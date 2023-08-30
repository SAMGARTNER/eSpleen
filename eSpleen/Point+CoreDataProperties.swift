//
//  Point+CoreDataProperties.swift
//  
//
//  Created by Samir Augusto Gartner Arias on 21/10/15.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Point {

    
    @NSManaged var id: String?
    @NSManaged var creationDate: NSDate
    @NSManaged var modificationDate: NSDate
}
