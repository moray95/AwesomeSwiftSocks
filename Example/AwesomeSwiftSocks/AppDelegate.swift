//
//  AppDelegate.swift
//  AwesomeSwiftSocks
//
//  Created by Moray Baruh on 06/22/2016.
//  Copyright (c) 2016 Moray Baruh. All rights reserved.
//

import UIKit
import AwesomeSwiftSocks

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, SocketConnectionDelegate
{
  var window: UIWindow?

  func application(application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
  {
    let socket = ClientSocket(url: "www.moraybaruh.com", port: 80)
    if socket.connect()
    {
      socket.send("GET / HTTP/1.1\r\n")
      socket.send("host: www.moraybaruh.com\r\n\r\n")
      let received = NSMutableData()
      while let data = socket.read(1)
      {
        received.appendData(data)
      }
      print(String(data: received, encoding: NSUTF8StringEncoding)!)
    }
    else
    {
      print("Connection Failed")
    }
    return true
  }

  func socketConnectionDidConnect(socketConnection: SocketConnection)
  {
    print("Connected!")
    socketConnection.send("Connected!")
  }

  func socketConnectionDidDisconnect(socketConnection: SocketConnection)
  {
    print("Disconnected!")
  }

  func socketConnectionDidFailToConnect(socketConnection: SocketConnection)
  {
    print("Connection failed!")
  }

  func socketConnection(socketConnection: SocketConnection, didReciveData data: NSData)
  {
    print("Received data: \(String(data: data, encoding: NSUTF8StringEncoding)!)")
    socketConnection.close()
  }


}

