//
//  SockerServer.swift
//  Pods
//
//  Created by Moray on 23/06/16.
//
//

import Foundation

/**
 *  Defines methods to properly handle events on a `SocketServer`.
 */
public protocol SocketServerDelegate : class
{
  /// Called when the server has been started successfully.
  func socketServerDidStart(socketServer : SocketServer)
  /// Called when the server has failed to start.
  func socketServerDidFailToStart(socketServer : SocketServer)
  /// Called when the server has accepted a client.
  func socketServer(socketServer : SocketServer, didAcceptClient clientSocket : ClientSocket)
  /// Called when the server has stopped.
  func socketServerDidStop(socketServer : SocketServer)
}

public class SocketServer
{
  /// The default dispatch queue to use for dispatching the polling.
  private static let defaultDispatchQueue = dispatch_queue_create("com.moraybaruh.awesomeswiftsocks.serverdispatchqueue",
                                                                  DISPATCH_QUEUE_SERIAL)
  /// The delay between each dispatch.
  private static let disptachDelay : Int64 = 1

  /// The uderlaying server socket.
  private let socket : ServerSocket
  /// The delagate to dispatch events to.
  public weak var delegate : SocketServerDelegate?
  /// The dispatch queue to use for polling.
  private var dispatchQueue = SocketServer.defaultDispatchQueue

  /**
   *  Creates a server to accept connections
   *  on the given port.
   *
   *  - parameter port: The port to bind to.
   */
  public init(port : Int)
  {
    socket = ServerSocket(port: port)
  }

  /**
   *  Starts the server to accept clients. Uses
   *  the given dispatch queue for polling for not
   *  nil. Otherwise uses the default dispatch queue.
   *
   *  - parameter dispatchQueue: The dispatch to to use
   *                             for polling.
   */
  public func start(dispatchQueue : dispatch_queue_t? = nil)
  {
    if let dispatchQueue = dispatchQueue
    {
      self.dispatchQueue = dispatchQueue
    }
    guard socket.listen() else
    {
      dispatch_async(dispatch_get_main_queue())
      {
        self.delegate?.socketServerDidFailToStart(self)
      }
      return
    }
    dispatch_async(dispatch_get_main_queue())
    {
      self.delegate?.socketServerDidStart(self)
    }
    poll()
  }

  private func poll()
  {
    let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, SocketServer.disptachDelay)
    dispatch_after(dispatchTime, dispatchQueue, pollImpl)
  }

  private func pollImpl()
  {
    guard socket.listening else
    {
      return
    }
    var pfd = pollfd(fd: socket.socket!, events: Int16(POLLIN), revents: 0)
    Darwin.poll(&pfd, 1, 10)
    let revents = Int(pfd.revents)
    if revents & Int(POLLHUP) != 0
    {
      stop()
      return
    }
    if revents & Int(POLLIN) != 0
    {
      let clientSocket = socket.acceptNext()
      delegate?.socketServer(self, didAcceptClient: clientSocket)
    }
    poll()
  }

  /**
   *  Stops the server.
   */
  private func stop()
  {
    socket.close()
    dispatch_async(dispatch_get_main_queue())
    {
      self.delegate?.socketServerDidStop(self)
    }
  }

}