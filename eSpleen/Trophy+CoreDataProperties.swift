//
//  Trophy+CoreDataProperties.swift
//  eSpleen
//
//  Created by Samir Augusto Gartner Arias on 21/10/15.
//  Copyright © 2015 Samir Gartner. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Trophy {


    @NSManaged var type: NSString
    @NSManaged var modificationDate: NSDate
    @NSManaged var substracts: Bool
}
