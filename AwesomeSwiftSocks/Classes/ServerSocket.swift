//
//  Socket.swift
//  Pods
//
//  Created by Moray on 22/06/16.
//
//

import Foundation

/**
 *  A server-side socket that can be used
 *  to accept incomming connections and handle
 *  clients.
 */
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

  /**
   *  Starts listening for incomming connections.
   *  Does nothing if the socket is already listening.
   *  Returns whether or not the socket started listening.
   *
   *  - returns: `true` if the socket started listening for
   *             connections or was already listening and
   *             `false` if an error occured.
   */
  public func listen() -> Bool
  {
    guard !listening else
    {
      return true
    }
    socket = createSocket()
    guard let socket = socket else
    {
      return false
    }
    guard socket > 0 else
    {
      self.socket = nil
      return false
    }
    guard listenSocket(socket, port: port) else
    {
      self.socket = nil
      return false
    }
    return true
  }

  /**
   *  Accepts a client connection to the socket.
   *  Returns the socket associated with the accepted
   *  client or `nil` if an error occured.
   *
   *  Calls to this method must be preceded by a
   *  successfull call to `listen`.
   *
   *  - returns: The socket associated with the newly
   *             accepted client or `nil` if an error
   *             occured.
   */
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

  /**
   *  Starts a server run loop for accepting
   *  all incomming connection to the socket.
   *  Calls `clientHandler` for each accepted
   *  client. Discards failed accepts. This 
   *  method does not return.
   */
  @noreturn
  public func acceptAll(clientHandler : ClientSocket -> ())
  {
    while true
    {
      if let clientSocket = accept()
      {
        clientHandler(clientSocket)
      }
    }
  }

}