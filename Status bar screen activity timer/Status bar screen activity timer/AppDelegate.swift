//
//  AppDelegate.swift
//  Status bar screen activity timer
//
//  Created by Павло Сливка on 09.05.21.
//  Copyright © 2021 Павло Сливка. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var viewController: ViewController!


    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    
    let popover = NSPopover()
    var period: Period?
    
    struct TempPeriod {
        var onTime: Date
        var offTime: Date
        
        init(onTime: Date, offTime: Date) {
            self.onTime = onTime
            self.offTime = offTime
        }
    }
    
    var tempPeriod = TempPeriod(onTime: Date(), offTime: Date())
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("StatusBarButtonImage"))
            button.action = #selector(AppDelegate.togglePopover)
        }
        
        
        popover.animates = false
        popover.contentViewController = ViewController.freshViewController()
        popover.behavior = .transient
        
        
//        deleteAllData("Period")

        tempPeriod.onTime = Date()
        
        
        self.viewController = ViewController()
        sittingTimer(setup: true)

        // MARK: - Screen saver detection
        
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(sleepListener(_:)),
                                                          name: NSWorkspace.willSleepNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(sleepListener(_:)),
                                                          name: NSWorkspace.didWakeNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(sleepListener(_:)),
                                                          name: NSWorkspace.screensDidSleepNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(sleepListener(_:)),
                                                          name: NSWorkspace.screensDidWakeNotification, object: nil)
        
    }
    
    @objc func sittingTimer(setup: Bool = false) {
        
        var timerSec = 5
        
        if(!setup) {
            timerSec = viewController.getCurrentSittingTime()
        }

        _ = Timer.scheduledTimer(timeInterval: TimeInterval(timerSec), target: self, selector: #selector(standingTimer), userInfo: nil, repeats: false)
        showPopover(sender: nil)
    }
    
    @objc func standingTimer() {
        let timerSec = viewController.getCurrentStandingTime()
        
        _ = Timer.scheduledTimer(timeInterval: TimeInterval(timerSec), target: self, selector: #selector(sittingTimer), userInfo: nil, repeats: false)
        showPopover(sender: nil)
    }
    
    
    func deleteAllData(_ entity:String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try persistentContainer.viewContext.fetch(fetchRequest)
            for object in results {
                guard let objectData = object as? NSManagedObject else {continue}
                persistentContainer.viewContext.delete(objectData)
            }
        } catch let error {
            print("Detele all data in \(entity) error :", error)
        }
    }
    
    @objc private func sleepListener(_ aNotification: Notification) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let currentTime = formatter.string(from: Date())
        
//        self.viewController = ViewController()
        
        
        if aNotification.name == NSWorkspace.screensDidSleepNotification{
            
            tempPeriod.offTime = Date()
            
            let context = persistentContainer.viewContext
            period = Period(context: context)
            period?.onTime = tempPeriod.onTime
            period?.offTime = tempPeriod.offTime
            
            saveAction(nil)
            
            viewController.getPeriods()
            
            print(currentTime, "- screen is asleep")
            
        } else if aNotification.name == NSWorkspace.screensDidWakeNotification{
            
//            period?.onTime = Date()
//            saveAction(nil)
//
//            viewController.getPeriods()
            print(currentTime, "- screen is awake")
            viewController.getPeriods()
        }
    }
    
//    func storeTime(date: Date, on: Bool) {
//        if on {
//           period?.onTime = date
//
//            saveAction(nil)
//            self.viewController = ViewController()
//            viewController.doVCStuff(period: period!)
//            period = nil
//        } else {
//            period?.offTime = date
//
//
//
//        }
//
//
//        var periods = viewController.periods
//
//        periods.append(period)
//        
        
//    }


    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    
    @objc func togglePopover(_ sender: Any?) {
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }
    
    func showPopover(sender: Any?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            
//            self.viewController = ViewController()
//            viewController.getPeriods()
        }
    }
    
    func closePopover(sender: Any?) {
        popover.performClose(sender)
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Status_bar_screen_activity_timer")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving and Undo support

    @IBAction func saveAction(_ sender: AnyObject?) {
        // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
        let context = persistentContainer.viewContext

        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing before saving")
        }
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Customize this code block to include application-specific recovery steps.
                let nserror = error as NSError
                NSApplication.shared.presentError(nserror)
            }
        }
    }

    func windowWillReturnUndoManager(window: NSWindow) -> UndoManager? {
        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        return persistentContainer.viewContext.undoManager
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        // Save changes in the application's managed object context before the application terminates.
        let context = persistentContainer.viewContext
        
        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing to terminate")
            return .terminateCancel
        }
        
        if !context.hasChanges {
            return .terminateNow
        }
        
        do {
            try context.save()
        } catch {
            let nserror = error as NSError

            // Customize this code block to include application-specific recovery steps.
            let result = sender.presentError(nserror)
            if (result) {
                return .terminateCancel
            }
            
            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButton(withTitle: quitButton)
            alert.addButton(withTitle: cancelButton)
            
            let answer = alert.runModal()
            if answer == .alertSecondButtonReturn {
                return .terminateCancel
            }
        }
        // If we got here, it is time to quit.
        return .terminateNow
    }

}

