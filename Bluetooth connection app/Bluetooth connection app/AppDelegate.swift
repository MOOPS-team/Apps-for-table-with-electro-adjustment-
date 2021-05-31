//
//  AppDelegate.swift
//  Bluetooth connection app
//
//  Created by Павло Сливка on 05.04.21.
//  Copyright © 2021 Павло Сливка. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var activityLog: String = ""
    var VC = ViewController()


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(sleepListener(_:)),
                                                          name: NSWorkspace.willSleepNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(sleepListener(_:)),
                                                          name: NSWorkspace.didWakeNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(sleepListener(_:)),
                                                          name: NSWorkspace.screensDidSleepNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(sleepListener(_:)),
                                                          name: NSWorkspace.screensDidWakeNotification, object: nil)
    }
    
    
    @objc private func sleepListener(_ aNotification: Notification) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let currentTime = formatter.string(from: Date())
        
        if aNotification.name == NSWorkspace.willSleepNotification {
            print(currentTime, "- going to sleep")
        } else if aNotification.name == NSWorkspace.didWakeNotification {
            print(currentTime, "- woke up")
        } else if aNotification.name == NSWorkspace.screensDidSleepNotification{
//            activityLog += currentTime + " fall asleep\n"
//            VC.printActivity(activityLog)
            print(currentTime, "- screen is asleep")
        } else if aNotification.name == NSWorkspace.screensDidWakeNotification{
//            activityLog += currentTime + " wake up\n"
//            VC.printActivity(activityLog)
            print(currentTime, "- screen is awake")
        } else{
            print("Unknown notification")
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    

}

