//
//  SocketConnection.swift
//  Pods
//
//  Created by Moray on 23/06/16.
//
//

import Foundation

public protocol SocketConnectionDelegate : class
{
  func socketConnectionDidConnect(socketConnection : SocketConnection)
  func socketConnectionDidFailToConnect(socketConnection : SocketConnection)
  func socketConnectionDidDisconnect(socketConnection : SocketConnection)
  func socketConnection(socketConnection : SocketConnection, didReciveData data : NSData)
}

public class SocketConnection
{
  private static let dispatchQueue = dispatch_queue_create("com.moraybaruh.awesomeswiftsocks.dispatchqueue",
                                                            DISPATCH_QUEUE_SERIAL)
  private static let disptachDelay : Int64 = 1

  public let socket : ClientSocket
  public weak var delegate : SocketConnectionDelegate?

  public init(url : NSURL, port: Int)
  {
    socket = ClientSocket(url: url, port: port)
  }

  public func startConnection()
  {
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
    dispatch_after(dispatchTime, SocketConnection.dispatchQueue, pollImpl)
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
    var pfd = pollfd(fd: socket.socket!, events: Int16(POLLIN), revents: 0)
    Darwin.poll(&pfd, 1, 10)
    let revents = Int(pfd.revents)
    if revents & Int(POLLHUP) != 0
    {
      disconnect()
      return
    }
    if revents & Int(POLLIN) != 0
    {
      readAvailable()
    }
    poll()
  }

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

  public func disconnect()
  {
    socket.close()
    dispatch_async(dispatch_get_main_queue())
    {
      self.delegate?.socketConnectionDidDisconnect(self)
      self.delegate = nil // Prevent multiple call to the delegate due to polling
    }
  }

}