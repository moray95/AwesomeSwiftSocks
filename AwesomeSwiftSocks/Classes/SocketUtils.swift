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

func resolveAddress(address : String) -> String?
{
  let host = CFHostCreateWithName(nil, address).takeRetainedValue()
  CFHostStartInfoResolution(host, .Addresses, nil)
  var success: DarwinBoolean = false
  guard let addresses = CFHostGetAddressing(host, &success)?.takeUnretainedValue() as NSArray?,
            theAddress = addresses.firstObject as? NSData else
  {
    return nil
  }
  var hostname = [CChar](count: Int(NI_MAXHOST), repeatedValue: 0)
  guard getnameinfo(UnsafePointer(theAddress.bytes), socklen_t(theAddress.length),
                   &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 else
  {
      return nil
  }
  return String.fromCString(hostname)
}

func connectSocket(socket : SocketType, address : String, port : PortType) -> Bool
{
  var addr = sockaddr_in()
  addr.sin_family = UInt8(AF_INET)
  addr.sin_port = CFSwapInt16HostToBig(port)
  guard let host = resolveAddress(address) else
  {
    return false
  }
  guard inet_pton(AF_INET, host, cast(&addr.sin_addr)) != -1 else
  {
    return false
  }
  return connect(socket, cast(&addr), UInt32(sizeof (sockaddr_in))) != -1
}

func writeSocket(socket : SocketType, data : NSData) -> Bool
{
  return write(socket, data.bytes, data.length) != -1
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

func socketIgnoreSigpipe(socket : SocketType)
{
  var value = 1
  setsockopt(socket, SOL_SOCKET, SO_NOSIGPIPE, &value, UInt32(sizeof (Int)))
}
