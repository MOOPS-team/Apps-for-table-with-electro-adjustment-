//
//  PeripheralMenuItem.swift
//  Bluetooth connection app
//
//  Created by Павло Сливка on 08.12.2021.
//  Copyright © 2021 Павло Сливка. All rights reserved.
//

import Cocoa

class PeripheralMenuItem: NSCollectionViewItem {
    @IBOutlet var peripheralNameLabel: NSTextField!
    @IBOutlet var peripheralConnectionStatus: ReusableView!
    
    static let reuseIdentfier = NSUserInterfaceItemIdentifier("PeripheralMenuItem")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
