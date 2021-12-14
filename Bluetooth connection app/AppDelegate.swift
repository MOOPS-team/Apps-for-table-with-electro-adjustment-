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
    
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    let popover = NSPopover()


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        // popover setup
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("StatusBarButtonImage"))
            button.action = #selector(togglePopover)
        }
        
        popover.animates = false
        popover.contentViewController = ViewController.freshViewController()
        popover.behavior = .transient
//        popover.contentViewController?.view.layer?.borderColor = .clear
        
        
        // screen activity tracking setup
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
    
    @objc func togglePopover(_ sender: Any?) {
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }

        //make popover remain on the same place after menubar is hidden in full screen mode
        if let popoverWindow = popover.contentViewController?.view.window {
            popoverWindow.parent?.removeChildWindow(popoverWindow)
        }
    }
    
    func showPopover(sender: Any?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }
    
    func closePopover(sender: Any?) {
        popover.performClose(sender)
    }
    
    

}

