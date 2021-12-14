//
//  ReusableView.swift
//  Bluetooth connection app
//
//  Created by Павло Сливка on 04.12.2021.
//  Copyright © 2021 Павло Сливка. All rights reserved.
//

import Cocoa

@IBDesignable class ReusableView: NSView {

    @IBInspectable var backgroundColor: NSColor? {
        didSet { needsDisplay = true }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet { needsDisplay = true }
    }
    
    override var wantsUpdateLayer: Bool {
        return true
    }
    
    override func updateLayer() {
        layer?.backgroundColor = backgroundColor?.cgColor
        layer?.cornerRadius = cornerRadius
    }
    
}
