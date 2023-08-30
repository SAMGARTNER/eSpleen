//
//  IKSDBManager.swift
//  iKeepScore
//
//  Created by Samir Augusto Gartner Arias on 7/12/14.
//  Copyright (c) 2014 Samir Gartner. All rights reserved.
//

import UIKit
import Foundation
import CoreData
//import FirebaseDatabase
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class IKSDBManager: NSObject
{
    
    var deletionCicleStartDate:Date? = nil
    var syncCicleStartDate:Date? = nil
    var matchesSortDescriptor:NSSortDescriptor?
    //var eSpleenRef: DatabaseReference!
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "co.bucle.iKeepScore" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] as URL
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "eSpleen", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("iKeepScore.sqlite")
        
        var failureReason = "There was an error creating or loading the application's saved data."
        let mOptions = [NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true]
        do {
            try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: mOptions)
        } catch let error1 as NSError {
            //error = error1
            coordinator = nil
            // Report any error we got.
            let descriptionKey = "Failed to initialize the application's saved data"
            let dict:[AnyHashable: Any] = [NSLocalizedDescriptionKey:descriptionKey, NSLocalizedFailureReasonErrorKey:failureReason, NSUnderlyingErrorKey:error1]
            var error: NSError? = nil
            //dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            //dict[NSLocalizedFailureReasonErrorKey] = failureReason
            //dict[NSUnderlyingErrorKey] = error
            //error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict as [[NSObject : AnyObject]])
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo:dict as? [String : Any] )
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error!), \(error!.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        //var managedObjectContext = NSManagedObjectContext()
        var managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        managedObjectContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        return managedObjectContext
        }()
    
    
    override init()
    {
    super.init()
        
    }
    
    func deleteMatch(_ theMatch:Match?)
    {
        
        
        var saveError:NSError?
        let matchID = theMatch?.id
        if self.managedObjectContext != nil
        {
            if theMatch != nil {
                if let participants = theMatch?.participants!.allObjects as? [Participation]
                {
            for aParticipant in participants
                {
                    if let trophies = aParticipant.trophies.allObjects as? [Trophy]
                    {
                        for aTrophy in trophies
                        {
                    // es necesario guardar despues de cada borrado, de lo contrario el delegado tumba la aplicacion
     
                    self.managedObjectContext?.delete(aTrophy)
                            do {
                                try managedObjectContext!.save()
                                if self.deletionCicleStartDate == nil
                                {
                                    self.deletionCicleStartDate = Date()
                                }
                            } catch let error as NSError {
                                saveError = error
                                NSLog("Unresolved error \(saveError!), \(saveError!.userInfo)")
                            }
                        }
                    }

                    self.managedObjectContext?.delete(aParticipant)
                    do {
                        try managedObjectContext!.save()
                    } catch let error as NSError {
                        saveError = error
                        NSLog("Unresolved error \(saveError!), \(saveError!.userInfo)")
                    }
                }
                        self.managedObjectContext?.delete(theMatch!)

                do {
                    try managedObjectContext!.save()
                    if self.deletionCicleStartDate == nil
                    {
                        self.deletionCicleStartDate = Date()
                    }
                    if matchID != nil
                    {
                        _ = self.storeDeletedObjectReferenceWithID(matchID! as String, type: "match", deletionDate: Date())
                        /*if FBSDKAccessToken.current() != nil{
                            //self.syncDataInFirebaseWithFacebookToken(FBSDKAccessToken.current())
                        }*/
                    }
                    
                } catch let error as NSError {
                    saveError = error
                    NSLog("Unresolved error \(saveError!), \(saveError!.userInfo)")
                }
            }
            }
        }
    }
    
    
    func deleteTrophy(_ theTrophy:Trophy?)
    {
        if self.managedObjectContext != nil
        {
            if theTrophy != nil
            {
            var saveError:NSError?
            let trophyID = theTrophy?.id
            /*var participations:NSArray? = theTrophy?.participations.allObjects
            var theTrophyMatch:Match = (participations?.objectAtIndex(0) as Participation).match
            var matchedTrophiesPredicate:NSPredicate = NSPredicate(format: "ANY trophies.name == %@", theTrophy!.name)!
            var searchResultArray:NSArray? = participations?.filteredArrayUsingPredicate(matchedTrophiesPredicate)
            if searchResultArray != nil
                {
                    for aTrophy in searchResultArray!
                        {*/
                for aParticipation in (theTrophy?.participations)!
                {
                    ((aParticipation as! Participation).player as Player).modificationDate = Date() as NSDate
                    ((aParticipation as! Participation).match as Match).modificationDate = Date() as NSDate
                }
                            self.managedObjectContext?.delete(theTrophy!)
            do {
                try managedObjectContext!.save()
                if self.deletionCicleStartDate == nil
                {
                    self.deletionCicleStartDate = Date()
                }
                if trophyID != nil
                {
                _ = self.storeDeletedObjectReferenceWithID(trophyID! as String, type: "trophy", deletionDate: Date())
                    
                    
                }
                
                
            } catch let error as NSError {
                saveError = error
                NSLog("Unresolved error \(saveError!), \(saveError!.userInfo)")
            }
                        /*}
                }*/
            }
        }
    }
    
    func getMatchesModifiedAfterDate(_ aDate:Date) -> NSArray
        {
            //if aDate != nil{
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
            let entity:NSEntityDescription? = NSEntityDescription.entity(forEntityName: "Match", in: self.managedObjectContext!)
            let modificationPredicate:NSPredicate = NSPredicate(format: "modificationDate > %@",aDate as CVarArg)
            fetchRequest.predicate = modificationPredicate
            fetchRequest.entity = entity
            let resultArray:NSArray = try! self.managedObjectContext!.fetch(fetchRequest) as NSArray
            for aMatch in resultArray
            {
                self.fillMatchEmptyOptionals(aMatch as! Match)
            }
            
            return resultArray
           
        }
    
    func getPlayersModifiedAfterDate(_ aDate:Date) -> NSArray
    {
        //if aDate != nil{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entity:NSEntityDescription? = NSEntityDescription.entity(forEntityName: "Player", in: self.managedObjectContext!)
        let modificationPredicate:NSPredicate = NSPredicate(format: "modificationDate > %@",aDate as CVarArg)
        fetchRequest.predicate = modificationPredicate
        fetchRequest.entity = entity
        let resultArray:NSArray = try! self.managedObjectContext!.fetch(fetchRequest) as NSArray
        for aPlayer in resultArray
        {
            self.fillPlayerEmptyOptionals(aPlayer as! Player)
        }
        
            return resultArray

    }
    
    func getFilesModifiedAfterDate(_ aDate:Date) -> NSArray
    {
        //if aDate != nil{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entity:NSEntityDescription? = NSEntityDescription.entity(forEntityName: "File", in: self.managedObjectContext!)
        let modificationPredicate:NSPredicate = NSPredicate(format: "modificationDate > %@",aDate as CVarArg)
        fetchRequest.predicate = modificationPredicate
        fetchRequest.entity = entity
        let resultArray:NSArray = try! self.managedObjectContext!.fetch(fetchRequest) as NSArray
        for aFile in resultArray
        {
            self.fillFileEmptyOptionals(aFile as! File)
        }
        
            return resultArray
        
    }
    
    func getTrophiesModifiedAfterDate(_ aDate:Date) -> NSArray
    {
        //if aDate != nil{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entity:NSEntityDescription? = NSEntityDescription.entity(forEntityName: "Trophy", in: self.managedObjectContext!)
        let modificationPredicate:NSPredicate = NSPredicate(format: "modificationDate > %@",aDate as CVarArg)
        fetchRequest.predicate = modificationPredicate
        fetchRequest.entity = entity
        let resultArray:NSArray = try! self.managedObjectContext!.fetch(fetchRequest) as NSArray
        for aTrophy in resultArray
        {
            self.fillTrophyEmptyOptionals(aTrophy as! Trophy)
        }
        //print("modified trophies",resultArray.count)
            return resultArray
       
    }
    
    func getPointsModifiedAfterDate(_ aDate:Date) -> NSArray
    {
        //if aDate != nil{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entity:NSEntityDescription? = NSEntityDescription.entity(forEntityName: "Point", in: self.managedObjectContext!)
        let modificationPredicate:NSPredicate = NSPredicate(format: "modificationDate > %@",aDate as CVarArg)
        fetchRequest.predicate = modificationPredicate
        fetchRequest.entity = entity
        let resultArray:NSArray = try! self.managedObjectContext!.fetch(fetchRequest) as NSArray
        for aPoint in resultArray
        {
            self.fillPointEmptyOptionals(aPoint as! Point)
        }
      
            return resultArray
     
    }
    
    func getProofsModifiedAfterDate(_ aDate:Date) -> NSArray
    {
        //if aDate != nil{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entity:NSEntityDescription? = NSEntityDescription.entity(forEntityName: "Proof", in: self.managedObjectContext!)
        let modificationPredicate:NSPredicate = NSPredicate(format: "modificationDate > %@",aDate as CVarArg)
        fetchRequest.predicate = modificationPredicate
        fetchRequest.entity = entity
        let resultArray:NSArray = try! self.managedObjectContext!.fetch(fetchRequest) as NSArray
        for aProof in resultArray
        {
            self.fillProofEmptyOptionals(aProof as! Proof)
        }
        
            return resultArray
     
    }
    
    func getParticipationsCreatedAfterDate(_ aDate:Date) -> NSArray
    {
        //if aDate != nil{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entity:NSEntityDescription? = NSEntityDescription.entity(forEntityName: "Participation", in: self.managedObjectContext!)
        let modificationPredicate:NSPredicate = NSPredicate(format: "creationDate > %@",aDate as CVarArg)
        fetchRequest.predicate = modificationPredicate
        fetchRequest.entity = entity
        let resultArray:NSArray = try! self.managedObjectContext!.fetch(fetchRequest) as NSArray
        for aParticipation in resultArray
        {
            self.fillParticipationEmptyOptionals(aParticipation as! Participation)
        }
       
            return resultArray
       
    }
    
    func createMatch() -> Match?
    {
        var saveError:NSError?
        if self.managedObjectContext != nil
        {
            let match:Match = NSEntityDescription.insertNewObject(forEntityName: "Match", into: self.managedObjectContext!) as! Match
            match.id = NSUUID().uuidString as NSString
            match.creationDate = Date()
            match.modificationDate = Date() as NSDate
            do {
                try managedObjectContext!.save()
                //println("Match Created")
                return match
                
            } catch let error as NSError {
                saveError = error
                NSLog("Unresolved error \(saveError!), \(saveError!.userInfo)")
            }
        }
    return nil
    }
    
    func addPlayer(_ player:Player, toMatch match:Match, corner:NSString) -> Participation?
    {
        let participant = NSEntityDescription.insertNewObject(forEntityName: "Participation", into: self.managedObjectContext!) as? Participation
        participant?.player = player
        participant?.match = match
        participant?.corner = corner
        participant?.creationDate = Date() as NSDate
        match.modificationDate = Date() as NSDate
        //match.participants = match.participants.setByAddingObject(participant!)
        var saveError:NSError?
        do {
            try managedObjectContext!.save()
        } catch let error as NSError {
            saveError = error
            NSLog("Unresolved error \(saveError!), \(saveError!.userInfo)")
            return nil
        }
        return participant!
    }
    
    func storeDeletedObjectReferenceWithID(_ objectID: String, type:String, deletionDate:Date) -> Bool
    {
        /*let deletedObject = self.createDeletedObjectReference()
        var saveError:NSError?
        deletedObject!.id = objectID
        deletedObject!.type = type
        deletedObject!.deletionDate = deletionDate
        
        do {
            try managedObjectContext!.save()
            
            return true
        } catch let error as NSError {
            saveError = error
            
        }
        
        NSLog("Unresolved error saving deleted object reference\(saveError), \(saveError!.userInfo)")
        return false*/
        return false
    }
    
    func addTrophy(_ trophy:Trophy?, toMatch match:Match?) -> Trophy?
    {
        var matchedParticipants:NSArray?
        var saveError:NSError?
    
        if trophy != nil && match != nil
        {
        matchedParticipants =  match!.participants!.allObjects as NSArray
        
            
        if matchedParticipants?.count == 2
        {
            let participantA:Participation = matchedParticipants?.object(at: 0) as! Participation
            let participantB:Participation = matchedParticipants?.object(at: 1) as! Participation
            
            
            let clonedTrophy = self.createTrophy()
            clonedTrophy?.creationDate = (trophy?.creationDate)!
            clonedTrophy?.modificationDate = (trophy?.modificationDate)!
            clonedTrophy?.setValue(trophy?.value(forKey: "name"), forKey: "name")
            participantA.addTrophyObject(value: trophy!)
            participantB.addTrophyObject(value: clonedTrophy!)
            match?.modificationDate = Date() as NSDate as NSDate
                
            do {
                try managedObjectContext!.save()
                    
                return trophy
            } catch let error as NSError {
                saveError = error
                NSLog("Unresolved error \(saveError!), \(saveError!.userInfo)")
            }
        }
        }
        
        
        
        return nil
    }
    
    func setPlayer(_ player:Player,id:String?, nameHash:String?, forenames:NSString?, surenames:NSString?, addressBookID:NSString?, facebookID:NSString?, googlePlusID: String?, twitterID:NSString?,gamecenterID: NSString?,mobageID: NSString?,mixiID: String? , weiboID: String?,picture:Data?) -> Player?
    {
    if id != nil && id != ""
        {
            player.id = id!
        }
    else
        {
            player.id = NSUUID().uuidString
        }
    if nameHash != nil
        {
            player.nameHash = nameHash! as NSString
        }
    else
        {
            player.nameHash = ""
        }
    if forenames != nil
        {
            player.forenames = forenames!
        }
    else
        {
            player.forenames = ""
        }
    if surenames != nil
        {
            player.surenames = surenames!
        }
    else
        {
            player.surenames = ""
        }
    if id != nil
        {
            player.abID = addressBookID!
        }
    else
        {
            player.abID = ""
        }
    if facebookID != nil
        {

            player.facebookID = facebookID!
        }
    else
        {
            
            player.facebookID = ""

        }
    if googlePlusID != nil
        {
            player.googlePlusID = googlePlusID!
        }
    else
        {
            player.googlePlusID = ""
        }
    if twitterID != nil
        {
            player.twitterID = twitterID!
        }
    else
        {
            player.twitterID = ""
        }
    if gamecenterID != nil
        {
            player.gamecenterID = gamecenterID!
        }
    else
        {
            player.gamecenterID = ""
        }
    if mobageID != nil
        {
            player.mobageID = mobageID!
        }
    else
        {
            player.mobageID = ""
        }
    if mixiID != nil
        {
            player.mixiID = mixiID!
        }
    else
        {
            player.mixiID = ""
        }
    if weiboID != nil
        {
            player.weiboID = weiboID!
        }
    else
        {
            player.weiboID = ""
        }
    if picture != nil
        {
            player.picture = picture!
        }
    else
        {
            player.weiboID = ""
        }
        
        player.modificationDate = Date() as NSDate
        
    var saveError:NSError?
    do {
        try managedObjectContext!.save()
    } catch let error as NSError {
        saveError = error
        NSLog("Unresolved error \(saveError!), \(saveError!.userInfo)")
        return nil
    }
    return self.getPlayerWithNameHash(nameHash)
    }
    
    func createPlayer() -> Player?
    {
        var saveError:NSError?
        //let player:Player? = NSEntityDescription.entity(forEntityName: "Player", in: self.managedObjectContext!) as? Player
        let player:Player? = Player(context: self.managedObjectContext!)
        
        player?.id = NSUUID().uuidString
        player?.creationDate = Date() as NSDate
        player?.modificationDate = Date() as NSDate
        do {
            try managedObjectContext!.save()
            NSLog("Player Created")
            print(player as Any)
            return player
        } catch let error as NSError {
            saveError = error
        }
       
        NSLog("Could not create player \(saveError!), \(saveError!.userInfo)")
        return nil
    }
    
    func createDeletedObjectReference() -> DeletedObject?
    {
        var saveError:NSError?
        let aObject:DeletedObject? = NSEntityDescription.insertNewObject(forEntityName: "DeletedObject", into: self.managedObjectContext!) as? DeletedObject
        do {
            try managedObjectContext!.save()
            return aObject
        } catch let error as NSError {
            saveError = error
        }
        
        NSLog("Unresolved error creating deleted object reference \(saveError!), \(saveError!.userInfo)")
        return nil
    }
    
    func createTrophy() -> Trophy?
    {
        var saveError:NSError?
        let trophy:Trophy? = NSEntityDescription.insertNewObject(forEntityName: "Trophy", into: self.managedObjectContext!) as? Trophy
        trophy!.id = NSUUID().uuidString
        trophy!.creationDate = Date()
        trophy!.modificationDate = Date() as NSDate as NSDate
        do {
            try managedObjectContext!.save()
            return trophy!
        } catch let error as NSError {
            saveError = error
        }
        
        NSLog("Unresolved error \(saveError!), \(saveError!.userInfo)")
        return nil
    }
    
    func getPlayerWithMatchingID(_ ABID:String?, FBID:String?, TWID:String?) -> Player?
    {
       let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entity:NSEntityDescription? = NSEntityDescription.entity(forEntityName: "Player", in: self.managedObjectContext!)
        //var requestError:NSError?
        
        //var FBIDPredicate:NSPredicate = NSPredicate(format: "twitterID = %@",FBID!)
        //var TWIDPredicate:NSPredicate = NSPredicate(format: "facebookID = %@",TWID!)
        
        //var predicatesArray:NSMutableArray = NSMutableArray()
        
        if ABID != nil {
            let ABIDPredicate:NSPredicate = NSPredicate(format: "abID = %@",ABID!)
            //predicatesArray.addObject(ABID!)
            fetchRequest.predicate = ABIDPredicate
            fetchRequest.entity = entity
            let ABIDResultArray:NSArray = try! self.managedObjectContext!.fetch(fetchRequest) as NSArray
            if ABIDResultArray.count > 0
            {
                self.fillPlayerEmptyOptionals((ABIDResultArray.object(at: 0) as? Player)!)
                return ABIDResultArray.object(at: 0) as? Player
            }
        }
        
        if FBID != nil {
            let FBIDPredicate:NSPredicate = NSPredicate(format: "facebookID = %@",FBID!)
            //predicatesArray.addObject(FBID!)
            fetchRequest.predicate = FBIDPredicate
            fetchRequest.entity = entity
            let FBIDResultArray:NSArray = try! self.managedObjectContext!.fetch(fetchRequest) as NSArray
            if FBIDResultArray.count > 0
            {
                return FBIDResultArray.object(at: 0) as? Player
            }
        }
        
        if TWID != nil {
            let TWIDPredicate:NSPredicate = NSPredicate(format: "twitterID = %@",TWID!)
            //predicatesArray.addObject(TWID!)
            fetchRequest.predicate = TWIDPredicate
            fetchRequest.entity = entity
            let TWIDResultArray:NSArray = try! self.managedObjectContext!.fetch(fetchRequest) as NSArray
            if TWIDResultArray.count > 0
            {
                return TWIDResultArray.object(at: 0) as? Player
            }
        }
        
        
        //var compoundPredicate:NSPredicate = NSCompoundPredicate.andPredicateWithSubpredicates(predicatesArray)
        //fetchRequest?.predicate = compoundPredicate
        return nil
    }
    
    func getPlayerWithNameHash(_ nameHash:String?) -> Player?
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entity:NSEntityDescription? = NSEntityDescription.entity(forEntityName: "Player", in: self.managedObjectContext!)
        //var requestError:NSError?
        
        if nameHash != nil
        {
            let nameHashPredicate = NSPredicate(format: "nameHash = %@",nameHash!)
            fetchRequest.predicate = nameHashPredicate
            fetchRequest.entity = entity
            let nameHashResultArray:NSArray = try! self.managedObjectContext!.fetch(fetchRequest) as NSArray
            if nameHashResultArray.count > 0
            {
                self.fillPlayerEmptyOptionals((nameHashResultArray.object(at: 0) as? Player)!)
                return nameHashResultArray.object(at: 0) as? Player
            }
        }
        return nil
    }
    
    func getPlayerWithUUID(_ UUID:String?) -> Player?
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entity:NSEntityDescription? = NSEntityDescription.entity(forEntityName: "Player", in: self.managedObjectContext!)
        //var requestError:NSError?
        
        if UUID != nil
        {
            let nameHashPredicate = NSPredicate(format: "id = %@",UUID!)
            fetchRequest.predicate = nameHashPredicate
            fetchRequest.entity = entity
            let nameHashResultArray:NSArray = try! self.managedObjectContext!.fetch(fetchRequest) as NSArray
            if nameHashResultArray.count > 0
            {
                self.fillPlayerEmptyOptionals((nameHashResultArray.object(at: 0) as? Player)!)
                return nameHashResultArray.object(at: 0) as? Player
            }
        }
        return nil
    }
    
    func getPlayerWithABID(_ ABID:String?) -> Player?
    {
        if ABID != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
            let entity:NSEntityDescription? = NSEntityDescription.entity(forEntityName: "Player", in: self.managedObjectContext!)
            let ABIDPredicate:NSPredicate = NSPredicate(format: "abID = %@",ABID!)
            //predicatesArray.addObject(ABID!)
            fetchRequest.predicate = ABIDPredicate
            fetchRequest.entity = entity
            let ABIDResultArray:NSArray = try! self.managedObjectContext!.fetch(fetchRequest) as NSArray
            if ABIDResultArray.count > 0
            {
                self.fillPlayerEmptyOptionals((ABIDResultArray.object(at: 0) as? Player)!)
                return ABIDResultArray.object(at: 0) as? Player
            }
        }
        
        return nil
    }
    
    func getPlayerWithFacebookID(_ facebookID:String?) -> Player?
    {
        if facebookID != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
            let entity:NSEntityDescription? = NSEntityDescription.entity(forEntityName: "Player", in: self.managedObjectContext!)
            let FBIDPredicate:NSPredicate = NSPredicate(format: "facebookID = %@",facebookID!)
            //predicatesArray.addObject(FBID!)
            fetchRequest.predicate = FBIDPredicate
            fetchRequest.entity = entity
            let FBIDResultArray:NSArray = try! self.managedObjectContext!.fetch(fetchRequest) as NSArray
            if FBIDResultArray.count > 0
            {
                self.fillPlayerEmptyOptionals((FBIDResultArray.object(at: 0) as? Player)!)
                return FBIDResultArray.object(at: 0) as? Player
            }
        }
        
        return nil
    }
    
    

    
    func saveContext () {
        if let moc = self.managedObjectContext {
            if moc.hasChanges
                {
                    do {
                        try
                            moc.save()
                        }
                        catch let error as NSError
                        {
                        // Replace this implementation with code to handle the error appropriately.
                        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                        NSLog("Unresolved error \(error), \(error.userInfo)")
                        //abort()
                        }
                
                }
            
            }
        }
    
    func createFacebookContact() -> FacebookContact?
    {
        var saveError:NSError?
        let contact:FacebookContact? = NSEntityDescription.insertNewObject(forEntityName: "FacebookContact", into: self.managedObjectContext!) as? FacebookContact
        do {
            try managedObjectContext!.save()
            return contact!
        } catch let error as NSError {
            saveError = error
        }
        
        NSLog("Unresolved error \(saveError!), \(saveError!.userInfo)")
        return nil
    }
    
    func setFacebookContactInformation(_ contact:FacebookContact, id:String?, name:String?, first_name:String?, last_name:String?, picture:Data?, email:String?, phone_number:String?, list_type:String?,invited:Bool?,hasTheApp:Bool?,username:String?,middle_name:String?,checksum:String?) -> FacebookContact?
    {
        if id != nil
        {
            contact.id = id!
        }
        else
        {
            contact.id = ""
        }
        if name != nil
        {
            contact.name = name!
        }
        else
        {
            contact.name = ""
        }
        if first_name != nil
        {
            contact.first_name = first_name!
        }
        else
        {
            contact.first_name = ""
        }
        if last_name != nil
        {
            contact.last_name = last_name!
        }
        else
        {
            contact.last_name = ""
        }
        if picture != nil
        {
            contact.picture = picture!
        }
        else
        {
            contact.picture = Data(base64Encoded: "", options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)! as NSData as Data
        }
        if email != nil
        {
            contact.email = email!
        }
        else
        {
            contact.email = ""
        }
        if phone_number != nil
        {
            contact.phone_number = phone_number!
        }
        else
        {
            contact.phone_number = ""
        }
        if list_type != nil
        {
            contact.list_type = list_type!
        }
        else
        {
            contact.list_type = ""
        }
        if invited != nil
        {
            contact.invited = invited! as NSNumber
        }
        else
        {
            contact.invited = false
        }
        if hasTheApp != nil
        {
            contact.hasTheApp = hasTheApp! as NSNumber
        }
        else
        {
            contact.hasTheApp = false
        }
        if username != nil
        {
            contact.username = username!
        }
        else
        {
            contact.username = ""
        }
        if middle_name != nil
        {
            contact.middle_name = middle_name!
        }
        else
        {
            contact.middle_name = ""
        }
        if checksum != nil
        {
            contact.checksum = checksum!
        }
        else
        {
            contact.checksum = ""
        }
        var saveError:NSError?
        do {
            try managedObjectContext!.save()
        } catch let error as NSError {
            saveError = error
            NSLog("Unresolved error \(saveError!), \(saveError!.userInfo)")
            return nil
        }
        return self.getFacebookContactWithID(id)
    }
    
    func storeFacebookContactWithInformation(_ contact:FacebookContact, id:String?, name:String?, first_name:String?, last_name:String?, picture:Data?, email:String?, phone_number:String?, list_type:String?,invited:Bool?,hasTheApp:Bool?,username:String?,middle_name:String?,checksum:String?)
    {
        if id != nil
        {
            contact.id = id!
        }
        if name != nil
        {
            contact.name = name!
        }
        if first_name != nil
        {
            contact.first_name = first_name!
        }
        if last_name != nil
        {
            contact.last_name = last_name!
        }
        if picture != nil
        {
            contact.picture = picture!
        }
        if email != nil
        {
            contact.email = email!
        }
        if phone_number != nil
        {
            contact.phone_number = phone_number!
        }
        if list_type != nil
        {
            contact.list_type = list_type!
        }
        if invited != nil
        {
            contact.invited = invited! as NSNumber
        }
        if hasTheApp != nil
        {
            contact.hasTheApp = hasTheApp! as NSNumber
        }
        if username != nil
        {
            contact.username = username!
        }
        if middle_name != nil
        {
            contact.middle_name = middle_name!
        }
        if checksum != nil
        {
            contact.checksum = checksum!
        }
        var saveError:NSError?
        do {
            try managedObjectContext!.save()
        } catch let error as NSError {
            saveError = error
            NSLog("Unresolved error \(saveError!), \(saveError!.userInfo)")
        }
    }
    
    func getFacebookContactWithID(_ id:String?) -> FacebookContact?
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entity:NSEntityDescription? = NSEntityDescription.entity(forEntityName: "FacebookContact", in: self.managedObjectContext!)
        
        if id != nil
        {
            let nameHashPredicate = NSPredicate(format: "id = %@",id!)
            fetchRequest.predicate = nameHashPredicate
            fetchRequest.entity = entity
            let idResultArray:NSArray = try! self.managedObjectContext!.fetch(fetchRequest) as NSArray
            if idResultArray.count > 0
            {
                return idResultArray.object(at: 0) as? FacebookContact
            }
        }
        return nil
    }
    
    func getFacebookContacts() -> NSArray?
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entity:NSEntityDescription? = NSEntityDescription.entity(forEntityName: "FacebookContact", in: self.managedObjectContext!)
        //fetchRequest?.predicate = nil
        fetchRequest.entity = entity
        let resultArray:NSArray = try! self.managedObjectContext!.fetch(fetchRequest) as NSArray
        return resultArray
    }
    
    func getPlayers() -> NSArray
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entity:NSEntityDescription? = NSEntityDescription.entity(forEntityName: "Player", in: self.managedObjectContext!)
        //fetchRequest?.predicate = nil
        fetchRequest.entity = entity
        let resultArray:NSArray = try! self.managedObjectContext!.fetch(fetchRequest) as NSArray
        for aFile in resultArray
        {
            self.fillPlayerEmptyOptionals(aFile as! Player)
        }
        return resultArray
    }
    
    func getMatches() -> NSArray
    {
        //print("get Matches")
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entity:NSEntityDescription? = NSEntityDescription.entity(forEntityName: "Match", in: self.managedObjectContext!)
        self.matchesSortDescriptor = NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
        fetchRequest.sortDescriptors = [matchesSortDescriptor!]
        fetchRequest.entity = entity
        let resultArray:NSArray = try! self.managedObjectContext!.fetch(fetchRequest) as NSArray
        for aMatch in resultArray
        {
            //print("filling match")
        self.fillMatchEmptyOptionals(aMatch as! Match)
        }
        return resultArray
    }
    
    func getFiles() -> NSArray
    {
       let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entity:NSEntityDescription = NSEntityDescription.entity(forEntityName: "File", in: self.managedObjectContext!)!
        //fetchRequest?.predicate = nil
        fetchRequest.entity = entity
        let resultArray:NSArray = try! self.managedObjectContext!.fetch(fetchRequest) as NSArray
        for aFile in resultArray
        {
            self.fillFileEmptyOptionals(aFile as! File)
        }
        return resultArray
    }
    
    func getAllDeletedObjectsReferences() -> NSArray
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entity:NSEntityDescription? = NSEntityDescription.entity(forEntityName: "DeletedObject", in: self.managedObjectContext!)
        //fetchRequest?.predicate = nil
        fetchRequest.entity = entity
        let resultArray:NSArray = try! self.managedObjectContext!.fetch(fetchRequest) as NSArray
        /*for aObject in resultArray
        {
            //self.fillDeletedObjectEmptyOptionals(aObject as! DeletedObject)
        }*/
        return resultArray
    }
    
    func getDeletedObjectsReferencesCreatedBeforeDate(_ aDate:Date) -> NSArray?
    {
        //if aDate != nil{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entity:NSEntityDescription? = NSEntityDescription.entity(forEntityName: "DeletedObject", in: self.managedObjectContext!)
        let modificationPredicate:NSPredicate = NSPredicate(format: "deletionDate < %@",aDate as CVarArg)
        fetchRequest.predicate = modificationPredicate
        fetchRequest.entity = entity
        let resultArray:NSArray = try! self.managedObjectContext!.fetch(fetchRequest) as NSArray
        if resultArray.count > 0
        {
            return resultArray
        }
        //}
        return nil
    }
    
    func removeAllDeletedObjectsReferences()
    {
        var saveError:NSError?
        if self.managedObjectContext != nil
        {
            let facebookContacts:NSArray? = getAllDeletedObjectsReferences()
            if facebookContacts != nil
            {
                if facebookContacts?.count > 0
                {
                    for aFacebookContact in facebookContacts!
                    {
                        self.managedObjectContext?.delete(aFacebookContact as! NSManagedObject)
                    }
                    do
                    {
                        try managedObjectContext!.save()
                        self.deletionCicleStartDate = nil
                    }
                    catch let error as NSError
                    {
                        saveError = error
                        NSLog("Unresolved error \(saveError!), \(saveError!.userInfo)")
                    }
                }
            }
            
        }
        
    }

    
    func removeAllFacebookContacts()
    {
        var saveError:NSError?
        if self.managedObjectContext != nil
        {
            let facebookContacts:NSArray? = getFacebookContacts()
            if facebookContacts != nil
                {
                    if facebookContacts?.count > 0
                    {
                        for aFacebookContact in facebookContacts!
                        {
                            self.managedObjectContext?.delete(aFacebookContact as! NSManagedObject)
                        }
                        do
                        {
                            try managedObjectContext!.save()
                        }
                        catch let error as NSError
                        {
                            saveError = error
                            NSLog("Unresolved error \(saveError!), \(saveError!.userInfo)")
                        }
                    }
            }
            
        }

    }
    
    func storeFacebookContactsInContactsMutableArray(_ contactsMutableArray:NSMutableArray)
    {
        
            if contactsMutableArray.count > 0
            {
                for item in contactsMutableArray
                {
                    if let aFacebookContactDictionary:NSDictionary = item as? NSDictionary
                    {
                    let aFacebookContact:FacebookContact? = createFacebookContact()
                    var pictureData: Data? = nil
                        if aFacebookContact != nil
                        {
                        
                            if let pictureDictionary = aFacebookContactDictionary.object(forKey: "picture") as? NSDictionary
                            {
                                if let dataDictionary = pictureDictionary.object(forKey: "data") as? NSDictionary
                                {
                                   
                                    if let urlString = dataDictionary.object(forKey: "url") as? String
                                    {
                                        var error:NSError?
                                        if (URL(string: urlString) as NSURL?)?.checkResourceIsReachableAndReturnError(&error) != nil
                                        {
                                            let aPictureData = try? Data(contentsOf: URL(string:urlString)!)
                                            if aPictureData != nil
                                            {
                                                pictureData = aPictureData
                                            }
                                        }
                                    }
                                }
                            }
                        
                        
                        
                        
                    storeFacebookContactWithInformation(aFacebookContact!, id: aFacebookContactDictionary.object(forKey: "id") as? String, name: aFacebookContactDictionary.object(forKey: "name") as? String, first_name: aFacebookContactDictionary.object(forKey: "first_name") as? String, last_name: aFacebookContactDictionary.object(forKey: "last_name") as? String, picture: pictureData, email: aFacebookContactDictionary.object(forKey: "email") as? String, phone_number: aFacebookContactDictionary.object(forKey: "phone_number") as? String, list_type: aFacebookContactDictionary.object(forKey: "list_type") as? String, invited: false, hasTheApp: false, username: aFacebookContactDictionary.object(forKey: "username") as? String, middle_name: aFacebookContactDictionary.object(forKey: "middle_name") as? String, checksum: nil)
                    }
                    }
                }
            }
        
    }
    
    func storeFacebookContactsInContactsArray(_ contactsArray:NSArray)
    {
        
        if contactsArray.count > 0
        {
            for item in contactsArray
            {
                if let aFacebookContactDictionary:NSDictionary = item as? NSDictionary
                {
                    let aFacebookContact:FacebookContact? = createFacebookContact()
                    
                    var pictureData: Data? = nil
                    
                    
                    if aFacebookContact != nil
                    {
                        if let pictureDictionary = aFacebookContactDictionary.object(forKey: "picture") as? NSDictionary
                        {
                            if let dataDictionary = pictureDictionary.object(forKey: "data") as? NSDictionary
                            {
                                
                                if let urlString = dataDictionary.object(forKey: "url") as? String
                                {
                                    var error:NSError?
                                    if (URL(string: urlString) as NSURL?)?.checkResourceIsReachableAndReturnError(&error) != nil
                                    {
                                        let aPictureData = try? Data(contentsOf: URL(string:urlString)!)
                                        if aPictureData != nil
                                        {
                                            pictureData = aPictureData
                                        }
                                    }
                                }
                            }
                        }
                        
                    storeFacebookContactWithInformation(aFacebookContact!, id: aFacebookContactDictionary.object(forKey: "id") as? String, name: aFacebookContactDictionary.object(forKey: "name") as? String, first_name: aFacebookContactDictionary.object(forKey: "first_name") as? String, last_name: aFacebookContactDictionary.object(forKey: "last_name") as? String, picture: pictureData, email: aFacebookContactDictionary.object(forKey: "email") as? String, phone_number: aFacebookContactDictionary.object(forKey: "phone_number") as? String, list_type: aFacebookContactDictionary.object(forKey: "list_type") as? String, invited: false, hasTheApp: false, username: aFacebookContactDictionary.object(forKey: "username") as? String, middle_name: aFacebookContactDictionary.object(forKey: "middle_name") as? String, checksum: nil)
                    }
                }
            }
        }
        
    }
    
    func replaceFacebookContactsWithContactsInMutableArray(_ contactsMutableArray:NSMutableArray)
    {
        removeAllFacebookContacts()
        storeFacebookContactsInContactsMutableArray(contactsMutableArray)
    
    }
    
    func replaceFacebookContactsWithContactsInArray(_ contactsArray:NSArray)
    {
        removeAllFacebookContacts()
        storeFacebookContactsInContactsArray(contactsArray)
        
    }
    
    func removeFacebookContact(_ contact:FacebookContact?)
    {
        var saveError:NSError?
        if self.managedObjectContext != nil
        {
            if contact != nil {
                
                    managedObjectContext?.delete(contact!)
                    do {
                        try managedObjectContext!.save()
                    } catch let error as NSError {
                        saveError = error
                        NSLog("Unresolved error \(saveError!), \(saveError!.userInfo)")
                    }
                
            }
        }
    }
    
    /*func syncDataInFirebaseWithFacebookToken(_ token:FBSDKAccessToken)
    {
        /*let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            
            let defaults = NSUserDefaults.standardUserDefaults()
            
            
            if let firebaseLoginfailed:Bool? = defaults.objectForKey("firebaseLoginfailed") as? Bool != nil
            {
                if (firebaseLoginfailed != nil)
                {
                    self.dumpDataFromFirebaseWithFacebookToken(FBSDKAccessToken.currentAccessToken())
                }
            }
            self.syncDeletedDataInFirebaseWithFacebookToken(token)
            self.syncNewDataSinceLastCicleWithToken(token)
            /*dispatch_async(dispatch_get_main_queue()) {
                // update some UI
            }*/
        }*/
    }*/
    
   /* func syncDeletedDataInFirebaseWithFacebookToken(_ token:FBSDKAccessToken)
    {
        

        /*if self.eSpleenRef.authData == nil
        {
            self.eSpleenRef.authWithOAuthProvider("facebook", token: token.tokenString, withCompletionBlock: { error, authData in
                
                if error != nil
                {
                    print("Login failed. \(error)")
                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setObject(true, forKey: "firebaseLoginfailed")
                    NSUserDefaults.standardUserDefaults().synchronize()
                }
                else
                {
                    print("Logged in! \(authData)")
                    
                    self.syncDeletedDataWithToken(token)
                    
                }
                
            })
        }
        else
        {
            self.syncDeletedDataWithToken(token)
        }
        
        
    */
    }*/
    
   /* func syncDeletedDataWithToken(_ token:FBSDKAccessToken)
    {
        let userLastUpdateRef = self.eSpleenRef.child("users/"+token.userID+"/info/lastUpdate")
        userLastUpdateRef.observe(.value, with: {snapshot in
            
            if snapshot.value != nil
            {
                let dateFormatter:DateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
                let date = dateFormatter.date(from: snapshot.value as! String)
                
                if self.deletionCicleStartDate != nil
                {
                    //error, falla por objeto nulo
                    //print("fecha error objeto nulo",date)
                    for anObject in self.getDeletedObjectsReferencesCreatedBeforeDate(date!)!
                    {
                        if (anObject as! DeletedObject).type == "match"
                        {
                            
                            let matchRef = self.eSpleenRef.child("users/"+token.userID+"/matches/"+(anObject as! DeletedObject).id!)
                            matchRef.removeValue(completionBlock: {error, firebaseRef in
                                
                                
                                if error == nil
                                {
                                    
                                }
                                else
                                {
                                    do
                                    {
                                        self.managedObjectContext?.delete(anObject as! NSManagedObject)
                                        try self.managedObjectContext!.save()
                                    }
                                    catch let error as NSError
                                    {
                                        
                                        NSLog("Unresolved error syncing  \(error), \(error.userInfo)")
                                    }
                                    
                                }
                                
                            })
                        }
                        
                    }
                    
                }
                if self.getAllDeletedObjectsReferences().count == 0
                {
                    self.deletionCicleStartDate = nil
                    //print("OBJETOS BORRADOS SINCRONIZADOS")
                }
                else
                {
                    //print("OBJETOS BORRADOS NO SINCRONIZADOS")
                }
                
                
            }
        })
    }*/
    
    
    /*func syncNewDataSinceLastCicleWithToken(_ token:FBSDKAccessToken)
    {
        
        /*if self.eSpleenRef.authData == nil
        {
            self.eSpleenRef.authWithOAuthProvider("facebook", token: token.tokenString, withCompletionBlock: { error, authData in
                
                
                
                if error != nil
                {
                    print("Login failed. \(error)")
                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setObject(true, forKey: "firebaseLoginfailed")
                    NSUserDefaults.standardUserDefaults().synchronize()
                }
                else
                {
                    print("Logged in! \(authData)")
                    self.syncNewDataWithToken(token)
                    
                    
                }
                
            })
        }
        else
        {
            self.syncNewDataWithToken(token)
        }
        
        */
    }*/
    
    
    /*func syncNewDataWithToken(_ token:FBSDKAccessToken)
    {
        
        /*let lastUpdateRef = self.eSpleenRef.childByAppendingPath("users/"+token.userID+"/info/lastUpdate")
        lastUpdateRef.observeEventType(FEventType.Value, withBlock: {snapshot in
            
            var newPlayers:NSMutableArray
            
            var newMatches:NSMutableArray
            var newParticipations:NSMutableArray
            var newTrophies:NSMutableArray
            var newFiles:NSMutableArray
            var newPoints:NSMutableArray
            var newProofs:NSMutableArray
            
            if ((snapshot.value as? NSString) != nil)
            {
                //print("LAST UPDATE EXISTS")
                let dateFormatter:NSDateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
                //print("snapshot value",snapshot.value)
                let date = dateFormatter.dateFromString(snapshot.value as! String)
                
                if date != nil
                {
                    //print("DATE NOT NIL")
                    self.syncCicleStartDate = NSDate()
                    newPlayers = (self.getPlayersModifiedAfterDate(date!).mutableCopy()) as! NSMutableArray
                    newMatches = (self.getMatchesModifiedAfterDate(date!).mutableCopy()) as! NSMutableArray
                    newParticipations = (self.getParticipationsCreatedAfterDate(date!).mutableCopy()) as! NSMutableArray
                    newTrophies = (self.getTrophiesModifiedAfterDate(date!).mutableCopy()) as! NSMutableArray
                    newFiles = (self.getFilesModifiedAfterDate(date!).mutableCopy()) as! NSMutableArray
                    newPoints = (self.getPointsModifiedAfterDate(date!).mutableCopy()) as! NSMutableArray
                    newProofs = (self.getProofsModifiedAfterDate(date!).mutableCopy()) as! NSMutableArray
                    let discardedFiles:NSMutableArray = NSMutableArray()
                    for aFile in newFiles
                    {
                        let idPredicate = NSPredicate(format: "SELF.id like[cd] %@", ((aFile as! File).trophy?.id!)!)
                        if (newTrophies.filteredArrayUsingPredicate(idPredicate)).count > 0
                        {
                            discardedFiles.addObject(aFile)
                        }
                        
                    }
                    //print("files to delete",discardedFiles.count)
                    newFiles.removeObjectsInArray(discardedFiles as [AnyObject])
                    
                    let discardedProofs:NSMutableArray = NSMutableArray()
                    
                    for aProof in newProofs
                    {
                        let idPredicate = NSPredicate(format: "SELF.id like[cd] %@", ((aProof as! Proof).point?.id!)!)
                        if (newPoints.filteredArrayUsingPredicate(idPredicate)).count > 0
                        {
                            discardedProofs.addObject(aProof)
                        }
                        
                    }
                    //print("discarded proofs",discardedProofs.count)
                    newProofs.removeObjectsInArray(discardedProofs as [AnyObject])
                    
                    let discardedPoints:NSMutableArray = NSMutableArray()
                    
                    for aPoint in newPoints
                    {
                        let idPredicate = NSPredicate(format: "SELF.id like[cd] %@", ((aPoint as! Point).trophy?.id!)!)
                        if (newTrophies.filteredArrayUsingPredicate(idPredicate)).count > 0
                        {
                            discardedPoints.addObject(aPoint)
                        }
                        
                    }
                    //print("discarded points",discardedPoints.count)
                    newPoints.removeObjectsInArray(discardedPoints as [AnyObject])
                    
                    let discardedTrophies:NSMutableArray = NSMutableArray()
                    
                    for aTrophy in newTrophies
                    {
                        let idPredicate = NSPredicate(format: "ANY trophies.id like[cd] %@", (aTrophy as! Trophy).id!)
                        if (newParticipations.filteredArrayUsingPredicate(idPredicate)).count > 0
                        {
                            discardedTrophies.addObject(aTrophy)
                        }
                        
                    }
                    //print("discarded trophies",discardedTrophies.count)
                    newTrophies.removeObjectsInArray(discardedTrophies as [AnyObject])
                    
                    let discardedParticipations:NSMutableArray = NSMutableArray()
                    
                    for aParticipation in newParticipations
                    {
                        let idPredicate = NSPredicate(format: "SELF.id like[cd] %@", (aParticipation as! Participation).match.id!)
                        if (newMatches.filteredArrayUsingPredicate(idPredicate)).count > 0
                        {
                            discardedParticipations.addObject(aParticipation)
                        }
                        
                    }
                    //print("discarded participations",discardedParticipations.count)
                    newParticipations.removeObjectsInArray(discardedParticipations as [AnyObject])
                    
                    
                    
                    
                    var playerDictionary = [String:String]()
                    var players = [String:[String:String]]()
                    //var userInfo = [String:String]()
                    //var userPair = [String:[String:AnyObject]]()
                    var matchDictionary = [String:AnyObject]()
                    var matches = [String:[String:AnyObject]]()
                    var participationDictionary = [String:AnyObject]()
                    var participations = [String:[String:AnyObject]]()
                    var trophyDictionary = [String:AnyObject]()
                    var trophies = [String:[String:AnyObject]]()
                    var pointDictionary = [String:AnyObject]()
                    var points = [String:[String:AnyObject]]()
                    var proofDictionary = [String:AnyObject]()
                    var proofs = [String:[String:AnyObject]]()
                    var fileDictionary = [String:String]()
                    var files = [String:[String:String]]()
                    
                    //print("participations to sync",newParticipations.count)
                    //print("trophies to sync",newTrophies.count)
                    //print("points to sync",newPoints.count)
                    //print("proofs to sync",newProofs.count)
                    
                    
                    print("files to sync",newFiles.count)
                    for aFile in newFiles
                    {
                        self.fillFileEmptyOptionals(aFile as! File)
                        
                        fileDictionary = ["id":(aFile as! File).id!,"creationDate":((aFile as! File).creationDate!.description),"modificationDate":((aFile as! File).creationDate!.description),"name":(aFile as! File).name! as String,"type":(aFile as! File).type! as String,"urlPath":(aFile as! File).urlPath! as String,"trophy":((aFile as! File).trophy?.id!)! as String,"data":((aFile as! File).data?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength))!]
                        files[(aFile as! File).id! as String] = fileDictionary
                    }
                    
                    print("players to sync",newPlayers.count)
                    for aPlayer in newPlayers
                    {
                        self.fillPlayerEmptyOptionals(aPlayer as! Player)
                        
                        playerDictionary = ["id":(aPlayer as! Player).id!, "nameHash":(aPlayer as! Player).nameHash! as String,"forenames":(aPlayer as! Player).forenames! as String,"surenames":(aPlayer as! Player).surenames! as String,"facebookID":(aPlayer as! Player).facebookID! as String,"twitterID":(aPlayer as! Player).twitterID! as String,"abID":(aPlayer as! Player).abID! as String, "gamecenterID":(aPlayer as! Player).gamecenterID! as String, "googlePlusID":(aPlayer as! Player).googlePlusID!, "mixiID":(aPlayer as! Player).mixiID!, "weiboID":(aPlayer as! Player).weiboID!,"mobageID":(aPlayer as! Player).mobageID! as String,"picture":((aPlayer as! Player).picture?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength))!]
                        players[(aPlayer as! Player).id! as String] = playerDictionary
                    }
                    
                    print("matches to sync",newMatches.count)
                    for aMatch in newMatches
                    {
                        self.fillMatchEmptyOptionals(aMatch as! Match)
                        
                        for aParticipation:NSManagedObject in ((aMatch as! Match).participants?.allObjects as! [NSManagedObject])
                        {
                            for aTrophy:NSManagedObject in ((aParticipation as! Participation).trophies.allObjects as! [NSManagedObject])
                            {
                                for aPoint:NSManagedObject in ((aTrophy as! Trophy).points!.allObjects as! [NSManagedObject])
                                {
                                    
                                    for aProof:NSManagedObject in ((aTrophy as! Trophy).points!.allObjects as! [NSManagedObject])
                                    {
                                        self.fillProofEmptyOptionals(aProof as! Proof)
                                        
                                        proofDictionary = ["id":(aProof as! Proof).id!, "creationDate":((aProof as! Proof).creationDate.description),"modificationDate":((aProof as! Proof).creationDate.description),"name":(aProof as! Proof).name!,"type":(aProof as! Proof).type!,"urlPath":(aProof as! Proof).urlPath!,"point":((aProof as! Proof).point?.id!)!,"data":((aProof as! Proof).data?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength))!]
                                        proofs[(aPoint as! Proof).id! as String] = proofDictionary
                                    }
                                    
                                    self.fillPointEmptyOptionals(aPoint as! Point)
                                    
                                    pointDictionary = ["id":(aPoint as! Point).id!, "creationDate":((aPoint as! Point).creationDate.description),"modificationDate":((aPoint as! Point).creationDate.description),"timeStamp":((aPoint as! Point).timeStamp?.description)!,"latitude":((aPoint as! Point).latitude?.description)!,"longitude":((aPoint as! Point).longitude?.description)!,"proof":((aPoint as! Point).proofs?.id!)!,"trophy":((aPoint as! Point).trophy?.id!)!]
                                    points[(aPoint as! Point).id! as String] = pointDictionary
                                }
                                self.fillTrophyEmptyOptionals(aTrophy as! Trophy)
                                
                                var fileID = ""
                                if (aTrophy as! Trophy).files != nil
                                {
                                    self.fillFileEmptyOptionals((aTrophy as! Trophy).files!)
                                    fileID = ((aTrophy as! Trophy).files?.id)!
                                }
                                trophyDictionary = ["id":(aTrophy as! Trophy).id!, "name":(aTrophy as! Trophy).name as! String,"picture":((aTrophy as! Trophy).picture!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)), "creationDate":((aTrophy as! Trophy).creationDate!.description),"modificationDate":((aTrophy as! Trophy).creationDate!.description),"type":(aTrophy as! Trophy).type,"score":(aTrophy as! Trophy).score!.stringValue,"approved":(aTrophy as! Trophy).approved.description,"groupTrophy":(aTrophy as! Trophy).groupTrophy.description,"file":fileID,"points":points,"match":(aMatch as! Match).id! as String,"player":(aParticipation as! Participation).player.id! as String]
                                trophies[(aTrophy as! Trophy).id! as String] = trophyDictionary
                                
                                points.removeAll()
                            }
                            
                            self.fillParticipationEmptyOptionals(aParticipation as! Participation)
                            self.fillPlayerEmptyOptionals((aParticipation as! Participation).player)
                            
                            //participationDictionary = ["corner":(aParticipation as! Participation).corner! as String,"match":(aParticipation as! Participation).match.id! as String,"player":(aParticipation as! Participation).player.id! as String,"creationDate":((aParticipation as! Participation).creationDate?.description)!]
                            participationDictionary = ["corner":(aParticipation as! Participation).corner! as String,"match":(aParticipation as! Participation).match.id! as String,"player":(aParticipation as! Participation).player.id! as String,"creationDate":((aParticipation as! Participation).creationDate?.description)!,"trophies":trophies]
                            participations[(aParticipation as! Participation).corner! as String] = participationDictionary
                            
                            trophies.removeAll()
                        }
                        
                        matchDictionary = ["id":(aMatch as! Match).id! as String, "name":(aMatch as! Match).name! as String, "creationDate":((aMatch as! Match).creationDate?.description)!,"modificationDate":((aMatch as! Match).creationDate?.description)!,"scoreAdds":(aMatch as! Match).scoreAdds.description,"participations":participations]
                        matches[(aMatch as! Match).id! as String] = matchDictionary
                        
                        participations.removeAll()
                    }
                    
                    
                    let playerRef = self.eSpleenRef.childByAppendingPath("users/"+token.userID+"/info")
                    let playerMatchesRef = self.eSpleenRef.childByAppendingPath("users/"+token.userID+"/matches")
                    let playerPlayers = self.eSpleenRef.childByAppendingPath("users/"+token.userID+"/players")
                    
                    
                    let lastUpdate = ["lastUpdate":(self.syncCicleStartDate?.description)!]
                    playerRef.updateChildValues(lastUpdate)
                    for aPlayer in players
                    {
                        playerPlayers.updateChildValues([aPlayer.0:aPlayer.1])
                    }
                    
                    for aMatch in matches
                    {
                        playerMatchesRef.updateChildValues([aMatch.0:aMatch.1])
                    }
                    
                    
                    
                    
                }
                else
                {
                    self.copyAllDataInFirebaseWithFacebookToken(FBSDKAccessToken.currentAccessToken())
                }
                
            }
            else
            {
                //print("LAST UPDATE DOESNT EXISTS")
                self.copyAllDataInFirebaseWithFacebookToken(FBSDKAccessToken.currentAccessToken())
            }
        })*/
    }*/
    
    /*func dumpDataFromFirebaseWithFacebookToken(_ token:FBSDKAccessToken)
    {
        /*let defaults = NSUserDefaults.standardUserDefaults()
        let appFirstRunDate = defaults.objectForKey("isFirstRun") as? NSDate
        if appFirstRunDate != nil
        {
            let lastUpdateRef = self.eSpleenRef.childByAppendingPath("users/"+token.userID+"/info/lastUpdate")
            
            lastUpdateRef.observeSingleEventOfType(FEventType.Value, withBlock: {lastUpdateSnap in
                
                if !(lastUpdateSnap.value is NSNull)
                {
                    let dateFormatter:NSDateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
                    let fireBaseLastUpdateDate = dateFormatter.dateFromString(lastUpdateSnap.value as! String)
                    if fireBaseLastUpdateDate?.earlierDate(appFirstRunDate!) == fireBaseLastUpdateDate
                    {
                        if self.eSpleenRef.authData == nil
                        {
                            self.eSpleenRef.authWithOAuthProvider("facebook", token: token.tokenString, withCompletionBlock: { error, authData in
                                
                                if error != nil {
                                    print("Login failed. \(error)")
                                    let defaults = NSUserDefaults.standardUserDefaults()
                                    defaults.setObject(true, forKey: "firebaseLoginfailed")
                                    NSUserDefaults.standardUserDefaults().synchronize()
                                } else {
                                    print("Logged in! \(authData)")
                                    
                                    let defaults = NSUserDefaults.standardUserDefaults()
                                    defaults.setObject(false, forKey: "firebaseLoginfailed")
                                    NSUserDefaults.standardUserDefaults().synchronize()
                                    self.dumpDataWithToken(token)
                                    
                                }
                            })
                        }
                        else
                        {
                            self.dumpDataWithToken(token)
                        }
                        
                        
                    }
                }
            })
        }*/
    }*/
    
    
   /* func dumpDataWithToken(_ token:FBSDKAccessToken)
    {
        let userRef = self.eSpleenRef.child("users/"+token.userID)
        userRef.observeSingleEvent(of: .value, with: {snapshot in
            
            if snapshot.value == nil
            {
                //print("USUARIO NO TIENE DATOS")
            }
            else
            {
                var players:NSDictionary?
                var matches:NSDictionary?
                var participations:NSDictionary?
                var trophies:NSDictionary?
                var points:NSDictionary?
                //var proofs:NSDictionary?
                //var files:NSDictionary?
                
                let filesRef = userRef.child("files")
                let matchesRef = userRef.child("matches")
                //let participationsRef = userRef.childByAppendingPath("participations")
                let playersRef = userRef.child("players")
                //let trophiesRef = userRef.childByAppendingPath("trophies")
                //let pointRef = userRef.childByAppendingPath("points")
                let proofsRef = userRef.child("proofs")
                
                filesRef.observeSingleEvent(of: .value, with: {snap in
                    if !(snap.value is NSNull)  {
                        
                        //files = (snap.value as! NSDictionary)
                    }
                    proofsRef.observeSingleEvent(of: .value, with: {snap in
                        if !(snap.value is NSNull) {
                            //proofs = (snap.value as! NSDictionary)
                        }
                        
                        playersRef.observeSingleEvent(of: .value, with: {snap in
                            if !(snap.value is NSNull)
                            {
                                players = (snap.value as! NSDictionary)
                                for aPlayer in players!
                                {
                                    let aNewPlayer = self.createPlayer()
                                    _ = self.setPlayer(
                                        aNewPlayer!,
                                        id: (aPlayer.value as! NSDictionary).value(forKey: "id") as? String,
                                        nameHash: (aPlayer.value as! NSDictionary).value(forKey: "nameHash") as? String,
                                        forenames: (aPlayer.value as! NSDictionary).value(forKey: "forenames") as? NSString,
                                        surenames: (aPlayer.value as! NSDictionary).value(forKey: "surenames") as? NSString,
                                        addressBookID: (aPlayer.value as! NSDictionary).value(forKey: "abID") as? NSString,
                                        facebookID: (aPlayer.value as! NSDictionary).value(forKey: "facebookID") as? NSString,
                                        googlePlusID: (aPlayer.value as! NSDictionary).value(forKey: "googlePlusID") as? String,
                                        twitterID: (aPlayer.value as! NSDictionary).value(forKey: "twitterID") as? NSString,
                                        gamecenterID: (aPlayer.value as! NSDictionary).value(forKey: "gamecenterID") as? NSString,
                                        mobageID: (aPlayer.value as! NSDictionary).value(forKey: "mobageID") as? NSString,
                                        mixiID: (aPlayer.value as! NSDictionary).value(forKey:"mixiID") as? String,
                                        weiboID: (aPlayer.value as! NSDictionary).value(forKey: "weiboID") as? String,
                                        picture:  NSData(base64Encoded: ((aPlayer.value as! NSDictionary).value(forKey: "picture") as? Data)!,
                                        options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)! as Data
                                        )
                                }
                            }
                            
                            matchesRef.observeSingleEvent(of: .value, with: {snap in
                                
                                if !(snap.value is NSNull)  {
                                    matches = (snap.value as! NSDictionary)
                                }
                                if matches != nil
                                {
                                    for aMatch in matches!
                                    {
                                        let aNewMatch = self.createMatch()
                                        participations = (aMatch.value as! NSDictionary).value(forKey: "participations") as? NSDictionary
                                        if participations != nil
                                        {
                                            for aParticipation in participations!
                                            {
                                                let thePlayer = self.getPlayerWithUUID((aParticipation.value as! NSDictionary).value(forKey: "player") as? String)
                                                if thePlayer != nil
                                                {
                                                    //let aNewParticipation = self.addPlayer(thePlayer!, toMatch: aNewMatch!, corner: aParticipation.key as! NSString)
                                                    trophies = (aParticipation.value as! NSDictionary).value(forKey: "trophies") as? NSDictionary
                                                    if trophies != nil
                                                    {
                                                        for aTrophy in trophies!
                                                        {
                                                            let aNewTrophy:Trophy? = self.createTrophy()
                                                            aNewTrophy?.name = (aTrophy.value as! NSDictionary).value(forKey: "name") as! String as NSString
                                                            aNewTrophy?.score = Int((aTrophy.value as! NSDictionary).value(forKey: "score") as! String) as NSNumber?
                                                            _ = self.addTrophy(aNewTrophy, toMatch: aNewMatch)
                                                            points = (aTrophy.value as! NSDictionary).value(forKey: "points") as? NSDictionary
                                                            if points != nil
                                                            {
                                                                /*for aPoint in points!
                                                                {
                                                                    
                                                                }*/
                                                            }
                                                            
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                
                            })
                        })
                    })
                })
                self.saveContext()
                //ELSE value not nil
            }
        })
    }*/
    
    /*func copyAllDataInFirebaseWithFacebookToken(_ token:FBSDKAccessToken)
    {
        
        /*if self.eSpleenRef.authData == nil
        {
            self.eSpleenRef.authWithOAuthProvider("facebook", token: token.tokenString, withCompletionBlock: { error, authData in
                
                if error != nil
                {
                    print("Login failed. \(error)")
                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setObject(true, forKey: "firebaseLoginfailed")
                    NSUserDefaults.standardUserDefaults().synchronize()
                }
                else
                {
                    print("Logged in! \(authData)")
                    self.copyDataWithToken(token)
                }
                
            })
        }
        else
        {
            self.copyDataWithToken(token)
        }
        */
    }*/
    
    
    /*func copyDataWithToken(_ token:FBSDKAccessToken)
    {
        
        let usersRef = self.eSpleenRef.child("users/"+token.userID+"/info/nombre")
        
        usersRef.observe(.value, with: {snapshot in
            
            if snapshot.value == nil
            {
                
            }
            else
            {
                self.syncCicleStartDate = NSDate() as Date
                let eSpleenUsersRef = self.eSpleenRef.child("users")
                var playerDictionary = [String:String]()
                let playersArray:NSArray = self.getPlayers()
                var players = [String:[String:String]]()
                var userInfo = [String:String]()
                var user = [String:[String:[String:AnyObject]]]()
                var userPair = [String:[String:AnyObject]]()
                var matchDictionary = [String:AnyObject]()
                let matchesArray:NSArray = self.getMatches()
                var matches = [String:[String:AnyObject]]()
                var participationDictionary = [String:AnyObject]()
                var participations = [String:[String:AnyObject]]()
                var trophyDictionary = [String:AnyObject]()
                var trophies = [String:[String:AnyObject]]()
                var pointDictionary = [String:AnyObject]()
                var points = [String:[String:AnyObject]]()
                var proofDictionary = [String:AnyObject]()
                var proofs = [String:[String:AnyObject]]()
                var fileDictionary = [String:String]()
                let filesArray:NSArray = self.getFiles()
                var files = [String:[String:String]]()
                
                for aFile:NSManagedObject in filesArray as! [NSManagedObject]
                {
                    self.fillFileEmptyOptionals(aFile as! File)
                    
                    fileDictionary = ["id":(aFile as! File).id!,"creationDate":((aFile as! File).creationDate!.description),"modificationDate":((aFile as! File).creationDate!.description),"name":(aFile as! File).name! as String,"type":(aFile as! File).type! as String,"urlPath":(aFile as! File).urlPath! as String,"trophy":((aFile as! File).trophy?.id!)! as String,"data":((aFile as! File).data?.base64EncodedString(options:Data.Base64EncodingOptions.lineLength64Characters))!]
                    files[(aFile as! File).id! as String] = fileDictionary
                }
                
                
                for aPlayer:NSManagedObject in playersArray as! [NSManagedObject]
                {
                    self.fillPlayerEmptyOptionals(aPlayer as! Player)
                    
                    playerDictionary = ["id":(aPlayer as! Player).id!, "nameHash":(aPlayer as! Player).nameHash! as String,"forenames":(aPlayer as! Player).forenames! as String,"surenames":(aPlayer as! Player).surenames! as String,"facebookID":(aPlayer as! Player).facebookID! as String,"twitterID":(aPlayer as! Player).twitterID! as String,"abID":(aPlayer as! Player).abID! as String, "gamecenterID":(aPlayer as! Player).gamecenterID! as String, "googlePlusID":(aPlayer as! Player).googlePlusID!, "mixiID":(aPlayer as! Player).mixiID!, "weiboID":(aPlayer as! Player).weiboID!,"mobageID":(aPlayer as! Player).mobageID! as String,"picture":((aPlayer as! Player).picture?.base64EncodedString(options:NSData.Base64EncodingOptions.lineLength64Characters))!]
                    players[(aPlayer as! Player).id! as String] = playerDictionary
                }
                
                
                for aMatch:NSManagedObject in matchesArray as! [NSManagedObject]
                {
                    self.fillMatchEmptyOptionals(aMatch as! Match)
                    
                    for aParticipation:NSManagedObject in ((aMatch as! Match).participants?.allObjects as! [NSManagedObject])
                    {
                        for aTrophy:NSManagedObject in ((aParticipation as! Participation).trophies.allObjects as! [NSManagedObject])
                        {
                            for aPoint:NSManagedObject in ((aTrophy as! Trophy).points!.allObjects as! [NSManagedObject])
                            {
                                
                                for aProof:NSManagedObject in ((aTrophy as! Trophy).points!.allObjects as! [NSManagedObject])
                                {
                                    self.fillProofEmptyOptionals(aProof as! Proof)
                                    
                                    proofDictionary = ["id":(aProof as! Proof).id! as AnyObject, "creationDate":((aProof as! Proof).creationDate.description as AnyObject as AnyObject),"modificationDate":((aProof as! Proof).creationDate.description as AnyObject),"name":(aProof as! Proof).name! as AnyObject,"type":(aProof as! Proof).type! as AnyObject,"urlPath":(aProof as! Proof).urlPath! as AnyObject as AnyObject,"point":((aProof as! Proof).point?.id!)! as AnyObject,"data":((aProof as! Proof).data?.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters))!] as [String : AnyObject]
                                    proofs[(aPoint as! Proof).id! as String] = proofDictionary
                                }
                                
                                self.fillPointEmptyOptionals(aPoint as! Point)
                                
                                pointDictionary = ["id":(aPoint as! Point).id!, "creationDate":((aPoint as! Point).creationDate.description),"modificationDate":((aPoint as! Point).creationDate.description),"timeStamp":((aPoint as! Point).timeStamp?.description)!,"latitude":((aPoint as! Point).latitude?.description)!,"longitude":((aPoint as! Point).longitude?.description)!,"proof":((aPoint as! Point).proofs?.id!)!,"trophy":((aPoint as! Point).trophy?.id!)!] as [String : AnyObject]
                                points[(aPoint as! Point).id! as String] = pointDictionary
                            }
                            self.fillTrophyEmptyOptionals(aTrophy as! Trophy)
                            
                            var fileID = ""
                            if (aTrophy as! Trophy).files != nil
                            {
                                self.fillFileEmptyOptionals((aTrophy as! Trophy).files!)
                                fileID = ((aTrophy as! Trophy).files?.id)!
                            }
                            trophyDictionary = ["id":(aTrophy as! Trophy).id! as AnyObject, "name":(aTrophy as! Trophy).name! as String as AnyObject,"picture":((aTrophy as! Trophy).picture!.base64EncodedString(options:NSData.Base64EncodingOptions.lineLength64Characters)), "creationDate":((aTrophy as! Trophy).creationDate!.description),"modificationDate":((aTrophy as! Trophy).creationDate!.description),"type":(aTrophy as! Trophy).type,"score":(aTrophy as! Trophy).score!.stringValue,"approved":(aTrophy as! Trophy).approved.description,"groupTrophy":(aTrophy as! Trophy).groupTrophy.description,"file":fileID,"points":points,"match":(aMatch as! Match).id! as String,"player":(aParticipation as! Participation).player.id! as String] as [String : AnyObject] as [String : AnyObject]
                            trophies[(aTrophy as! Trophy).id! as String] = trophyDictionary
                            
                            points.removeAll()
                        }
                        
                        self.fillParticipationEmptyOptionals(aParticipation as! Participation)
                        self.fillPlayerEmptyOptionals((aParticipation as! Participation).player)
                        
                        //participationDictionary = ["corner":(aParticipation as! Participation).corner! as String,"match":(aParticipation as! Participation).match.id! as String,"player":(aParticipation as! Participation).player.id! as String,"creationDate":((aParticipation as! Participation).creationDate?.description)!]
                        participationDictionary = ["corner":(aParticipation as! Participation).corner! as String as String,"match":(aParticipation as! Participation).match.id! as String,"player":(aParticipation as! Participation).player.id! as String,"creationDate":((aParticipation as! Participation).creationDate?.description)!,"trophies":trophies] as [String : AnyObject]
                        participations[(aParticipation as! Participation).corner! as String] = participationDictionary
                        
                        trophies.removeAll()
                    }
                    
                    matchDictionary = ["id":(aMatch as! Match).id! as String, "name":(aMatch as! Match).name! as String, "creationDate":((aMatch as! Match).creationDate?.description)!,"modificationDate":((aMatch as! Match).creationDate?.description)!,"scoreAdds":(aMatch as! Match).scoreAdds.description,"participations":participations] as [String : AnyObject]
                    matches[(aMatch as! Match).id! as String] = matchDictionary
                    
                    participations.removeAll()
                }
                
                
                userInfo = ["nombre":"samir","email":"samir@bucle.co","lastUpdate":(self.syncCicleStartDate?.description)!]
                userPair["info"] = userInfo as [String : AnyObject]
                userPair["players"] = players as [String : AnyObject]
                userPair["matches"] = matches as [String : AnyObject]
                userPair["files"] = files as [String : AnyObject]
                user[token.userID] = userPair
                eSpleenUsersRef.setValue(user) // Updatechild????
                
            }
            //
        })

    }*/
    
    func fillPlayerEmptyOptionals(_ aPlayer:Player)
    {
        for property in aPlayer.entity.attributesByName
        {
            if aPlayer.id == nil || aPlayer.id == ""
            {
                 //print("player id vacio")
                aPlayer.id = NSUUID().uuidString
            }
            if property.1.attributeValueClassName == "NSString" && aPlayer.value(forKey: property.0) == nil
            {
                //print(property.0," vacio")
                aPlayer.setValue("", forKey: property.0)
            }
            else if property.1.attributeValueClassName == "NSDate" && aPlayer.value(forKey: property.0) == nil
            {
                //print(property.0," vacio")
                aPlayer.setValue(Date(), forKey: property.0)
            }
            else if property.1.attributeValueClassName == "NSData" && aPlayer.value(forKey: property.0) == nil
            {
                //print(property.0," vacio")
                aPlayer.setValue(Data(base64Encoded: "", options: NSData.Base64DecodingOptions.ignoreUnknownCharacters), forKey: property.0)
            }
            
        }
        var saveError:NSError?
        do {
            try self.managedObjectContext!.save()
        } catch let error as NSError {
            saveError = error
            NSLog("Unresolved error filling Empty Optionls \(saveError!), \(saveError!.userInfo)")
            
        }

    }
    
    func fillMatchEmptyOptionals(_ aMatch:Match)
    {
        //print("match ID",aMatch.id)
        if aMatch.id == nil || aMatch.id == ""
        {
            
            aMatch.id = NSUUID().uuidString as NSString
            //print("ID vacio",aMatch.id)
            
        }
        
        for property in aMatch.entity.attributesByName
        {
            if property.1.attributeValueClassName == "NSString" && aMatch.value(forKey: property.0) == nil
            {
                //print(property.0," M vacio")
                aMatch.setValue("", forKey: property.0)
            }
            else if property.1.attributeValueClassName == "NSDate" && aMatch.value(forKey: property.0) == nil
            {
                //print(property.0," M vacio")
                aMatch.setValue(Date(), forKey: property.0)
            }
            else if property.1.attributeValueClassName == "NSData" && aMatch.value(forKey: property.0) == nil
            {
                //print(property.0," M vacio")
                aMatch.setValue(Data(base64Encoded: "", options: NSData.Base64DecodingOptions.ignoreUnknownCharacters), forKey: property.0)
            }
            
        }
        var saveError:NSError?
        do {
        try self.managedObjectContext!.save()
        } catch let error as NSError {
        saveError = error
        NSLog("Unresolved error filling Empty Optionls \(saveError!), \(saveError!.userInfo)")
        
        }
        
    }
    
    func fillParticipationEmptyOptionals(_ aParticipation:Participation)
    {
    if aParticipation.corner == nil
    {
    aParticipation.corner = NSUUID().uuidString as NSString
        //print("ID vacio",aParticipation.corner)
    }
    for property in aParticipation.entity.attributesByName
    {
    if property.1.attributeValueClassName == "NSString" && aParticipation.value(forKey: property.0) == nil
    {
    //print(property.0," P vacio")
    aParticipation.setValue("", forKey: property.0)
    }
    else if property.1.attributeValueClassName == "NSDate" && aParticipation.value(forKey: property.0) == nil
    {
    //print(property.0," P vacio")
    aParticipation.setValue(Date(), forKey: property.0)
    }
    else if property.1.attributeValueClassName == "NSData" && aParticipation.value(forKey: property.0) == nil
    {
    //print(property.0," P vacio")
    aParticipation.setValue(Data(base64Encoded: "", options: NSData.Base64DecodingOptions.ignoreUnknownCharacters), forKey: property.0)
    }
    
    }
    var saveError:NSError?
    do {
    try self.managedObjectContext!.save()
    } catch let error as NSError {
    saveError = error
    NSLog("Unresolved error filling Empty Optionls \(saveError!), \(saveError!.userInfo)")
    
    }
    
    }
    
    func fillTrophyEmptyOptionals(_ aTrophy:Trophy)
    {
        //print("trophy ID ",aTrophy.id)
        if aTrophy.id == nil || aTrophy.id == ""
        {
            
            
            aTrophy.id = NSUUID().uuidString
            //print("ID vacio",aTrophy.id)
        }
        for property in aTrophy.entity.attributesByName
        {
            if property.1.attributeValueClassName == "NSString" && aTrophy.value(forKey: property.0) == nil
            {
                //print(property.0," T vacio")
                aTrophy.setValue("", forKey: property.0)
            }
            else if property.1.attributeValueClassName == "NSDate" && aTrophy.value(forKey: property.0) == nil
            {
                //print(property.0," T vacio")
                aTrophy.setValue(Date(), forKey: property.0)
            }
            else if property.1.attributeValueClassName == "NSData" && aTrophy.value(forKey: property.0) == nil
            {
                //print(property.0," T vacio")
                aTrophy.setValue(Data(base64Encoded: "", options: NSData.Base64DecodingOptions.ignoreUnknownCharacters), forKey: property.0)
            }
            
        }
        var saveError:NSError?
        do {
        try self.managedObjectContext!.save()
        } catch let error as NSError {
        saveError = error
        NSLog("Unresolved error filling Empty Optionls \(saveError!), \(saveError!.userInfo)")
        
        }
        
    }
    
    func fillPointEmptyOptionals(_ aPoint:Point)
    {
        if aPoint.id == nil || aPoint.id == ""
        {
            aPoint.id = NSUUID().uuidString
            //print("ID vacio",aPoint.id)
        }
        for property in aPoint.entity.attributesByName
        {
            if property.1.attributeValueClassName == "NSString" && aPoint.value(forKey: property.0) == nil
            {
                //print(property.0," vacio")
                aPoint.setValue("", forKey: property.0)
            }
            else if property.1.attributeValueClassName == "NSDate" && aPoint.value(forKey: property.0) == nil
            {
                //print(property.0," vacio")
                aPoint.setValue(Date(), forKey: property.0)
            }
            else if property.1.attributeValueClassName == "NSData" && aPoint.value(forKey: property.0) == nil
            {
                //print(property.0," vacio")
                aPoint.setValue(Data(base64Encoded: "", options: NSData.Base64DecodingOptions.ignoreUnknownCharacters), forKey: property.0)
            }
            
        }
        var saveError:NSError?
        do {
        try self.managedObjectContext!.save()
        } catch let error as NSError {
        saveError = error
        NSLog("Unresolved error filling Empty Optionls \(saveError!), \(saveError!.userInfo)")
        
        }
        
    }
    
    func fillFileEmptyOptionals(_ aFile:File)
    {
        if aFile.id == nil || aFile.id == ""
        {
            aFile.id = NSUUID().uuidString
        }
        for property in aFile.entity.attributesByName
        {
            if property.1.attributeValueClassName == "NSString" && aFile.value(forKey: property.0) == nil
            {
                //print(property.0," vacio")
                aFile.setValue("", forKey: property.0)
            }
            else if property.1.attributeValueClassName == "NSDate" && aFile.value(forKey: property.0) == nil
            {
                //print(property.0," vacio")
                aFile.setValue(Date(), forKey: property.0)
            }
            else if property.1.attributeValueClassName == "NSData" && aFile.value(forKey: property.0) == nil
            {
                //print(property.0," vacio")
                aFile.setValue(Data(base64Encoded: "", options: NSData.Base64DecodingOptions.ignoreUnknownCharacters), forKey: property.0)
            }
            
        }
        var saveError:NSError?
        do {
        try self.managedObjectContext!.save()
        } catch let error as NSError {
        saveError = error
        NSLog("Unresolved error filling Empty Optionls \(saveError!), \(saveError!.userInfo)")
        
        }
        
    }
    
    func fillProofEmptyOptionals(_ aProof:Proof)
    {
        if aProof.id == nil || aProof.id == ""
        {
            aProof.id = NSUUID().uuidString
            //print("ID vacio",aProof.id)
        }
        for property in aProof.entity.attributesByName
        {
            if property.1.attributeValueClassName == "NSString" && aProof.value(forKey: property.0) == nil
            {
                //print(property.0," vacio")
                aProof.setValue("", forKey: property.0)
            }
            else if property.1.attributeValueClassName == "NSDate" && aProof.value(forKey: property.0) == nil
            {
                //print(property.0," vacio")
                aProof.setValue(Date(), forKey: property.0)
            }
            else if property.1.attributeValueClassName == "NSData" && aProof.value(forKey: property.0) == nil
            {
                //print(property.0," vacio")
                aProof.setValue(Data(base64Encoded: "", options: NSData.Base64DecodingOptions.ignoreUnknownCharacters), forKey: property.0)
            }
            
        }
        var saveError:NSError?
        do {
        try self.managedObjectContext!.save()
        } catch let error as NSError {
        saveError = error
        NSLog("Unresolved error filling Empty Optionls \(saveError!), \(saveError!.userInfo)")
        
        }
        
    }
    
    
   
    
}
