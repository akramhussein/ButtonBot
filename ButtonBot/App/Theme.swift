//
//  Theme.swift
//  Bot
//
//  Created by Akram Hussein on 04/09/2017.
//  Copyright © 2017 Ross Atkin Associates. All rights reserved.
//

import UIKit

struct Theme {
    static func apply(statusBarColor: UIColor) {
        UIBarButtonItem.appearance().tintColor = .white

        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().isOpaque = true
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedStringKey.foregroundColor: UIColor.white
        ]

        UINavigationBar.appearance().setBackgroundImage(UIImage(),
                                                        for: .any,
                                                        barMetrics: .default)

        UINavigationBar.appearance().shadowImage = UIImage()

        // System wide status bar color
        Theme.setStatusBarBackgroundColor(statusBarColor)
    }

    static func setStatusBarBackgroundColor(_ color: UIColor) {
        guard let statusBar = (UIApplication.shared.value(forKey: "statusBarWindow") as AnyObject).value(forKey: "statusBar") as? UIView
        else { return }
        statusBar.backgroundColor = color
    }
}
