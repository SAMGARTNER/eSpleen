//
//  Player+CoreDataProperties.swift
//  
//
//  Created by Samir Augusto Gartner Arias on 22/10/15.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Player {


    @NSManaged var googlePlusID: String?
    @NSManaged var id: String?
    @NSManaged var mixiID: String?
    @NSManaged var weiboID: String?
    @NSManaged var creationDate: NSDate
    @NSManaged var modificationDate: NSDate
    @NSManaged var mobageID: NSString?
}
