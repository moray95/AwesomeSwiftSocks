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
class AppDelegate: UIResponder, UIApplicationDelegate
{
  var window: UIWindow?

  func application(application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
  {
    // Override point for customization after application launch.
    let serverSocket = ServerSocket(port: 9090)
    serverSocket.listen()
    while true
    {
      guard let clientSocket = serverSocket.accept() else
      {
        continue
      }
      var str = clientSocket.read(1)
      while str != nil
      {
        clientSocket.send(str!)
        str = clientSocket.read(1)
      }
    }
    return true
  }

}

