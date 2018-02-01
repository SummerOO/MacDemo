//
//  ViewController.swift
//  MacDemo
//
//  Created by zr on 2018/1/18.
//  Copyright © 2018年 ZR. All rights reserved.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController {
    
    @IBOutlet weak var timeTextField: NSTextField!
    
    @IBOutlet weak var eggImageView: NSImageCell!
  
    @IBOutlet weak var startButton: NSButton!
    
    @IBOutlet weak var stopButton: NSButtonCell!
    
    @IBOutlet weak var reSetButton: NSButtonCell!
    
    var eggTimer = EggTimer()
    
    var prefs = Preferences()
    
    var soundPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eggTimer.delegate = self
        setupPrefs()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func startAction(_ sender: Any) {
        if eggTimer.isPaused {
            eggTimer.resumeTimer()
        } else {
            eggTimer.duration = prefs.selectedTime
            eggTimer.startTimer()
        }
        configureButtonsAndMenus()
        prepareSound()
    }
    @IBAction func stopAction(_ sender: Any) {
        eggTimer.stopTimer()
        configureButtonsAndMenus()
    }
    @IBAction func resetAction(_ sender: Any) {
        eggTimer.resetTimer()
        updateDisplay(for: prefs.selectedTime)
        configureButtonsAndMenus()
    }
    
    // MARK: - IBActions - menus
    @IBAction func startTimerMenuItemSelected(_ sender: Any) {
        startAction(sender)
    }
    
    @IBAction func stopTimerMenuItemSelected(_ sender: Any) {
        stopAction(sender)
    }
    
    @IBAction func resetTimerMenuItemSelected(_ sender: Any) {
        resetAction(sender)
    }
}

extension ViewController: EggTimerProtocol {
    func timeRemainingOnTimer(_ timer: EggTimer, timeRemaining: TimeInterval) {
        updateDisplay(for: timeRemaining)
    }
    
    func timerHasFinished(_ timer: EggTimer) {
        updateDisplay(for: 0)
        playSound()
    }
 
}

extension ViewController {
    
    // MARK: - 显示
    func updateDisplay(for timeRemaining: TimeInterval) {
        timeTextField.stringValue = textToDisplay(for: timeRemaining)
        eggImageView.image = imageToDisplay(for: timeRemaining)
    }
    
    private func textToDisplay(for timeRemaining: TimeInterval) -> String {
        if timeRemaining == 0 {
            return "Done!"
        }
        
        let minutesRemaining = floor(timeRemaining / 60)
        let secondsRemaining = timeRemaining - (minutesRemaining * 60)
        
        let secondsDisplay = String(format: "%02d", Int(secondsRemaining))
        let timeRemainingDisplay = "\(Int(minutesRemaining)):\(secondsDisplay)"
        
        return timeRemainingDisplay
    }
    
    private func imageToDisplay(for timeRemaining: TimeInterval) -> NSImage? {
        let percentageComplete = 100 - (timeRemaining / prefs.selectedTime * 100)
        
        if eggTimer.isStopped {
            let stoppedImageName = (timeRemaining == 0) ? "100" : "stopped"
            return NSImage(named: NSImage.Name(rawValue: stoppedImageName))
        }
        
        let imageName: String
        switch percentageComplete {
        case 0 ..< 25:
            imageName = "0"
        case 25 ..< 50:
            imageName = "25"
        case 50 ..< 75:
            imageName = "50"
        case 75 ..< 100:
            imageName = "75"
        default:
            imageName = "100"
        }
        
        return NSImage(named: NSImage.Name(rawValue: imageName))
    }
    
    func configureButtonsAndMenus() {
        let enableStart: Bool
        let enableStop:  Bool
        let enableReset: Bool
        
        if eggTimer.isStopped {
            enableStart = true
            enableStop  = false
            enableReset = false
        } else if eggTimer.isPaused {
            enableStart = true
            enableStop  = false
            enableReset = true
        } else {
            enableStart = false
            enableStop  = true
            enableReset = false
        }
        
        startButton.isEnabled = enableStart
        stopButton.isEnabled  = enableStop
        reSetButton.isEnabled = enableReset
        
        if let appDel = NSApplication.shared.delegate as? AppDelegate {
            appDel.enableMenus(start: enableStart, stop: enableStop, reset: enableReset)
        }
    }
    
}

extension ViewController {
    
    // MARK: - 设置
    func setupPrefs() {
        updateDisplay(for: prefs.selectedTime)
        
        let notificationName = Notification.Name(rawValue: "PrefsChanged")
        NotificationCenter.default.addObserver(forName: notificationName,
                                               object: nil, queue: nil) {
                                                (notification) in
                                                self.checkForResetAfterPrefsChange()
        }
    }
    
    func updateFromPrefs() {
        self.eggTimer.duration = self.prefs.selectedTime
        self.resetAction(self)
    }
    
    func checkForResetAfterPrefsChange() {
        if eggTimer.isStopped || eggTimer.isPaused {
            // 1
            updateFromPrefs()
        } else {
            // 2
            let alert = NSAlert()
            alert.messageText = "Reset timer with the new settings?"
            alert.informativeText = "This will stop your current timer!"
            alert.alertStyle = .warning
            
            // 3
            alert.addButton(withTitle: "Reset")
            alert.addButton(withTitle: "Cancel")
            
            // 4
            let response = alert.runModal()
            if response == NSApplication.ModalResponse.alertFirstButtonReturn {
                self.updateFromPrefs()
            }
        }
    }
    
}

extension ViewController {
    
    // MARK: - 声音
    
    func prepareSound() {
        guard let audioFileUrl = Bundle.main.url(forResource: "ding",
                                                 withExtension: "mp3") else {
                                                    return
        }
        do {
            soundPlayer = try AVAudioPlayer(contentsOf: audioFileUrl)
            soundPlayer?.prepareToPlay()
        } catch {
            print("Sound player not available: \(error)")
        }
    }
    
    func playSound() {
        soundPlayer?.play()
    }
    
}

