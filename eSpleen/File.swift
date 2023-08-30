//
//  File.swift
//  iKeepScore
//
//  Created by Samir Augusto Gartner Arias on 17/12/14.
//  Copyright (c) 2014 Samir Gartner. All rights reserved.
//

import Foundation
import CoreData

class File: NSManagedObject {

    @NSManaged var data: Data?
    @NSManaged var name: NSString?
    @NSManaged var type: NSString?
    @NSManaged var urlPath: NSString?
    @NSManaged var trophy: Trophy?

}
