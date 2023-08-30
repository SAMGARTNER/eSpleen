//
//  MixiContact.swift
//  eSpleen
//
//  Created by Samir Augusto Gartner Arias on 12/10/15.
//  Copyright © 2015 Samir Gartner. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

class MixiContact: NSManagedObject {

    @NSManaged var username: String?
    @NSManaged var picture: Data?
    @NSManaged var phone_number: String?
    @NSManaged var name: String?
    @NSManaged var middle_name: String?
    @NSManaged var list_type: String?
    @NSManaged var last_name: String?
    @NSManaged var invited: NSNumber?
    @NSManaged var id: String?
    @NSManaged var hasTheApp: NSNumber?
    @NSManaged var first_name: String?
    @NSManaged var email: String?
    @NSManaged var checksum: String?
    @NSManaged var creationDate: Date
    @NSManaged var modificationDate: Date

}
