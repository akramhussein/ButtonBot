//
//  DeviceSettingsViewController.swift
//  Bot
//
//  Created by Akram Hussein on 04/09/2017.
//  Copyright © 2017 Ross Atkin Associates. All rights reserved.
//

import UIKit
import Eureka

public typealias DeviceSettingsCompletionHandler = ((Double, Int, Double, Int, Int) -> Void)

class DeviceSettingsViewController: FormViewController {

    // MARK: Properties
    private var scanningSpeed: Double!
    private var robotSpeed: Int!
    private var trim: Double!
    private var servoOn: Int!
    private var servoOff: Int!

    private var completionHandler: DeviceSettingsCompletionHandler?

    // MARK: View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back",
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(DeviceSettingsViewController.backPressed(_:)))

        form +++ Section("")

            <<< DecimalRow("scanning_speed") { row in
                row.title = "Scanning speed (Seconds)"
                row.value = self.scanningSpeed
                row.add(rule: RuleRequired())

                let ruleMax = RuleClosure<Double> { rowValue in
                    return (rowValue == nil || rowValue! < 0.1 || rowValue! > 100.0) ? ValidationError(msg: "Value must be between 0.1 and 100") : nil
                }

                row.add(rule: ruleMax)
                row.validationOptions = .validatesOnChange
            }
            .cellUpdate { cell, row in
                if !row.isValid {
                    cell.titleLabel?.textColor = .red
                }
            }

            <<< IntRow("robot_speed") { row in
                row.title = "Robot speed (%)"
                row.value = self.robotSpeed

                row.add(rule: RuleRequired())

                let ruleMax = RuleClosure<Int> { rowValue in
                    return (rowValue == nil || rowValue! < 1 || rowValue! > 100) ? ValidationError(msg: "Value must be between 1 and 100") : nil
                }

                row.add(rule: ruleMax)
                row.validationOptions = .validatesOnChange
            }
            .cellUpdate { cell, row in
                if !row.isValid {
                    cell.titleLabel?.textColor = .red
                }
            }
        
            <<< SliderRow("trim") { row in
                row.title = "Motor Trim"
                row.minimumValue = -10.0
                row.maximumValue = 10.0
                row.value = Float(self.trim)
            }.cellUpdate { cell, row in
                if let v = row.value {
                    row.cell.valueLabel.text = "L: \(-v) R: \(v)"
                }
            }
        
            <<< IntRow("servo_on") { row in
                row.title = "Servo On (Degrees)"
                row.value = self.servoOn
                
                row.add(rule: RuleRequired())
                
                let ruleMax = RuleClosure<Int> { rowValue in
                    return (rowValue == nil || rowValue! < 0 || rowValue! > 180) ? ValidationError(msg: "Value must be between 0 and 180") : nil
                }
                
                row.add(rule: ruleMax)
                row.validationOptions = .validatesOnChange
                }
                .cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                }
            }
            
            <<< IntRow("servo_off") { row in
                row.title = "Servo Off (Degrees)"
                row.value = self.servoOff
                
                row.add(rule: RuleRequired())
                
                let ruleMax = RuleClosure<Int> { rowValue in
                    return (rowValue == nil || rowValue! < 0 || rowValue! > 180) ? ValidationError(msg: "Value must be between 0 and 180") : nil
                }
                
                row.add(rule: ruleMax)
                row.validationOptions = .validatesOnChange
                }
                .cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
            }
    }

    // MARK: Init

    init(scanningSpeed: Double,
         robotSpeed: Int,
         trim: Double,
         servoOn: Int,
         servoOff: Int,
         completionHandler: ((Double, Int, Double, Int, Int) -> Void)?) {
        self.scanningSpeed = scanningSpeed
        self.robotSpeed = robotSpeed
        self.trim = trim
        self.servoOn = servoOn
        self.servoOff = servoOff
        self.completionHandler = completionHandler
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    @objc func backPressed(_ sender: Any) {
        guard let scanningSpeedRow = self.form.rowBy(tag: "scanning_speed") as? DecimalRow,
            let scanningSpeed = scanningSpeedRow.value,
            scanningSpeedRow.isValid else {
            self.showAlert("Value must be between 0.1 and 100")
            return
        }

        guard let robotSpeedRow = self.form.rowBy(tag: "robot_speed") as? IntRow,
            let robotSpeed = robotSpeedRow.value,
            robotSpeedRow.isValid else {
            self.showAlert("Value must be between 1 and 100")
            return
        }

        guard let trimRow = self.form.rowBy(tag: "trim") as? SliderRow,
            let trim = trimRow.value else {
            self.showAlert("Value must be between -10 and 10")
            return
        }

        guard let servoOnRow = self.form.rowBy(tag: "servo_on") as? IntRow,
            let servoOn = servoOnRow.value,
            servoOnRow.isValid else {
                self.showAlert("Value must be between 0 and 180")
                return
        }
        
        guard let servoOffRow = self.form.rowBy(tag: "servo_off") as? IntRow,
            let servoOff = servoOffRow.value,
            servoOffRow.isValid else {
                self.showAlert("Value must be between 0 and 180")
                return
        }

        self.completionHandler?(scanningSpeed, robotSpeed, Double(trim), servoOn, servoOff)
    }

}
