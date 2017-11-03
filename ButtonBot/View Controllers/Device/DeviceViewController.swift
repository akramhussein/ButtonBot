//
//  DeviceViewController.swift
//  Bot
//
//  Created by Akram Hussein on 04/09/2017.
//  Copyright © 2017 Ross Atkin Associates. All rights reserved.
//

import UIKit


final class DeviceViewController: UIViewController {

    // MARK: UI Outlets

    @IBOutlet weak var forwardButton: UIButton! {
        didSet {
            self.forwardButton.layer.cornerRadius = 6.0
            self.forwardButton.tintColor = .white
            self.forwardButton.backgroundColor = .unselectedButtonBackgroundColor
            self.forwardButton.imageView?.contentMode = .scaleAspectFit
            self.forwardButton.imageEdgeInsets = UIEdgeInsetsMake(25, 25, 25, 25)

            self.forwardButton.setImage(self.arrowImage, for: .normal)
        }
    }

    @IBOutlet weak var rightButton: UIButton! {
        didSet {
            self.rightButton.layer.cornerRadius = 6.0
            self.rightButton.tintColor = .white
            self.rightButton.backgroundColor = .unselectedButtonBackgroundColor
            self.rightButton.imageView?.contentMode = .scaleAspectFit
            self.rightButton.imageEdgeInsets = UIEdgeInsetsMake(25, 25, 25, 25)

            self.rightButton.setImage(self.arrowImage,  for: .normal)
            self.rightButton.imageView?.transform = (self.rightButton.imageView?.transform.rotated(by: .pi / 2))!
        }
    }

    @IBOutlet weak var backwardButton: UIButton! {
        didSet {
            self.backwardButton.layer.cornerRadius = 6.0
            self.backwardButton.tintColor = .white
            self.backwardButton.backgroundColor = .unselectedButtonBackgroundColor
            self.backwardButton.imageView?.contentMode = .scaleAspectFit
            self.backwardButton.imageEdgeInsets = UIEdgeInsetsMake(25, 25, 25, 25)

            self.backwardButton.setImage(self.arrowImage,  for: .normal)
            self.backwardButton.imageView?.transform = (self.backwardButton.imageView?.transform.rotated(by: .pi))!
        }
    }

    @IBOutlet weak var leftButton: UIButton! {
        didSet {
            self.leftButton.layer.cornerRadius = 6.0
            self.leftButton.tintColor = .white
            self.leftButton.backgroundColor = .unselectedButtonBackgroundColor
            self.leftButton.imageView?.contentMode = .scaleAspectFit
            self.leftButton.imageEdgeInsets = UIEdgeInsetsMake(25, 25, 25, 25)

            self.leftButton.setImage(self.arrowImage,  for: .normal)
            self.leftButton.imageView?.transform = (self.leftButton.imageView?.transform.rotated(by: -(.pi/2)))!

        }
    }

