//
//  Period+CoreDataProperties.swift
//  Status bar screen activity timer
//
//  Created by Павло Сливка on 23.05.21.
//  Copyright © 2021 Павло Сливка. All rights reserved.
//
//

import Foundation
import CoreData


extension Period {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Period> {
        return NSFetchRequest<Period>(entityName: "Period")
    }

    @NSManaged public var offTime: NSDate?
    @NSManaged public var onTime: NSDate?

}
