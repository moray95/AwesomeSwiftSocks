//
//  SocketConnection.swift
//  Pods
//
//  Created by Moray on 23/06/16.
//
//

import Foundation

/**
 *  Defines methods to properly handle socket
 *  connections.
 */
public protocol SocketConnectionDelegate : class
{
  /// Called when the connection has been estabished with success.
  func socketConnectionDidConnect(socketConnection : SocketConnection)
  /// Called when the connection couldn't be established.
  func socketConnectionDidFailToConnect(socketConnection : SocketConnection)
  /// Called when the connection has ended.
  func socketConnectionDidDisconnect(socketConnection : SocketConnection)
  /// Called when the connection has received some data.
  func socketConnection(socketConnection : SocketConnection, didReciveData data : NSData)
}

/**
 *  An asynchonous socket connection to server.
 *  A `SocketConnectionDelegate` can be set to
 *  take appropriate action for each occuring event.
 *  The delegate is always called in the main thread.
 */
public class SocketConnection
{
  /// The queue to use for dispatching the events.
  private static let defaultDispatchQueue = dispatch_queue_create("com.moraybaruh.awesomeswiftsocks.dispatchqueue",
                                                                  DISPATCH_QUEUE_SERIAL)
  /// The delay between each dispatch.
  private static let disptachDelay : Int64 = 1

  /// The underlaying socket.
  private let socket : ClientSocket
  /// The delegate to report events to.
  public weak var delegate : SocketConnectionDelegate?
  /// The dispatch queue used for waiting for incomming data.
  private var dispatchQueue : dispatch_queue_t = SocketConnection.defaultDispatchQueue

  /**
   *  Creates a new connection to connect to the
   *  given URL with the given port.
   *
   *  - parameter url: The URL to connect to.
   *  - parameter port: The port to use for the connection.
   */
  public init(url : NSURL, port: Int)
  {
    socket = ClientSocket(url: url, port: port)
  }

  /**
   *  Starts the connection to receive data from
   *  the server. Uses a custom dispatch queue
   *  to await data unless specified otherwise.
   *
   *  - parameter dispatchQueue: The queue to dispatch the
   *                             read events into.
   */
  public func startConnection(dispatchQueue : dispatch_queue_t? = nil)
  {
    if let dispatchQueue = dispatchQueue
    {
      self.dispatchQueue = dispatchQueue
    }
    if socket.connect()
    {
      dispatch_async(dispatch_get_main_queue())
      {
        self.delegate?.socketConnectionDidConnect(self)
      }
      poll()
    }
    else
    {
      dispatch_async(dispatch_get_main_queue())
      {
        self.delegate?.socketConnectionDidFailToConnect(self)
      }
    }
  }

  private func poll()
  {
    let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, SocketConnection.disptachDelay)
    dispatch_after(dispatchTime, dispatchQueue, pollImpl)
  }

  private func pollImpl()
  {
    guard socket.connected else
    {
      dispatch_async(dispatch_get_main_queue())
      {
        self.delegate?.socketConnectionDidDisconnect(self)
      }
      return
    }
    // Ask for read event
    var pfd = pollfd(fd: socket.socket!, events: Int16(POLLIN), revents: 0)
    Darwin.poll(&pfd, 1, 10)
    let revents = Int(pfd.revents)
    if revents & Int(POLLHUP) != 0
    {
      close()
      return
    }
    if revents & Int(POLLIN) != 0
    {
      readAvailable()
    }
    poll()
  }

  /**
   *  Reads all the available data in the
   *  socket and transfers it to the delegate.
   */
  private func readAvailable()
  {
    let length = socket.bytesAvailable()
    if let data = socket.read(length)
    {
      dispatch_async(dispatch_get_main_queue())
      {
        self.delegate?.socketConnection(self, didReciveData: data)
      }
    }
  }

  /**
   *  Sends a message to the connected sercer.
   */
  public func send(msg : String)
  {
    socket.send(msg)
  }
  
  /**
   *  Sends a message to the connected sercer.
   */
  public func send(data : NSData)
  {
    socket.send(data)
  }

  /**
   *  Closes the connection.
   */
  public func close()
  {
    socket.close()
    dispatch_async(dispatch_get_main_queue())
    {
      self.delegate?.socketConnectionDidDisconnect(self)
      self.delegate = nil // Prevent multiple disconnect calls to the delegate due to polling
    }
  }

}