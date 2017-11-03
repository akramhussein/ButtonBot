//
//  Defaults.swift
//  Bot
//
//  Created by Akram Hussein on 04/09/2017.
//  Copyright © 2017 Ross Atkin Associates. All rights reserved.
//

import Foundation

public struct Key {
    public static let ScanningSpeed = "ScanningSpeed"
    public static let RobotSpeed = "RobotSpeed"
    public static let Trim = "Trim"
    public static let ServoOn = "ServoOn"
    public static let ServoOff = "ServoOff"
}

public struct Defaults {

    // Set user defaults key - Bool
    public static func setUserDefaultsKey(_ key: String, value: Bool) {
        UserDefaults.standard.set(value, forKey: key)
    }

    // Set user defaults key - Int
    public static func setUserDefaultsKey(_ key: String, value: Int) {
        UserDefaults.standard.set(value, forKey: key)
    }

    // Set user defaults key - Double
    public static func setUserDefaultsKey(_ key: String, value: Double) {
        UserDefaults.standard.set(value, forKey: key)
    }

    // Set user defaults key - String
    public static func setUserDefaultsKey(_ key: String, value: String) {
        UserDefaults.standard.set(value, forKey: key)
    }

    // Get user defaults key
    public static func getUserDefaultsKey(_ key: String) -> Bool {
        return UserDefaults.standard.bool(forKey: key)
    }

    public static func getUserDefaultsValueForKeyAsInt(_ key: String) -> Int {
        return UserDefaults.standard.integer(forKey: key)
    }

    public static func getUserDefaultsValueForKeyAsDouble(_ key: String) -> Double {
        return UserDefaults.standard.double(forKey: key)
    }

    public static func resetUserDefaultsValueForKey(_ key: String) {
        return UserDefaults.standard.set(nil, forKey: key)
    }

    public static func removeUserDefaultsValueForKey(_ key: String) {
        return UserDefaults.standard.removeObject(forKey: key)
    }
}
