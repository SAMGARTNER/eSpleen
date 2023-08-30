//
//  Proof.swift
//  eSpleen
//
//  Created by Samir Augusto Gartner Arias on 21/10/15.
//  Copyright © 2015 Samir Gartner. All rights reserved.
//

import Foundation
import CoreData

class Proof: NSManagedObject {

    
    @NSManaged var data: Data?
    @NSManaged var name: String?
    @NSManaged var type: String?
    @NSManaged var urlPath: String?
    @NSManaged var point: Point?
// Insert code here to add functionality to your managed object subclass

}
