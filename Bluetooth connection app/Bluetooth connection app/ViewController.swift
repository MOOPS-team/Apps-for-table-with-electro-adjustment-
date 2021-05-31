//
//  ViewController.swift
//  Bluetooth connection app
//
//  Created by Павло Сливка on 05.04.21.
//  Copyright © 2021 Павло Сливка. All rights reserved.
//

import Cocoa
import CoreBluetooth
import AppKit
//let services = CBUUID(string: "C8A680C6-98D3-4EC7-9EBE-E36BD5BD16E6")
//let services2 = CBUUID(string: "89A4E034-07AB-46F1-896F-318568021418")

class ViewController: NSViewController, CBPeripheralDelegate, CBCentralManagerDelegate {
    
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!
    private var characteristicForWriting: CBCharacteristic!
    
    @IBOutlet var fieldForMessage: NSTextField!
    
    @IBOutlet var displayWithActivity: NSTextField!
    
    @IBAction func sendButton(_ sender: Any) {
        let message = fieldForMessage.stringValue
        fieldForMessage.stringValue = ""
        
        let data = message.data(using: .utf8)!
        peripheral?.writeValue(data, for: characteristicForWriting, type: CBCharacteristicWriteType(rawValue: 0)!)
        
    }
    
    
    func printActivity(_ messageStr: String){
//        print(messageStr)
        displayWithActivity?.stringValue = messageStr
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        centralManager = CBCentralManager(delegate: self, queue: nil)
        view.layer?.backgroundColor = NSColor.gray.cgColor
    }
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            //print("central.state is .poweredOff")
            //print("Turn bluetooth on!")
            displayWithActivity.stringValue = "Turn bluetooth on!"
        case .poweredOn:
            //print("central.state is .poweredOn")
            displayWithActivity.stringValue = "Bluetooth is turned on"
            centralManager.scanForPeripherals(withServices: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral, RSSI)
        self.peripheral = peripheral
        peripheral.delegate = self
        centralManager.stopScan()
        centralManager.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        //print("Connected!")
        displayWithActivity.stringValue = "Connected!"
        peripheral.discoverServices(nil)
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
}

extension ViewController{
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard peripheral.services != nil else {return}
        guard let services = peripheral.services else {return}
        
        for service in services{
            print(service)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {return}
        
        for characteristic in characteristics{
            print(characteristic)
            if characteristic.properties.contains(.read) {
                print("\(characteristic.uuid): properties contains .read")
                peripheral.readValue(for: characteristic)
            }
            if characteristic.properties.contains(.notify) {
                print("\(characteristic.uuid): properties contains .notify")
            }
            if characteristic.properties.contains(.write) {
                print("\(characteristic.uuid): properties contains .write")
                characteristicForWriting = characteristic
                
//                let messageString = "Hello World"
//                let data = messageString.data(using: .utf8)!
//                peripheral.writeValue(data, for: characteristic, type: CBCharacteristicWriteType(rawValue: 0)!)
            }
        }
//        NSWorkspace.willSleepNotification
        
    }
    
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
//        let messageString = "Hello World!"
//        let data = messageString.data(using: .utf8)!
//
//        peripheral.writeValue(data, for: characteristic)
//    }
}
