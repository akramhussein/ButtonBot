//
//  MBProgressHUD+Extensions.swift
//  Bot
//
//  Created by Akram Hussein on 04/09/2017.
//  Copyright © 2017 Ross Atkin Associates. All rights reserved.
//

import MBProgressHUD

extension MBProgressHUD {
    static func createHUD(view: UIView, message: String) -> MBProgressHUD {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = .indeterminate
        hud.label.text = message
        return hud
    }

    static func createSimpleHUD(view: UIView, message: String) -> MBProgressHUD {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = .text
        hud.label.text = message
        hud.removeFromSuperViewOnHide = true
        hud.hide(animated: true, afterDelay: 2)
        return hud
    }

    static func createLoadingHUD(view: UIView, message: String) -> MBProgressHUD {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = .indeterminate
        hud.label.text = message
        hud.removeFromSuperViewOnHide = true
        return hud
    }

    func setHUDEndStatusWithImage(message: String, detailsMessage: String? = nil, imagePath: String, delay: Double = 1.0) {
        let image = UIImage(named: imagePath)
        let imageView = UIImageView(image: image)
        self.customView = imageView
        self.mode = .customView
        self.label.text = message
        self.detailsLabel.text = detailsMessage
        self.removeFromSuperViewOnHide = true
        self.hide(animated: true, afterDelay: delay)
    }

    func setHUDEndStatus(message: String, detailsMessage: String? = nil, delay: Double = 1.0) {
        self.mode = .customView
        self.label.text = message
        self.detailsLabel.text = detailsMessage
        self.removeFromSuperViewOnHide = true
        self.hide(animated: true, afterDelay: delay)
    }
}
