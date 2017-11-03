//
//  AppDelegate.swift
//  Bot
//
//  Created by Akram Hussein on 04/09/2017.
//  Copyright © 2017 Ross Atkin Associates. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        Theme.apply(statusBarColor: .primaryColor)

        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = .white

        let nav = UINavigationController(rootViewController: DeviceListViewController())
        nav.navigationBar.barTintColor = .primaryColor
        nav.navigationBar.backgroundColor = .primaryColor

        self.window?.rootViewController = nav
        self.window?.makeKeyAndVisible()
        return true
    }
}
