//
//  Match.swift
//  iKeepScore
//
//  Created by Samir Augusto Gartner Arias on 17/12/14.
//  Copyright (c) 2014 Samir Gartner. All rights reserved.
//

import Foundation
import CoreData

class Match: NSManagedObject {

    @NSManaged var creationDate: Date?
    @NSManaged var id: NSString?
    @NSManaged var initialScore: Int32
    @NSManaged var name: NSString?
    @NSManaged var scoreAdds: Bool
    @NSManaged var participants: NSSet?

}
