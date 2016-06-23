//
//  Socket.swift
//  Pods
//
//  Created by Moray on 23/06/16.
//
//

import Foundation

public class Socket
{
  var socket : SocketType? = nil
  /// The port of the server to connect through.
  public let port : PortType

  init(socket : SocketType? = nil, port : PortType)
  {
    self.socket = socket
    self.port = port
  }

  /**
   *  Closes the current session with the
   *  server. Does nothing if the socket is
   *  not already closed or not connected.
   */
  public func close()
  {
    if let socket = socket
    {
      closeSocket(socket)
    }
    socket = nil
  }

  deinit
  {
    close()
  }

}