    @IBOutlet weak var actionButton: UIButton! {
        didSet {
            self.actionButton.layer.cornerRadius = 6.0

            let gesture = UILongPressGestureRecognizer(target: self,
                                                       action: #selector(DeviceViewController.longPressAction(recognizer:)))
            gesture.minimumPressDuration = 0.05
            self.actionButton.addGestureRecognizer(gesture)
        }
    }

    private var allButtons = [UIButton]()

    // MARK: Properties

    private var connection: BluetoothConnection!
    private var mBot: MBot!
    private var device: BluetoothDevice?
    private var arrowImage = UIImage(named: "Arrow")!

    private var buttonTimer = Timer()
    private var keyboardTimer = Timer()
    private var keyboardSpacebarTimer = Timer()

    private var currentDirectionButton: UIButton! {
        didSet {
            switch self.currentDirectionButton {
            case self.forwardButton:
                self.currentDirectionButton.backgroundColor = .forward
                self.setRGB(position: .first, red: 100, green: 0, blue: 0)
            case self.rightButton:
                self.currentDirectionButton.backgroundColor = .right
                self.setRGB(position: .second, red: 100, green: 0, blue: 0)
            case self.backwardButton:
                self.currentDirectionButton.backgroundColor = .backward
                self.setRGB(position: .third, red: 100, green: 0, blue: 0)
            case self.leftButton:
                self.currentDirectionButton.backgroundColor = .left
                self.setRGB(position: .fourth, red: 100, green: 0, blue: 0)
            default:
                return
            }

            self.currentDirectionButton.alpha = 1.0
        }
    }
    
    func setRGB(position: MBot.RGBLEDBoardPosition, red: Int, green: Int, blue: Int) {
        self.mBot.setRGBLED(.port1, position: position, red: red, green: green, blue: blue)
        if let lastPos = self.lastPosition {
            self.mBot.setRGBLED(.port1, position: lastPos, red: 0, green: 0, blue: 0)
        }
        self.lastPosition = position
    }

    var robotSpeed: Double {
        let speed = Defaults.getUserDefaultsValueForKeyAsInt(Key.RobotSpeed)
        if speed == 0 {
            Defaults.setUserDefaultsKey(Key.RobotSpeed, value: 100)
            return 100.0
        }
        return Double(speed)
    }

    var mBotSpeed: Int {
        return Int((self.robotSpeed / 100.0) * 255.0)
    }
    
    var turnSpeed: Int {
        return Int(((self.robotSpeed / 2) / 100.0) * 255.0)
    }

    var scanningSpeed: Double {
        let speed = Defaults.getUserDefaultsValueForKeyAsDouble(Key.ScanningSpeed)
        if speed == 0.0 {
            Defaults.setUserDefaultsKey(Key.ScanningSpeed, value: 1.0)
            return 1.0
        }
        return speed
    }
    
    var trim: Double {
        return Defaults.getUserDefaultsValueForKeyAsDouble(Key.Trim)
    }

    var servoOn: Int {
        let v = Defaults.getUserDefaultsValueForKeyAsInt(Key.ServoOn)
        if v == 0 {
            Defaults.setUserDefaultsKey(Key.ServoOn, value: 25)
            return 25
        }
        return v
    }
    
    var servoOff: Int {
        let v = Defaults.getUserDefaultsValueForKeyAsInt(Key.ServoOff)
        if v == 0 {
            Defaults.setUserDefaultsKey(Key.ServoOff, value: 105)
            return 105
        }
        return v    }
    
    var scanning: Bool = false {
        didSet {
            if self.scanning {
                self.buttonTimer.invalidate()
                self.buttonTimer = Timer.scheduledTimer(timeInterval: self.scanningSpeed,
                                                        target: self,
                                                        selector: #selector(DeviceViewController.highlightButton(_:)),
                                                        userInfo: nil,
                                                        repeats: true)
            } else {
                self.buttonTimer.invalidate()
            }
        }
    }

    var accessSwitchInterval = 0.25
    
    var commands: [UIKeyCommand] = {
        [
            UIKeyCommand(input: " ", modifierFlags: [], action: #selector(DeviceViewController.spacePressed(_:))),
            UIKeyCommand(input: "\r", modifierFlags: [], action: #selector(DeviceViewController.enterPressed(_:)))
        ]
    }()
    
    lazy var ledPositions: [UIButton: MBot.RGBLEDBoardPosition] = {
        return [
            self.forwardButton: .first,
            self.rightButton: .second,
            self.backwardButton: .third,
            self.leftButton: .fourth,
        ]
    }()
    
    func ledPosition(button: UIButton) -> MBot.RGBLEDBoardPosition {
        return self.ledPositions[button]!
    }
    
    var lastPosition: MBot.RGBLEDBoardPosition?

    override var keyCommands: [UIKeyCommand]? {
        return self.commands
    }

    // MARK: ViewController Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "\(self.device?.name ?? "Bot")"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(DeviceViewController.backPressed(_:)))

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(DeviceViewController.settingsPressed(_:)))

        self.allButtons = [
            self.forwardButton,
            self.rightButton,
            self.leftButton,
            self.backwardButton
        ]

        self.allButtons.forEach { button in
            let gesture = UILongPressGestureRecognizer(target: self,
                                                       action: #selector(DeviceViewController.longPressGesture(recognizer:)))
            gesture.minimumPressDuration = 0.05
            button.addGestureRecognizer(gesture)
        }

        self.currentDirectionButton = self.forwardButton

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.scanning = true
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.buttonTimer.invalidate()
        self.keyboardTimer.invalidate()
        self.keyboardSpacebarTimer.invalidate()
    }
    
    // MARK: Init

    init(connection: BluetoothConnection, device: BluetoothDevice?) {
        self.connection = connection
        self.device = device
        self.mBot = MBot(connection: self.connection)
        super.init(nibName: nil, bundle: nil)
        self.mBot.clearRGBLED(.port1)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: Gestures

    @objc func longPressGesture(recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            self.activateCurrentDirectionButton(self)
            self.scanning = false
        } else if recognizer.state == .ended {
            print("Stop moving")
            self.mBot.stopMoving()
            
            if self.currentDirectionButton != self.forwardButton {
                self.currentDirectionButton.backgroundColor = .unselectedButtonBackgroundColor
                self.currentDirectionButton = self.forwardButton
            }
            
            self.scanning = true
        }
    }

    @objc func longPressAction(recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            print("Action ON")
            self.mBot.setServo(.port4, value: self.servoOn)
        } else if recognizer.state == .ended {
            print("Action OFF")
            self.mBot.setServo(.port4, value: self.servoOff)
        }
    }

    @objc func backPressed(_ sender: Any) {
        self.mBot.clearRGBLED(.port1)
        self.connection.disconnect()
        self.navigationController?.popViewController(animated: true)
    }

    @objc func settingsPressed(_ sender: Any) {
        self.mBot.clearRGBLED(.port1)
        let vc = DeviceSettingsViewController(scanningSpeed: self.scanningSpeed,
                                              robotSpeed: Int(self.robotSpeed),
                                              trim: self.trim,
                                              servoOn: self.servoOn,
                                              servoOff: self.servoOff) { scanningSpeed, robotSpeed, trim, servoOn, servoOff in
                                                
            Defaults.setUserDefaultsKey(Key.ScanningSpeed, value: scanningSpeed)
            Defaults.setUserDefaultsKey(Key.RobotSpeed, value: robotSpeed)
            Defaults.setUserDefaultsKey(Key.Trim, value: trim)
            Defaults.setUserDefaultsKey(Key.ServoOn, value: servoOn)
            Defaults.setUserDefaultsKey(Key.ServoOff, value: servoOff)

            self.buttonTimer.invalidate()
            self.buttonTimer = Timer.scheduledTimer(timeInterval: self.scanningSpeed,
                                                    target: self,
                                                    selector: #selector(DeviceViewController.highlightButton(_:)),
                                                    userInfo: nil,
                                                    repeats: true)

            self.navigationController?.popViewController(animated: true)
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @objc func highlightButton(_ sender: Any) {
        self.currentDirectionButton.backgroundColor = .unselectedButtonBackgroundColor
        self.currentDirectionButton.alpha = 1.0
        
        guard let index = self.allButtons.index(of: self.currentDirectionButton) else {
            return
        }

        self.currentDirectionButton = (index + 1 < self.allButtons.count)
            ? self.allButtons[index + 1]
            : self.allButtons.first!
    }
    
    

    func activateCurrentDirectionButton(_ sender: Any) {
        switch self.currentDirectionButton {
            
        case self.forwardButton:
            
            let botSpeed = Double(self.mBotSpeed) * 0.90
            var left = botSpeed
            var right = botSpeed
            let trimFactor = (self.trim / 100)
            
            let up = (1.0 + trimFactor) * botSpeed
            let down = (1.0 - trimFactor) * botSpeed
            
            if self.trim < 0 {
                left = up
                right = down
            } else if self.trim > 0 {
                left = down
                right = up
            }
        
            print("Forward at speed: L=\(-Int(left)), R=\(Int(right))")
            self.mBot.self.setMotors(-Int(left), rightMotor: Int(right))
            self.mBot.setRGBLED(.port1, position: .first, red: 0, green: 100, blue: 0)
        case self.rightButton:
            print("Right at speed: \(self.mBotSpeed)")
            self.mBot.turnRight(self.turnSpeed)
            self.mBot.setRGBLED(.port1, position: .second, red: 0, green: 100, blue: 0)
        case self.backwardButton:
            print("Backward at speed: \(self.mBotSpeed)")
            self.mBot.moveBackward(self.mBotSpeed)
            self.mBot.setRGBLED(.port1, position: .third, red: 0, green: 100, blue: 0)
        case self.leftButton:
            print("Left at speed: \(self.mBotSpeed)")
            self.mBot.turnLeft(self.turnSpeed)
            self.mBot.setRGBLED(.port1, position: .fourth, red: 0, green: 100, blue: 0)
        default:
            break
        }
    }
    
    @objc func stopBot() {
        print("Stop moving")
        self.mBot.stopMoving()
        if self.currentDirectionButton != self.forwardButton {
            self.currentDirectionButton.backgroundColor = .unselectedButtonBackgroundColor
            self.currentDirectionButton = self.forwardButton
        }
        self.scanning = true
    }

    @objc func stopAction() {
        self.mBot.setServo(.port4, value: self.servoOff)
    }

    // MARK: Access Switch

    override var canBecomeFirstResponder: Bool {
        return true
    }

    @objc public func spacePressed(_ command: UIKeyCommand) {
        print("Access Switch: Space pressed")
        self.keyboardSpacebarTimer.invalidate()
        self.keyboardSpacebarTimer = Timer.scheduledTimer(timeInterval: self.accessSwitchInterval,
                                                          target: self,
                                                          selector: #selector(DeviceViewController.stopAction),
                                                          userInfo: nil,
                                                          repeats: false)
        self.mBot.setServo(.port4, value: self.servoOn)
    }

    @objc public func enterPressed(_ command: UIKeyCommand) {
        print("Access Switch: Enter pressed")
        self.keyboardTimer.invalidate()
        self.scanning = false
        self.keyboardTimer = Timer.scheduledTimer(timeInterval: self.accessSwitchInterval,
                                                  target: self,
                                                  selector: #selector(DeviceViewController.stopBot),
                                                  userInfo: nil,
                                                  repeats: false)

        self.activateCurrentDirectionButton(self)
    }
}
