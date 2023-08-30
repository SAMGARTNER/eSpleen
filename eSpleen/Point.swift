//
//  Point.swift
//  
//
//  Created by Samir Augusto Gartner Arias on 21/10/15.
//
//

import Foundation
import CoreData

class Point: NSManagedObject {
    
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var timeStamp: Date?
    @NSManaged var proofs: Proof?
    @NSManaged var trophy: Trophy?
}
