//
//  PeripheralMenuController.swift
//  Bluetooth connection app
//
//  Created by Павло Сливка on 08.12.2021.
//  Copyright © 2021 Павло Сливка. All rights reserved.
//

import Cocoa

extension ViewController: NSCollectionViewDelegate, NSCollectionViewDataSource {
    
    func setupCollectionView() {
        peripheralsMenuCollectionView.delegate = self
        peripheralsMenuCollectionView.dataSource = self
    }
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return foundPeripherals.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let menuItem = collectionView.makeItem(withIdentifier: PeripheralMenuItem.reuseIdentfier, for: indexPath) as! PeripheralMenuItem
        let setIndex = foundPeripherals.index(foundPeripherals.startIndex, offsetBy: indexPath.item)
        
        if foundPeripherals.indices.contains(setIndex) {
            menuItem.peripheralNameLabel.stringValue = foundPeripherals[setIndex].name ?? "unknown"
            if foundPeripherals[setIndex] != peripheral {
                menuItem.peripheralConnectionStatus.isHidden = true
            }
        }
        return menuItem
    }
    
    
}
