//
//  ClientSocket.swift
//  AwesomeSwiftSocks
//
//  Created by Moray on 22/06/16.
//  Copyright © 2016 Moray Baruh. All rights reserved.
//

import Foundation
import Darwin
import AwesomeSwiftSocksCore

/**
 *  A simple client socket. Can be used to
 *  connect to server, send and receive messages.
 *
 *  The connection is closed when the object is
 *  destroyed.
 */
public class ClientSocket
{
  /// The URL of the server to connect.
  public let url : NSURL
  /// The port of the server to connect through.
  public let port : Int32
  /// The C socket used for connection.
  private var socket : Int32? = nil

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
    self.port = Int32(port)
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
    self.port = Int32(port)
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
    socket = ass_create_socket()
    guard let socket = socket else
    {
      fatalError()
    }
    guard socket > 0 else
    {
      return
    }
    if !ass_connect_socket(socket, url.absoluteString.cStringUsingEncoding(NSUTF8StringEncoding)!, port)
    {
      self.socket = nil
    }
  }

  /**
   *  Closes the current session with the
   *  server. Does nothing if the socket is
   *  not connected. Subsequent calls to `read` or
   *  `send` must be preceded by a class to `connect`
   *  to restablish the connection.
   */
  public func disconnect()
  {
    if let socket = socket
    {
      ass_close_socket(socket)
    }
    socket = nil
  }

  /**
   *  Sends a message to the connected server. Causes
   *  an program abortion if the socket is not connected.
   *
   *  - parameter msg: The message to send to the server.
   */
  public func send(msg : String)
  {
    guard let socket = socket else
    {
      fatalError("AwesomeSwiftSocks: Cannot send data without being connected.")
    }
    ass_write_socket(socket, msg.cStringUsingEncoding(NSUTF8StringEncoding)!, msg.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
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
  public func read(size : Int) -> String?
  {
    guard let socket = socket else
    {
      fatalError("AwesomeSwiftSocks: Cannot send data without being connected.")
    }
    let ptr = UnsafeMutablePointer<Int8>.alloc(size + 1)
    defer
    {
      ptr.dealloc(size + 1)
    }
    ptr.initialize(0) // Init the buffer to guarentee null termination
    let read = ass_read_socket(socket, ptr, size)
    if read == 0
    {
      return nil
    }
    return String.fromCString(ptr)
  }

  deinit
  {
    disconnect()
  }

}