//
//  ParticipationPlusCoreData.swift
//  iKeepScore
//
//  Created by Samir Augusto Gartner Arias on 14/12/14.
//  Copyright (c) 2014 Samir Gartner. All rights reserved.
//

import Foundation

extension Participation {
    @NSManaged var creationDate: NSDate?
    
    func addTrophyObject(value:Trophy) {
        let items = self.mutableSetValue(forKey: "trophies")
        items.add(value)
    }
    
    func removeTrophyObject(value:Trophy) {
        let items = self.mutableSetValue(forKey: "trophies")
        items.remove(value)
    }
}
