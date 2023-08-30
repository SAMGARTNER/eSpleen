//
//  Player.swift
//  iKeepScore
//
//  Created by Samir Augusto Gartner Arias on 17/12/14.
//  Copyright (c) 2014 Samir Gartner. All rights reserved.
//

import Foundation
import CoreData

class Player: NSManagedObject {

    @NSManaged var abID: NSString?
    @NSManaged var facebookID: NSString?
    @NSManaged var forenames: NSString?
    @NSManaged var gamecenterID: NSString?
    @NSManaged var nameHash: NSString?
    @NSManaged var picture: Data?
    @NSManaged var surenames: NSString?
    @NSManaged var twitterID: NSString?
    @NSManaged var participations: NSSet?

}
