//
//  DeviceListViewController+UITableViewDelegate.swift
//  Bot
//
//  Created by Akram Hussein on 04/09/2017.
//  Copyright © 2017 Ross Atkin Associates. All rights reserved.
//

import UIKit
import MBProgressHUD

extension DeviceListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)

        let device = deviceList[indexPath.row]
        self.selectedDevice = device
        self.hud = MBProgressHUD.createLoadingHUD(view: self.view, message: "Connecting...")
        self.connectionTimer = Timer.scheduledTimer(timeInterval: 10.0,
                                                    target: self,
                                                    selector: #selector(DeviceListViewController.failedToConnect(_:)),
                                                    userInfo: nil,
                                                    repeats: false)
        self.connection.connect(device)
    }
}
