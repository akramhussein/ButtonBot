//
//  BluetoothConnection.swift
//  Makeblock
//
//  Created by Wang Yu on 6/6/16.
//  Copyright © 2016 Makeblock. All rights reserved.
//

import Foundation
import CoreBluetooth

/// An bluetooth device
open class BluetoothDevice: Device {
    var peripheral: CBPeripheral?
    var RSSI: NSNumber?

    func distanceByRSSI() -> Float {
        if let rssi = RSSI {
            return powf(10.0, ((abs(rssi.floatValue) - 50.0) / 50.0)) * 0.7
        }
        return -1.0
    }

    /**
     Create a device using a CBPeripheral
     Normally you don't need to init a BluetoothDevice by yourself

     - parameter peri: the peripheral instance

     - returns: nil
     */
    public init(peri: CBPeripheral) {
        super.init()
        self.peripheral = peri
    }

    public override init() {
        super.init()
    }
}

/// The bluetooth connection
open class BluetoothConnection: NSObject, Connection, CBCentralManagerDelegate, CBPeripheralDelegate {

    // Bluetooth Module Characteristics
    let readWriteServiceUUID = "FFE1"
    let readNotifyCharacteristicUUID = "FFE2"
    let writeCharacteristicUUID = "FFE3"
    /// the maximum length of the package that can be send
    let notifyMTU = 20 // maximum 20 bytes in a single ble package

    // CoreBluetooth related
    var centralManager: CBCentralManager?
    var peripherals: [CBPeripheral] = []
    var activePeripheral: CBPeripheral?
    var writeCharacteristic: CBCharacteristic?
    var notifyReady = false

    // Connection related
    var deviceList: [BluetoothDevice] = []
    open var onConnect: (() -> Void)?
    open var onDisconnect: (() -> Void)?
    open var onReceive: ((Data) -> Void)?
    open var onAvailableDevicesChanged: (([Device]) -> Void)?
    var isConnectingDefaultDevice = false

    public override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }

    // Connection Methods
    /// Start scanning Bluetooth devices
    open func startDiscovery() {
        self.centralManager?.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: 0])
    }

    /// Stop scanning Bluetooth devices
    open func stopDiscovery() {
        self.centralManager?.stopScan()
    }

    /// Stop and start scanning Bluetooth devices
    func resetDiscovery() {
        self.stopDiscovery()
        self.startDiscovery()
    }

    /// Connect to a bluetooth device
    open func connect(_ device: Device) {
        if let bluetoothDevice = device as? BluetoothDevice {
            self.centralManager?.connect(bluetoothDevice.peripheral!, options: nil)
            self.stopDiscovery()
        }
    }

    /// TODO: Connect to the nearest bluetooth device after 5 seconds
    open func connectDefaultDevice() {
        self.isConnectingDefaultDevice = true
        self.startDiscovery()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
            // connect to the nearest devices after 5 seconds
            if self.deviceList.count > 0 {
                self.connect(self.deviceList[0])
            }
        }
    }

    open func disconnect() {
        if let peripheral = activePeripheral {
            self.centralManager?.cancelPeripheralConnection(peripheral)
            self.resetDiscovery()
        }
    }

    open func send(_ data: Data) {
        if let peripheral = activePeripheral {
            if peripheral.state == .connected {
                if let characteristic = writeCharacteristic {
                    var sendIndex = 0
                    while true {
                        var amountToSend = data.count - sendIndex
                        if amountToSend > self.notifyMTU {
                            amountToSend = self.notifyMTU
                        }
                        if amountToSend <= 0 {
                            return
                        }
                        let p: UnsafePointer = ((data as NSData).bytes + sendIndex).assumingMemoryBound(to: UInt8.self)
                        let dataChunk = Data(bytes: p, count: amountToSend)

                        peripheral.writeValue(dataChunk, for: characteristic, type: .withoutResponse)
                        sendIndex += amountToSend
                    }
                }
            }
        }
    }

    // CoreBluetooth Methods
    open func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if self.centralManager!.isEqual(central) {
            if central.state == .poweredOn {
                self.startDiscovery()
            } else {
                self.resetDiscovery()
            }
        }
    }

    open func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if self.centralManager!.isEqual(central) {
            if !self.peripherals.contains(peripheral) {
                if let name = peripheral.name {
                    if name.hasPrefix("Makeblock") {
                        self.peripherals.append(peripheral)
                        print("Adding peripherals \(self.peripherals)")
                        let device = BluetoothDevice(peri: peripheral)
                        device.RSSI = RSSI
                        device.distance = device.distanceByRSSI()
                        if let name = peripheral.name {
                            device.name = name
                        } else {
                            device.name = "Unknown"
                        }
                        self.deviceList.append(device)

                        // order devices according to their distance to the user
                        if self.deviceList.count > 1 {
                            self.deviceList.sort { $0.distanceByRSSI() < $1.distanceByRSSI() }
                        }

                        if let callback = onAvailableDevicesChanged {
                            callback(self.deviceList)
                        }
                    }
                }
            }
        }
    }

    /// Connected says central manager
    open func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if self.centralManager!.isEqual(central) {
            if !self.peripherals.contains(peripheral) {
                self.peripherals.append(peripheral)
                print("added undiscovered peripheral \(peripheral.identifier.uuidString)")
            }

            self.activePeripheral = peripheral
            peripheral.delegate = self
            peripheral.discoverServices([CBUUID(string: readWriteServiceUUID)])
        }
    }

    /// TODO: Fail to connect says central manager
    open func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("failed to connect peripheral")
    }

    /// Disconnected says central manager
    open func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let callback = onDisconnect {
            callback()
        }
    }

    /// Service discovered
    open func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if peripheral.isEqual(self.activePeripheral) {
            if let services = peripheral.services {
                for service in services {
                    print("discovered service \(service.uuid)")
                    if service.uuid.isEqual(CBUUID(string: self.readWriteServiceUUID)) {
                        peripheral.discoverCharacteristics(nil, for: service)
                    }
                }
            }
        }
    }

    /// If both write characteristic and notify is setup, call "onConnected" callback
    func checkAndNotifyIfConnected() {
        if self.notifyReady && self.writeCharacteristic != nil {
            if let callback = onConnect {
                print("onConnect")
                callback()
            }
        }
    }

    open func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if peripheral.isEqual(self.activePeripheral) {
            if let characteristics = service.characteristics {
                for characteristic in characteristics {
                    if characteristic.uuid.isEqual(CBUUID(string: self.writeCharacteristicUUID)) {
                        self.writeCharacteristic = characteristic
                        self.checkAndNotifyIfConnected()
                    } else if characteristic.uuid.isEqual(CBUUID(string: self.readNotifyCharacteristicUUID)) {
                        peripheral.setNotifyValue(true, for: characteristic)
                        self.notifyReady = true
                        self.checkAndNotifyIfConnected()
                    }
                }
            }
        }
    }

    open func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if error == nil {
            if peripheral.isEqual(self.activePeripheral) {
                if characteristic.uuid.isEqual(CBUUID(string: self.readNotifyCharacteristicUUID)) {
                    if let callback = onReceive {
                        if let value = characteristic.value {
                            callback(value)
                        }
                    }
                }
            }
        }
    }

}
