//
//  DeviceListViewController+UITableViewDataSource.swift
//  Bot
//
//  Created by Akram Hussein on 04/09/2017.
//  Copyright © 2017 Ross Atkin Associates. All rights reserved.
//

import UIKit

extension DeviceListViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.deviceList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let deviceCell = tableView.dequeueReusableCell(withIdentifier: "DeviceListTableViewCell", for: indexPath)
        let device = self.deviceList[indexPath.row]
        deviceCell.textLabel?.text = "\(device.name)"
        deviceCell.accessoryType = .disclosureIndicator
        return deviceCell
    }
}
