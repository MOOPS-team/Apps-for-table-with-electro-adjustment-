//
//  BackgroundSection.swift
//  Bluetooth connection app
//
//  Created by Павло Сливка on 03.12.2021.
//  Copyright © 2021 Павло Сливка. All rights reserved.
//

import Cocoa

class BackgroundSection: NSView {

    override var wantsUpdateLayer: Bool {
        return true
    }
    
    override func updateLayer() {
        layer?.backgroundColor = NSColor(red: 0.469, green: 0.488, blue: 0.658, alpha: 1).cgColor
        layer?.cornerRadius = 15
    }
    
}
