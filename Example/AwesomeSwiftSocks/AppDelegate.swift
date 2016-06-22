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
    let socket = ClientSocket(url: "127.0.0.1", port: 3030)
    socket.connect()
    socket.send("Hello World!")
    print(socket.read(300))
    return true
  }

}

