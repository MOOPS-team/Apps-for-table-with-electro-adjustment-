//
//  StepperTriangle.swift
//  Bluetooth connection app
//
//  Created by Павло Сливка on 05.12.2021.
//  Copyright © 2021 Павло Сливка. All rights reserved.
//

import Cocoa

class StepperLeftTriangle: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let path = NSBezierPath()
        path.move(to: CGPoint(x: 0, y: 7.5))
        path.line(to: CGPoint(x: 16.5, y: 0))
        path.line(to: CGPoint(x: 16.5, y: 15))
        path.close()
        NSColor(red: 0.773, green: 0.792, blue: 1, alpha: 1).set()
        path.fill()
    }
    
}
