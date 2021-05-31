//
//  ViewController.swift
//  Status bar screen activity timer
//
//  Created by Павло Сливка on 09.05.21.
//  Copyright © 2021 Павло Сливка. All rights reserved.
//

import Cocoa


class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var timeCounter: NSTextField!
    @IBOutlet var sittingTime: NSPopUpButton!
    @IBOutlet var standingTime: NSPopUpButton!
    
    var periods: [Period] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        
        let titles = getTitlesWithSeconds().0
        
        sittingTime.removeAllItems()
        sittingTime.addItems(withTitles: titles)
        
        standingTime.removeAllItems()
        standingTime.addItems(withTitles: titles)
        
        getPeriods()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func sittingTimeChange(_ sender: Any) {
        
        let timerSec = getCurrentSittingTime()
        
    }
    
    @IBAction func standingTimeChange(_ sender: Any) {
    }
    
    func getCurrentSittingTime() -> Int {
        
        let seconds = getTitlesWithSeconds().1
        let index = sittingTime.indexOfSelectedItem
        let timerSec = seconds[index]
        return timerSec

    }
    
    func getCurrentStandingTime() -> Int {
        
        let seconds = getTitlesWithSeconds().1
        let index = standingTime.indexOfSelectedItem
        let timerSec = seconds[index]
        return timerSec
        
    }
    
    func getTitlesWithSeconds() -> ([String], [Int]) {
        var titles = [String]()
        var seconds = [Int]()
        
        titles.append("    5s")
        seconds.append(5)
        
        for minutes in stride(from: 5, through: 55, by: 5) {
            titles.append("    \(minutes)m")
            seconds.append(minutes * 60)
        }
        
        for hours in 1...2 {
            for minutes in stride(from: 0, through: 59, by: 30) {
                if minutes == 0 {
                    titles.append("\(hours)h")
                    seconds.append(hours * 3600)
                } else {
                    titles.append("\(hours)h \(minutes)m")
                    seconds.append(hours * 3600 + minutes * 60)
                }
            }
        }
        
        titles.append("3h")
        seconds.append(3 * 3600)
        
        return (titles, seconds)
    }
    
//    func storeTimeDifference(timeDifference: DateComponents) {
//
//
//        let calendar = Calendar(identifier: .gregorian)
//        let dateDifference = calendar.date(from: timeDifference)
//
//        if let context = (NSApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
//
//            do {
//                let time = try context.fetch(Time.fetchRequest()) as [Time]
//            } catch {}
//
//            let previousTime = time.previousTime
//
//        }
//    }
    
    //MARK: - TableView Stuff
    func numberOfRows(in tableView: NSTableView) -> Int {
        return periods.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let period = periods[row]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        
        if((tableColumn?.identifier)!.rawValue == "onTimeColumn") {

            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "onTimeCell"), owner: self) as? NSTableCellView {

                if (period.onTime != nil){
                    cell.textField?.stringValue = formatter.string(from: period.onTime! as Date)
                }

                return cell;

            }
        } else {
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "offTimeCell"), owner: self) as? NSTableCellView {
                
                if period.offTime != nil {
                    cell.textField?.stringValue = formatter.string(from: period.offTime! as Date)
                }
                return cell;
                
            }
        }
        
        return nil
    }
    
    func getPeriods() {
        if let context = (NSApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            if let name = Period.entity().name {
                let fetchRequest = NSFetchRequest<Period>(entityName: name)
                if let periods = try? context.fetch(fetchRequest) {
                    self.periods = periods
                
                    if let summOfPeriods = findSummOfPeriods(periods: periods){
                        let formatter = DateFormatter()
                        formatter.dateFormat = "HH:mm:ss"
                        timeCounter.stringValue = formatter.string(from: summOfPeriods)
                    }

//                    for period in periods {
//                        let componentDiff = findTimeDifference(firstTime: period.onTime!, secondTime: period.offTime!)
//                        let dateDiff = Calendar.current.date(from: componentDiff)
//                        let currentSummOfPeriods = Calendar.current.date(byAdding: componentDiff, to: summOfPeriods)
//                    }
                }
            }
            
            tableView?.reloadData()
        }
    }
    
    func findSummOfPeriods (periods: [Period]) -> Date?{
        var compDifferences: [DateComponents] = []
        var summOfPeriods: Date?
        
        for period in periods {
            let componentDiff = findTimeDifference(firstTime: period.onTime!, secondTime: period.offTime!)
            print(componentDiff)
            compDifferences.append(componentDiff)
        }
        
        if periods.count > 1 {
            let currentDateDiff = Calendar.current.date(from: compDifferences[0])
            print("first diff - \(currentDateDiff!)")
            summOfPeriods = Calendar.current.date(byAdding: compDifferences[1], to: currentDateDiff!)
            print("first summ - \(summOfPeriods!)")
            
            for i in 1..<(compDifferences.count) {
                summOfPeriods = Calendar.current.date(byAdding: compDifferences[i], to: summOfPeriods!)
            }
        }
        
        return summOfPeriods
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

extension ViewController {
    
    static func freshViewController() -> ViewController {
        
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        
        let identifier = NSStoryboard.SceneIdentifier(rawValue: "ViewController")
        
        guard let viewController = storyboard.instantiateController(withIdentifier: identifier) as? ViewController
            else {
                fatalError("Why can't i find ViewController? - Check Main.storyboard")
        }
        
        return viewController
    }
}


func findTimeDifference(firstTime: Date, secondTime: Date) -> DateComponents {
    let diffComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: firstTime, to: secondTime)
    
    let formatter = DateFormatter()
    formatter.dateFormat = "dd"
    let dayFirst = formatter.string(from: firstTime)
    let daySecond = formatter.string(from: secondTime)
    if (dayFirst != daySecond) {
        // if session goes through 12pm
    }
//    let hours = diffComponents.hour
//    let minutes = diffComponents.minute
//    let seconds = diffComponents.second
    return diffComponents
}
