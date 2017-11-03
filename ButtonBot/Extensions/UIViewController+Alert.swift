//
//  UIViewController+Alert.swift
//  Bot
//
//  Created by Akram Hussein on 07/09/2017.
//  Copyright © 2017 Ross Atkin Associates. All rights reserved.
//

import UIKit

public extension UIViewController {
    func showAlert(_ message: String, okTitle: String? = "OK", okPressed: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let actionOk = UIAlertAction(title: okTitle, style: .default) { _ in
            okPressed?()
        }
        alertController.addAction(actionOk)
        DispatchQueue.main.async(execute: { () -> Void in
            self.present(alertController, animated: true, completion: nil)
        })
    }
}
