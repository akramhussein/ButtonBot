//
//  DeviceListViewController.swift
//  Bot
//
//  Created by Akram Hussein on 04/09/2017.
//  Copyright © 2017 Ross Atkin Associates. All rights reserved.
//

import UIKit
import MBProgressHUD

final class DeviceListTableViewCell: UITableViewCell {}

final class DeviceListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.dataSource = self
            self.tableView.delegate = self
            self.tableView.backgroundColor = .white

            self.tableView.separatorStyle = .singleLine
            self.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
            self.tableView.tableFooterView = UIView(frame: .zero)

            self.tableView.separatorInset = .zero
            self.tableView.layoutMargins = .zero

            self.tableView.register(DeviceListTableViewCell.self, forCellReuseIdentifier: "DeviceListTableViewCell")
        }
    }

    var selectedDevice: BluetoothDevice!
    var deviceList: [BluetoothDevice] = []
    var connection = BluetoothConnection()

    var hud: MBProgressHUD!
    var connectionTimer = Timer()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets = true
        self.edgesForExtendedLayout = .all
        self.navigationItem.title = "Select Robot"

        self.connection.onAvailableDevicesChanged = { devices in
            if let bleDevices = devices as? [BluetoothDevice] {
                self.deviceList = bleDevices
                self.tableView.reloadData()
            }
        }

        self.connection.onConnect = {
            if self.selectedDevice != nil {
                self.connectionTimer.invalidate()
                self.hud.hide(animated: true, afterDelay: 1.0)
                let vc = DeviceViewController(connection: self.connection, device: self.selectedDevice)
                self.navigationController?.pushViewController(vc, animated: true)
                self.selectedDevice = nil
            }
        }
    }

    @objc func failedToConnect(_ sender: Any) {
        self.hud.setHUDEndStatus(message: "Failed to connect",
                                 detailsMessage: "Check robot is still on and battery is charged",
                                 delay: 3.0)
    }
}
