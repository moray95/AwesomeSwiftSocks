//
//  Socket.swift
//  Pods
//
//  Created by Moray on 22/06/16.
//
//

import Foundation

public class ServerSocket : Socket
{
  /// Wheather or not is listening.
  public var listening : Bool
  {
    if let socket = socket
    {
      return socket > 0
    }
    return false
  }

  /**
   *  Creates a new socket to listen no the given port.
   *
   *  - parameter port: The port to listen to.
   */
  public init(port : Int)
  {
    super.init(port: PortType(port))
  }

  public func listen()
  {
    guard !listening else
    {
      return
    }
    socket = createSocket()
    guard let socket = socket else
    {
      fatalError()
    }
    guard socket > 0 else
    {
      self.socket = nil
      return
    }
    if !listenSocket(socket, port: port)
    {
      self.socket = nil
    }
  }

  public func accept() -> ClientSocket?
  {
    guard let socket = socket else
    {
      fatalError("AwesomeSwiftSocks: Cannot accept clients without listening.")
    }
    guard let (clientSocket, clientURL, clientPort) = acceptSocket(socket) else
    {
      return nil
    }
    return ClientSocket(socket: clientSocket, url: clientURL, port: clientPort)
  }
}