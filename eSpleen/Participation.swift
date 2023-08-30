//
//  Participation.swift
//  iKeepScore
//
//  Created by Samir Augusto Gartner Arias on 17/12/14.
//  Copyright (c) 2014 Samir Gartner. All rights reserved.
//

import Foundation
import CoreData

class Participation: NSManagedObject {

    @NSManaged var corner: NSString?
    @NSManaged var match: Match
    @NSManaged var player: Player
    @NSManaged var trophies: NSSet

}
