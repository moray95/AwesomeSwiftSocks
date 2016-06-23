//
//  ClientSocket.swift
//  AwesomeSwiftSocks
//
//  Created by Moray on 22/06/16.
//  Copyright © 2016 Moray Baruh. All rights reserved.
//

import Foundation
import Darwin

/**
 *  A simple client socket. Can be used to
 *  connect to server, send and receive messages.
 *
 *  The connection is closed when the object is
 *  destroyed.
 */
public class ClientSocket : Socket
{
  /// The URL of the server to connect.
  public let url : NSURL

  /// Wheather or not the socket is connected.
  public var connected : Bool
  {
    if let socket = socket
    {
      return socket > 0
    }
    return false
  }

  /**
   *  Creates a new socket to connect to the
   *  given server with the given port.
   *
   *  - paramter url: The URL of the server. This should
   *                   be a valid URL.
   *  - parameter port: The port to be used for the connection.
   */
  public init(url : String, port : Int)
  {
    self.url = NSURL(string: url)!
    super.init(port: PortType(port))
  }

  /**
   *  Creates a new socket to connect to the
   *  given server with the given port.
   *
   *  - paramter url: The URL of the server. This should
   *                  be a valid URL.
   *  - parameter port: The port to be used for the connection.
   */
  public init(url : NSURL, port : Int)
  {
    self.url = url
    super.init(port: PortType(port))
  }

  init(socket : SocketType, url : NSURL, port : PortType)
  {
    self.url = url
    super.init(socket: socket, port: port)
  }

  /**
   *  Connects the socket to the server. This method aborts
   *  if the `socket(2)` syscall fails. The socket won't be
   *  connected if the call to `connect(2)` fails.
   *  Check with `connected` if this call succeeds.
   */
  public func connect()
  {
    guard !connected else
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
    if !connectSocket(socket, address: url.absoluteString, port: port)
    {
      self.socket = nil
    }
  }

  /**
   *  Sends a message to the connected server. Causes
   *  an program abortion if the socket is not connected.
   *
   *  - parameter msg: The message to send to the server.
   */
  public func send(msg : String)
  {
    send(msg.dataUsingEncoding(NSUTF8StringEncoding)!)
  }

  public func send(data : NSData)
  {
    guard let socket = socket else
    {
      fatalError("AwesomeSwiftSocks: Cannot send data without being connected.")
    }
    writeSocket(socket, data: data)
  }

  /**
   *  Reads a message of given length from the server.
   *  Returns the string read from the server if any.
   *
   *  - parameter size: The size of the string to read.
   *
   *  - returns: A string of maximum size `size` sent by the server if any.
   *             If the returned value is `nil`, this probably means that the
   *             server closed the connection.
   */
  public func read(size : Int) -> NSData?
  {
    guard let socket = socket else
    {
      fatalError("AwesomeSwiftSocks: Cannot send data without being connected.")
    }
    return readSocket(socket, length: size)
  }

}