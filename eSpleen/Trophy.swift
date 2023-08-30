//
//  Trophy.swift
//  iKeepScore
//
//  Created by Samir Augusto Gartner Arias on 17/12/14.
//  Copyright (c) 2014 Samir Gartner. All rights reserved.
//

import Foundation
import CoreData

class Trophy: NSManagedObject {

    @NSManaged var approved: Bool
    @NSManaged var creationDate: Date?
    @NSManaged var groupTrophy: Bool
    @NSManaged var id: String?
    @NSManaged var name: NSString?
    @NSManaged var picture: Data?
    @NSManaged var score: NSNumber?
    @NSManaged var files: File?
    @NSManaged var participations: NSSet?
    @NSManaged var points: NSSet?
    

}
