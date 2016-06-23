//
//  SocketUtils.swift
//  Pods
//
//  Created by Moray on 23/06/16.
//
//

import Foundation
import Darwin

func cast<T, U>(data : UnsafePointer<T>) -> UnsafePointer<U>
{
  return UnsafePointer<U>(data)
}

func cast<T, U>(data : UnsafePointer<T>) -> UnsafeMutablePointer<U>
{
  return UnsafeMutablePointer<U>(data)
}

func cast<T, U>(var data : T) -> U
{
  let dataPtr : UnsafePointer<U> = cast(&data)
  return dataPtr.memory
}

public typealias SocketType = Int32
public typealias PortType = UInt16

func createSocket() -> SocketType
{
  return socket(AF_INET, SOCK_STREAM, IPPROTO_TCP)
}

func closeSocket(socket : SocketType)
{
  close(socket)
}

func connectSocket(socket : SocketType, address : String, port : PortType) -> Bool
{
  var addr = sockaddr_in()
  addr.sin_family = UInt8(AF_INET)
  addr.sin_port = CFSwapInt16HostToBig(port)
  if inet_pton(AF_INET, address, cast(addr)) < 0
  {
    return false
  }
  if connect(socket, cast(&addr), UInt32(sizeof (sockaddr_in))) < 0
  {
    return false
  }
  return true
}

func writeSocket(socket : SocketType, data : NSData)
{
  write(socket, data.bytes, data.length)
}

func readSocket(socket : SocketType, length : Int) -> NSData?
{
  let data = UnsafeMutablePointer<Int8>.alloc(length)
  let read = Darwin.read(socket, data, length)
  if read <= 0
  {
    data.dealloc(length)
    return nil
  }
  // NSData will take uwnership of the pointer
  return NSData(bytesNoCopy: data, length: read)
}


func listenSocket(socket : SocketType, port : PortType) -> Bool
{
  var addr = sockaddr_in()
  addr.sin_family = UInt8(AF_INET)
  addr.sin_port = CFSwapInt16HostToBig(port)
  addr.sin_addr.s_addr = 0                    // INADDR_ANY seems not ported to Swift

  if bind(socket, cast(&addr), UInt32(sizeof (sockaddr_in))) < 0
  {
    return false
  }
  if listen(socket, 128) < 0
  {
    return false
  }
  return true
}

func acceptSocket(socket : SocketType) -> (socket : SocketType, address : NSURL, port : PortType)?
{
  var clientAddr = sockaddr_in()
  var size = UInt32(sizeof (sockaddr_in))
  let clientSocket = accept(socket, cast(&clientAddr), &size)
  guard clientSocket >= 0 else
  {
    return nil
  }
  let clientURL = inet_ntoa(clientAddr.sin_addr)
  let clientPort : PortType = clientAddr.sin_port
  return (socket: clientSocket, address: NSURL(string: String.fromCString(clientURL)!)!, port: clientPort)
}


