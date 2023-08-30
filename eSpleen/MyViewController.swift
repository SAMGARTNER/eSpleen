//
//  ViewController.swift
//  iKeepScore
//
//  Created by Samir Augusto Arias Gartner on 19/11/14.
//  Copyright (c) 2014 Samir Gartner. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData
import AddressBook
import MessageUI
import Contacts
//import Firebase
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

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class MyViewController: UIViewController,UIScrollViewDelegate,UIGestureRecognizerDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate,UISearchBarDelegate,UIPageViewControllerDataSource,UIPageViewControllerDelegate,MFMailComposeViewControllerDelegate, /*FBSDKLoginButtonDelegate,*/ UISearchControllerDelegate
{
    var collectionView: UICollectionView?
    var middleView: UIView = UIView()
    var middleIndexView:UIView = UIView()
    var contactsTVC:IKSContactsTVC?
    var userCardSelectionContactsTVC:IKSContactsTVC?
    var contactsSearchResultTVC:IKSContactsTVC?
    var userCardSelectionContactsSearchResultTVC:IKSContactsTVC?
    var scoresTableView:UITableView?
    var menuTableView:UITableView?
    var configurationButtonItem: UIBarButtonItem = UIBarButtonItem()
    var configurationButton: UIButton?
    var addMatchButton: UIButton?
    var removeMatchButton: UIButton?
    var addTrophyButton:UIButton?
    var trashButton:UIButton?
    var plusButtonItem: UIBarButtonItem?
    var editButton:UIButton?
    var panGestureRecognizer:UIPanGestureRecognizer?
    var tapGestureRecognizer:UITapGestureRecognizer?
    var theAppDelegate:AppDelegate?
    var dbManager:IKSDBManager?
    var editMode:Bool = false
    var selectedTrophies:NSMutableArray = NSMutableArray()
    
    var matchesFetchedResultsController:NSFetchedResultsController<NSFetchRequestResult>?
    var matchesFetchResultsEntityDescription:NSEntityDescription?
    var matchesSortDescriptor:NSSortDescriptor?
    var matchesPredicate:NSPredicate?
    var managedObjectContext:NSManagedObjectContext?
    
    var trophiesFetchedResultsController:NSFetchedResultsController<NSFetchRequestResult>?
    var leftTrophiesFetchedResultsController:NSFetchedResultsController<NSFetchRequestResult>?
    var rightTrophiesFetchedResultsController:NSFetchedResultsController<NSFetchRequestResult>?
    var trophiesFetchResultsEntityDescription:NSEntityDescription?
    var leftTrophiesFetchResultsEntityDescription:NSEntityDescription?
    var rightTophiesFetchResultsEntityDescription:NSEntityDescription?
    var trophiesSortDescriptor:NSSortDescriptor?
    var leftTrophiesSortDescriptor:NSSortDescriptor?
    var rightTrophiesSortDescriptor:NSSortDescriptor?

    var trophiesPredicate:NSPredicate?
    var leftTrophiesPredicate:NSPredicate?
    var rightTrophiesPredicate:NSPredicate?
    
    var matchesArray:NSMutableArray = NSMutableArray()
    var trophiesArray:NSMutableArray = NSMutableArray()
    var leftTrophiesArray:NSMutableArray = NSMutableArray()
    var rightTrophiesArray:NSMutableArray = NSMutableArray()
    var addressBook :CNContactStore?
    var addressBookContactsMutableArray: NSMutableArray?
    
    var userCardSelectionAddressBookContactsMutableArray: NSMutableArray?
    
    var addressBookContactsSearchResultsMutableArray: NSMutableArray?
    
    var userCardSelectionAddressBookContactsSearchResultsMutableArray: NSMutableArray?
    
    var selectedContactsReferences:NSMutableArray = NSMutableArray()
    var userCardSelectionSelectedContactsReferences:NSMutableArray = NSMutableArray()
    var cancelPersonsSelectionBarButtonItem:UIBarButtonItem?
    var commitPersonsSelectionBarButtonItem:UIBarButtonItem?
    
    var cancelPersonCardSelectionBarButtonItem:UIBarButtonItem?
    var commitPersonCardSelectionBarButtonItem:UIBarButtonItem?
    
    var trophyNameTextFiled:UITextField?
    var contactsSearchController:UISearchController?
    var userCardSelectionContactsSearchController:UISearchController?
    var tutorialViewsMutableArray:NSMutableArray = NSMutableArray()
    var tutorialPageViewController:BCLTutorialPageViewController?
    var temporalFirstRun:Bool = true
    var myMail: MFMailComposeViewController!
    //var loginButton: FBSDKLoginButton?
    var facebookContacts:Bool = false
    var contactsKindSegmentedController:UISegmentedControl?
    var facebookContactsMutableArray: NSMutableArray?
    var updatedFacebookContactsMutableArray: NSMutableArray?
    var aNewClientNavigationController:UINavigationController?
    var userCardSelectionANewClientNavigationController:UINavigationController?
    var facebookContactsSearchResultsMutableArray: NSMutableArray?
    var readMoreIndexPath:IndexPath?
    var editingIndexPath:IndexPath?
    var userCardIndexLocation:Int?
    var userCardSuggestionUsed:Bool = false
    var userCardID:String? = nil
    var userCard:CNContact? = nil
    

override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        let useFacebookContacts:Bool? = (defaults.object(forKey: "useFacebookContacts") as? Bool)
        if useFacebookContacts != nil
        {
            self.facebookContacts = useFacebookContacts!
        }
        
        self.theAppDelegate = UIApplication.shared.delegate as? AppDelegate
        self.dbManager = theAppDelegate?.dbManager
        self.managedObjectContext = self.dbManager?.managedObjectContext
        self.matchesFetchResultsEntityDescription = NSEntityDescription.entity(forEntityName: "Match", in: managedObjectContext!)
        //se requiere descriptor de ordenamiento
        self.matchesSortDescriptor = NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Match")
        fetchRequest.sortDescriptors = [matchesSortDescriptor!]
        
        self.matchesFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        self.matchesFetchedResultsController?.delegate = self
        
        self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(MyViewController.panReceived(_:)))
        self.panGestureRecognizer?.delegate = self
        self.panGestureRecognizer?.cancelsTouchesInView = false
        self.view.addGestureRecognizer(self.panGestureRecognizer!)
        
        self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MyViewController.tapReceived(_:)))
        self.tapGestureRecognizer?.delegate = self

        self.tapGestureRecognizer?.cancelsTouchesInView = false
        self.view.addGestureRecognizer(self.tapGestureRecognizer!)
        //se deberia agregar al abrir el menu o buscar la forma de filtrar quien lo llama
        
        
        
        self.configurationButtonItem.target = self
        self.configurationButtonItem.action = #selector(MyViewController.showConfigurationMenu)
        self.configurationButtonItem.style = UIBarButtonItem.Style.plain
        let matchImage = UIImage(named: "gear.png")
        self.configurationButtonItem.image = matchImage
        
        self.middleView.frame = CGRect(x: 0, y:UIScreen.main.bounds.size.height * 0.3104166667+20, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height * (pow(UIScreen.main.bounds.size.height,-0.3238529486)));
        self.middleView.backgroundColor = UIColor(red: CGFloat(231.0/255.0), green: CGFloat(237.0/255.0), blue: CGFloat(234.0/255.0), alpha: CGFloat(1.0))
        
        
        let twentyFive:CGFloat = ((self.middleView.frame.size.height * 0.7692307692) / 2)
        let yPost:CGFloat = self.middleView.frame.size.height * 0.1153846154
        addTrophyButton = UIButton(type: UIButton.ButtonType.custom)
        addTrophyButton?.addTarget(self, action: #selector(MyViewController.addTrophyToCurrentMatch), for: UIControl.Event.touchUpInside)
        addTrophyButton?.setImage(self.getTintedImage(UIImage(named: "add_trophy.png")!, withColor: UIColor(red: CGFloat(51.0/255.0), green: CGFloat(51.0/255.0), blue: CGFloat(51.0/255.0), alpha: CGFloat(1.0))) , for: UIControl.State())
                addTrophyButton?.frame = CGRect(x: ((self.middleView.frame.size.width/4) * 4) - ((self.middleView.frame.size.width/4)/2) - twentyFive, y:yPost, width: self.middleView.frame.size.height * 0.7692307692, height: self.middleView.frame.size.height * 0.7692307692)
        
        editButton = UIButton(type: UIButton.ButtonType.custom)
        editButton?.setImage(self.getTintedImage(UIImage(named: "editing.png")!, withColor: UIColor(red: CGFloat(51.0/255.0), green: CGFloat(51.0/255.0), blue: CGFloat(51.0/255.0), alpha: CGFloat(1.0))) , for: UIControl.State())
        editButton?.frame = CGRect(x: ((self.middleView.frame.size.width/4) * 2) - ((self.middleView.frame.size.width/4)/2) - twentyFive, y:yPost, width: self.middleView.frame.size.height * 0.7692307692, height: self.middleView.frame.size.height * 0.7692307692)
        editButton?.addTarget(self, action: #selector(MyViewController.setIsEditing), for: UIControl.Event.touchUpInside)
        
        configurationButton = UIButton(type: UIButton.ButtonType.custom)
        configurationButton?.setImage(self.getTintedImage(UIImage(named: "gear.png")!, withColor: UIColor(red: CGFloat(51.0/255.0), green: CGFloat(51.0/255.0), blue: CGFloat(51.0/255.0), alpha: CGFloat(1.0))) , for: UIControl.State())
        configurationButton?.frame = CGRect(x: ((self.middleView.frame.size.width/4) * 1) - ((self.middleView.frame.size.width/4)/2) - twentyFive, y:yPost, width: self.middleView.frame.size.height * 0.7692307692, height: self.middleView.frame.size.height * 0.7692307692)
        configurationButton?.addTarget(self, action: #selector(MyViewController.showConfigurationMenu), for: UIControl.Event.touchUpInside)
        
        addMatchButton = UIButton(type: UIButton.ButtonType.custom)
        addMatchButton?.setImage(self.getTintedImage(UIImage(named: "add_match.png")!, withColor: UIColor(red: CGFloat(51.0/255.0), green: CGFloat(51.0/255.0), blue: CGFloat(51.0/255.0), alpha: CGFloat(1.0))) , for: UIControl.State())
        addMatchButton?.frame = CGRect(x: ((self.middleView.frame.size.width/4) * 3) - ((self.middleView.frame.size.width/4)/2) - twentyFive, y:yPost, width: self.middleView.frame.size.height * 0.7692307692, height: self.middleView.frame.size.height * 0.7692307692)
        addMatchButton?.addTarget(self, action: #selector(MyViewController.showContactsModalView), for: UIControl.Event.touchUpInside)
        
        removeMatchButton = UIButton(type: UIButton.ButtonType.custom)
        removeMatchButton?.setImage(self.getTintedImage(UIImage(named: "remove_match.png")!, withColor: UIColor(red: CGFloat(51.0/255.0), green: CGFloat(51.0/255.0), blue: CGFloat(51.0/255.0), alpha: CGFloat(1.0))) , for: UIControl.State())
        removeMatchButton?.frame = CGRect(x: ((self.middleView.frame.size.width/4) * 2) - ((self.middleView.frame.size.width/4)/2) - twentyFive, y:yPost, width: self.middleView.frame.size.height * 0.7692307692, height: self.middleView.frame.size.height * 0.7692307692)
        removeMatchButton?.addTarget(self, action: #selector(MyViewController.deleteCurrentMatch), for: UIControl.Event.touchUpInside)
        
        self.middleView.addSubview(addTrophyButton!)
        self.middleView.addSubview(self.addMatchButton!)
        self.middleView.addSubview(self.removeMatchButton!)
        
        self.middleView.addSubview(self.configurationButton!)
        
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10.0, bottom: 0, right: 10.0)
        layout.itemSize = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height * 0.3104166667)
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        
        //self.automaticallyAdjustsScrollViewInsets = false
        self.collectionView?.contentInsetAdjustmentBehavior = .never;
        self.collectionView = UICollectionView(frame: CGRect(x: 0, y:20, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height * 0.3104166667), collectionViewLayout: layout)
        self.collectionView!.dataSource = self
        self.collectionView!.delegate = self
        self.collectionView!.bounces = false
        self.collectionView!.showsHorizontalScrollIndicator = false
        self.collectionView!.register(IKSMatchCell.self, forCellWithReuseIdentifier: "aMatchCell")
        self.collectionView!.backgroundColor = UIColor(red: CGFloat(214.0/255.0), green: CGFloat(219.0/255.0), blue: CGFloat(217.0/255.0), alpha: CGFloat(1.0))
        let middleViewHeight = middleView.frame.size.height
        let topViewHeight = collectionView?.frame.size.height
        let phoneHeight = UIScreen.main.bounds.size.height
        self.scoresTableView = UITableView(frame: CGRect(x:0,y:topViewHeight! + 20 + middleViewHeight,width:UIScreen.main.bounds.size.width,height:(phoneHeight - middleViewHeight - topViewHeight!)))
        self.scoresTableView!.register(IKSTrophyCell.self, forCellReuseIdentifier: "aTrophyCell")
        self.scoresTableView!.register(IKSTrophyBigCell.self, forCellReuseIdentifier: "aBigTrophyCell")
        self.scoresTableView?.backgroundColor = UIColor(red: CGFloat(51.0/255.0), green: CGFloat(51.0/255.0), blue: CGFloat(51.0/255.0), alpha: CGFloat(1.0))
        self.scoresTableView?.decelerationRate = UIScrollView.DecelerationRate.normal
        self.scoresTableView?.delegate = self
        self.scoresTableView?.dataSource = self
        self.scoresTableView?.separatorColor = UIColor.white
        self.scoresTableView?.rowHeight = 88
        self.scoresTableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 44, right: 0)
        
        
        let cellTapGesture:UITapGestureRecognizer? = UITapGestureRecognizer()
        cellTapGesture?.delegate = self
        cellTapGesture?.addTarget(self, action: #selector(MyViewController.cellTapped(_:)))
        cellTapGesture?.cancelsTouchesInView = false
        
        let cellLongPressGesture:UILongPressGestureRecognizer? = UILongPressGestureRecognizer(target: self, action: #selector(MyViewController.cellLongPressed(_:)))
        let matchCellLongPressGesture:UILongPressGestureRecognizer? = UILongPressGestureRecognizer(target: self, action: #selector(MyViewController.matchCellLongPressed(_:)))
        
        

        self.scoresTableView?.addGestureRecognizer(cellTapGesture!)
        self.scoresTableView?.addGestureRecognizer(cellLongPressGesture!)
        
        self.collectionView?.addGestureRecognizer(matchCellLongPressGesture!)
        
        self.view.addSubview(self.collectionView!)
        self.view.addSubview(self.middleView)
        self.view.addSubview(self.scoresTableView!)
        
        self.collectionView?.contentOffset.x = 10
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.fetchEntities()
        self.fetchTrophies()
        self.unlockButtons()
    
        drawDummyMatch()
        loadDefaultContact()
        self.extendedLayoutIncludesOpaqueBars = true
        
    }
    
     override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.unlockButtons()
        if self.isFirstRun() == true
        {
        self.loadTutorial()
        }
        else
        {
            
        }
        self.loadUserCardSelectionContacts()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    
     func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        
    }
    
     func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if  collectionView == self.collectionView
        {
            self.cleanSelectedTrohpies()
            self.fetchTrophies()
            self.scoresTableView?.reloadData()

            self.unlockButtons()

        }

    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if  scrollView == self.collectionView
        {
            
        self.unlockButtons()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        if  scrollView == self.collectionView
        {
            if self.editMode == true
            {
                self.setIsEditing()
            }
            
            if self.editingIndexPath != nil
            {
            self.editingIndexPath = nil
            }
            
            if self.matchesArray.count > 0
            {
                self.lockButtons()
                if self.readMoreIndexPath != nil
                {
                    self.scoresTableView?.beginUpdates()
                    let oldIndexPath:IndexPath? = self.readMoreIndexPath
                    self.readMoreIndexPath = nil
                    
                    if oldIndexPath != nil
                    {
                        self.scoresTableView?.reloadRows(at: [oldIndexPath!], with: UITableView.RowAnimation.fade)
                        
                    }
                    self.scoresTableView?.endUpdates()
                }
                
                
            }
        
        }
    }
    
    
     func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if  scrollView == self.collectionView
        {
        }
    }

    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    {
        if  scrollView == self.collectionView
        {
        var nextIndex: Int = 0
        let matchesCount: CGFloat = CGFloat(matchesArray.count)
        let widthC = self.collectionView?.collectionViewLayout.collectionViewContentSize.width
        let someValue = scrollView.contentOffset.x/((widthC!)/matchesCount)+1.0
        let currentIndex: Int = Int(round(someValue))
        if (velocity.x == 0.0)
        {
            nextIndex = currentIndex
            targetContentOffset.pointee = CGPoint(x: positionForSection(nextIndex),y: 0.0)
        }
        else if (velocity.x > 0.0)
        {
            
            nextIndex = currentIndex + 1
            targetContentOffset.pointee = CGPoint(x: positionForSection(nextIndex),y: 0.0)
        }
        else
        {
            nextIndex = currentIndex - 1
            targetContentOffset.pointee = CGPoint(x: positionForSection(nextIndex),y: 0.0)
            
        }
        }
        
    }
    
    func getClosestSectionToXPoint(_ point: CGFloat) -> Int
    {
        
        if(point <= 10)
        {
            return 1
            
        }
        else if(point >= 310*(CGFloat(matchesArray.count - 1)))
        {
            return matchesArray.count;
        }
        let widthC = self.collectionView?.collectionViewLayout.collectionViewContentSize.width
        let matches = CGFloat(self.matchesArray.count)
        return Int(round(point/((widthC! + 90)/matches)+1.0))
        
    }
    
    func positionForSection(_ section: Int) -> CGFloat
    {
        
        var sectionCorrected = section
        if(sectionCorrected >= matchesArray.count)
        {
            sectionCorrected = matchesArray.count
        }
        else if(sectionCorrected == 0)
        {
            sectionCorrected = 1
        }
        let correctedSection = CGFloat(sectionCorrected-1)
        let xPosition = CGFloat((UIScreen.main.bounds.size.width*correctedSection)+10)
        return xPosition
        
    }
    
    func currentSection() -> Int
    {
    let offset = self.collectionView?.contentOffset.x
    return Int((offset! - 10.0)/UIScreen.main.bounds.size.width)
    }
    
    @objc func showConfigurationMenu()
    {
        if menuTableView == nil
        {
            self.menuTableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width * 0.8125, height: UIScreen.main.bounds.size.height), style:UITableView.Style.plain)
            self.menuTableView?.dataSource = self
            self.menuTableView?.delegate = self
            self.menuTableView?.contentInset = UIEdgeInsets(top: 20,left: 0,bottom: 0,right: 0)
            self.menuTableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
            self.menuTableView?.separatorInset = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 11)
            self.menuTableView?.separatorColor = UIColor.black
            self.menuTableView?.backgroundColor = UIColor.black
            self.menuTableView?.isScrollEnabled = false
            self.menuTableView?.register(IKSMenuCell.self, forCellReuseIdentifier: "aMenuCell")
            self.menuTableView?.register(IKSMenuCell.self, forCellReuseIdentifier: "logoCell")
        }
        if(self.navigationController?.view.frame.origin.x == 0){ //only show the menu if it is not already shown
            self.navigationController?.view.superview?.addSubview(menuTableView!)
            self.navigationController?.view.superview?.sendSubviewToBack(menuTableView!)
            self.showMenu()
            self.lockButtons()
            let oldIndexPath:IndexPath? = self.readMoreIndexPath
            self.readMoreIndexPath = nil
            self.scoresTableView?.beginUpdates()
            
            if oldIndexPath != nil
            {
            self.scoresTableView?.deselectRow(at: oldIndexPath!, animated: false)
                self.scoresTableView?.reloadRows(at: [oldIndexPath!], with: UITableView.RowAnimation.fade)
            }
            self.scoresTableView?.endUpdates()
            for  aCell in self.scoresTableView!.visibleCells
            {
                aCell.isUserInteractionEnabled = false
            }
            self.plusButtonItem?.isEnabled = false
            self.scoresTableView?.isScrollEnabled = false
            self.navigationController?.view.layer.shadowColor = UIColor.black.cgColor
            self.navigationController?.view.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
            self.navigationController?.view.layer.shadowOpacity = 0.4
            self.navigationController?.view.layer.shadowRadius = 5.0
            self.navigationController?.view.clipsToBounds = false
            self.navigationController?.view.layer.masksToBounds = false
            self.scoresTableView?.resignFirstResponder()
            self.menuTableView?.becomeFirstResponder()
            self.scoresTableView?.isScrollEnabled = false
        }
        else
        {
            self.hideMenu()
            self.unlockButtons()
            self.readMoreIndexPath = nil
            self.scoresTableView?.beginUpdates()
            let oldIndexPath:IndexPath? = self.readMoreIndexPath
            self.readMoreIndexPath = nil

            if oldIndexPath != nil
            {
                self.scoresTableView?.reloadRows(at: [oldIndexPath!], with: UITableView.RowAnimation.fade)
            }
            self.scoresTableView?.endUpdates()
            self.scoresTableView?.isScrollEnabled = true
            for  aCell in self.scoresTableView!.visibleCells
            {
                aCell.isUserInteractionEnabled = true
            }
            self.plusButtonItem?.isEnabled = true
            self.menuTableView?.resignFirstResponder()
            self.scoresTableView?.becomeFirstResponder()
            self.scoresTableView?.isScrollEnabled = true
        }

    
    }
    
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView == self.menuTableView
        {
        return 44
        }
        else if tableView == self.contactsTVC?.tableView
        {
        return 44
        }
        else if tableView == self.contactsSearchResultTVC?.tableView
        {
        return 44
        }
        else if tableView == self.scoresTableView
        {
            if self.readMoreIndexPath != nil && self.readMoreIndexPath!.row == indexPath.row
            {
            return 176
            }
            else
            {
            return 88
            }
        }
        return 88
    }
    
    func showMenu()
    {
   
        let y  = self.navigationController?.view.frame.origin.y
        let w  = self.navigationController?.view.frame.size.width
        let h  = self.navigationController?.view.frame.size.height
        let aRect: CGRect = CGRect(x: UIScreen.main.bounds.size.width * 0.8125, y: y!, width: w!, height: h!)
        let mynav: UINavigationController = self.navigationController!
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions(), animations: {mynav.view.frame = aRect}, completion: nil)
    

    }
    
    func hideMenu()
    {
        
        let y: CGFloat? = self.navigationController?.view.frame.origin.y
        let w: CGFloat? = self.navigationController?.view.frame.size.width
        let h: CGFloat? = self.navigationController?.view.frame.size.height
        let aRect: CGRect = CGRect(x: 0.0, y: y!, width: w!, height: h!)
        let mynav: UINavigationController = self.navigationController!
        UIView.animate(withDuration: 0.3, delay:0.0, options: UIView.AnimationOptions(), animations: {mynav.view.frame = aRect}, completion: {
        completion in
            
            
            self.scoresTableView?.isScrollEnabled = true
            for aCell in (self.scoresTableView?.visibleCells)!
            {
            aCell.isUserInteractionEnabled = true
            }
            self.menuTableView?.resignFirstResponder()
            self.menuTableView?.removeFromSuperview()
            self.menuTableView = nil
            self.scoresTableView?.becomeFirstResponder()
            self.scoresTableView?.isScrollEnabled = true
            self.plusButtonItem?.isEnabled = true
        
        })
    
    }
    
    func hideMenuNoAnimated()
    {
        
        let y: CGFloat? = self.navigationController?.view.frame.origin.y
        let w: CGFloat? = self.navigationController?.view.frame.size.width
        let h: CGFloat? = self.navigationController?.view.frame.size.height
        let aRect: CGRect = CGRect(x: 0.0, y: y!, width: w!, height: h!)
        let mynav: UINavigationController = self.navigationController!
        mynav.view.frame = aRect
        self.scoresTableView?.isScrollEnabled = true
            for aCell in (self.scoresTableView?.visibleCells)!
            {
                aCell.isUserInteractionEnabled = true
            }
            self.menuTableView?.resignFirstResponder()
            self.menuTableView?.removeFromSuperview()
            self.menuTableView = nil
            self.scoresTableView?.becomeFirstResponder()
            self.scoresTableView?.isScrollEnabled = true
            self.plusButtonItem?.isEnabled = true
        
    }
    
    @objc func panReceived(_ tapGestureRecognizer: UIPanGestureRecognizer )
    {
        if tapGestureRecognizer.view?.hitTest(tapGestureRecognizer.location(in: tapGestureRecognizer.view), with: nil) == self.scoresTableView
        {
        }
        if tapGestureRecognizer.view?.hitTest(tapGestureRecognizer.location(in: tapGestureRecognizer.view), with: nil) == self.collectionView
        {
        }
    var navcontrollerviewframesizewidth = self.navigationController?.view.frame.size.width
    var navcontrollerviewframesizeheight = self.navigationController?.view.frame.size.height
    var navcontrollerviewframeoriginx = self.navigationController?.view.frame.origin.x
    var navcontrollerviewframeoriginy = self.navigationController?.view.frame.origin.y
    let superviews = self.navigationController?.view?.superview
    let amount  = tapGestureRecognizer.translation(in: superviews!)//error potencial verificar superview antes de ejecutar
    if(self.navigationController?.view.frame.origin.x > 0)
    {
    if(tapGestureRecognizer.numberOfTouches > 0)
    {
        navcontrollerviewframesizewidth = self.navigationController?.view.frame.size.width
        navcontrollerviewframesizeheight = self.navigationController?.view.frame.size.height
        navcontrollerviewframeoriginx = self.navigationController?.view.frame.origin.x
        
    self.navigationController?.view.frame = CGRect(x: navcontrollerviewframeoriginx! + amount.x , y: navcontrollerviewframeoriginy!, width: navcontrollerviewframesizewidth!, height: navcontrollerviewframesizeheight!)
    tapGestureRecognizer.setTranslation(CGPoint(x: 0, y: 0), in:self.navigationController?.view.superview)
    
    if (self.navigationController?.view.frame.origin.x > UIScreen.main.bounds.size.width * 0.8125)
    {
    navcontrollerviewframesizewidth = self.navigationController?.view.frame.size.width
    navcontrollerviewframesizeheight = self.navigationController?.view.frame.size.height
    navcontrollerviewframeoriginy = self.navigationController?.view.frame.origin.y
    self.navigationController?.view.frame = CGRect(x: UIScreen.main.bounds.size.width * 0.8125, y: navcontrollerviewframeoriginy!, width: navcontrollerviewframesizewidth!, height: navcontrollerviewframesizeheight!)
    }
    
    }
    
        if(tapGestureRecognizer.state == UIGestureRecognizer.State.ended)
        {
            
            let aView = self.navigationController?.view
            let navigationViewBoundsSizeWidth = aView?.bounds.size.width
            if(self.navigationController?.view.frame.origin.x <= (navigationViewBoundsSizeWidth!/2))
                {
                    self.hideMenu()
                    self.unlockButtons()
                    self.scoresTableView?.beginUpdates()
                    
                    let oldIndexPath:IndexPath? = self.readMoreIndexPath
                    self.readMoreIndexPath = nil
                    if oldIndexPath != nil
                    {
                        self.scoresTableView?.reloadRows(at: [oldIndexPath!], with: UITableView.RowAnimation.fade)
                    }
                    self.scoresTableView?.endUpdates()
            }
            else
                {
                    let y: CGFloat? = self.navigationController?.view.frame.origin.y
                    let w: CGFloat? = self.navigationController?.view.frame.size.width
                    let h: CGFloat? = self.navigationController?.view.frame.size.height
                    let aRect: CGRect = CGRect(x: UIScreen.main.bounds.size.width * 0.8125, y: y!, width: w!, height: h!)
                    let mynav: UINavigationController = self.navigationController!
                UIView.animate(withDuration: 0.15, delay: 0.0, options: UIView.AnimationOptions(), animations: {mynav.view.frame = aRect}, completion: nil)
                    
                }
            
            
        }
    }
    else
    {
        
        self.plusButtonItem?.isEnabled = true
        self.hideMenuNoAnimated()
        
    }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {

        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {

        return false
    }
    
    @objc func tapReceived(_ tapGestureRecognizer:UITapGestureRecognizer)
    {
        let aView = self.navigationController?.view
        let navigationViewBoundsSizeWidth = aView?.bounds.size.width
        if(self.navigationController?.view.frame.origin.x >= (navigationViewBoundsSizeWidth!/2))
        {
            self.hideMenu()
            self.unlockButtons()
        }
        
    if(self.navigationController?.view.frame.origin.x >= 0)
        {
    }
    }
    
    func getTintedImage(_ image:UIImage, withColor tintColor: UIColor) -> UIImage
    {
    UIGraphicsBeginImageContextWithOptions(image.size, false, UIScreen.main.scale)
    let context:CGContext = UIGraphicsGetCurrentContext()!
    
    
    context.translateBy(x: 0, y: image.size.height)
    context.scaleBy(x: 1.0, y: -1.0)
    
    let rect: CGRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
    
    // draw alpha-mask
    context.setBlendMode(CGBlendMode.normal)
    context.draw(image.cgImage!, in: rect)
    
    // draw tint color, preserving alpha values of original image
    context.setBlendMode(CGBlendMode.sourceIn)
    tintColor.setFill()
    context.fill(rect)
    
    let coloredImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return coloredImage
    }
    
     func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
     func collectionView(_ collectionView: UICollectionView,numberOfItemsInSection section: Int) -> Int
    {
        return self.matchesArray.count
        
    }
    
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //print("collectionview cell for item")
        let matchCell: IKSMatchCell = collectionView.dequeueReusableCell(withReuseIdentifier: "aMatchCell", for: indexPath) as! IKSMatchCell
        if indexPath.row < self.matchesArray.count
        {
        let aMatch:Match = self.matchesArray.object(at: indexPath.row) as! Match
            self.dbManager?.fillMatchEmptyOptionals(aMatch)
        let cornerSortDescriptor = NSSortDescriptor(key: "corner", ascending: true)
            let matchesParticipans:NSArray =  NSArray(array: aMatch.participants!.allObjects).sortedArray(using: [cornerSortDescriptor]) as NSArray
        //error potencial si falta algun participante
        //si se encuentra solo un participante se deberia corregir
        if matchesParticipans.count == 2
        
        {
            let participationA:Participation = matchesParticipans.object(at: 0) as! Participation
            let participationB:Participation = matchesParticipans.object(at: 1) as! Participation
            
            self.dbManager?.fillParticipationEmptyOptionals(participationA)
            self.dbManager?.fillParticipationEmptyOptionals(participationB)
            
            var participationAForenames:NSString? = participationA.player.forenames
            let participationASurnames:NSString? = participationA.player.surenames
            
            var participationBForenames:NSString? = participationB.player.forenames
            let participationBSurenames:NSString? = participationB.player.surenames
            
            let participationAPlayerImageData:Data? = participationA.player.picture
            let participationBPlayerImageData:Data? = participationB.player.picture
            
            
            
            let locatA = participationAForenames?.range(of: " ")
            if locatA?.location != NSNotFound
            {
                let index = locatA?.location
                if (participationAForenames != nil)
                {
                    participationAForenames = participationAForenames?.substring(to: index!) as NSString?
                }
           
                
            }
            
            let locatB = participationBForenames?.range(of: " ")
            if locatB?.location != NSNotFound
            {
                let index = locatB?.location
                if (participationBForenames != nil)
                {
                    participationBForenames = participationBForenames?.substring(to: index!) as NSString?
                }
            }
            
            var rightScoreCount:Int? = 0
            var leftScoreCount:Int? = 0
            var participationAPlayerImage:UIImage?
            var participationBPlayerImage:UIImage?
            var playerANameString:String?
            var playerBNameString:String?
            
            
            
            if self.getPreferedLanguage() == "ja-JP"
            {
                if participationAForenames != nil && participationASurnames != nil
                {
                    matchCell.leftCornerPlayerForenamesLabel?.text = "\(participationASurnames! as String) \(participationAForenames! as String)"
                    //matchCell.leftCornerPlayerForenamesLabel?.text =  (participationASurnames! as String) + (NSString(string: " ") as String) + (participationAForenames! as String)
                    //playerANameString = ((participationASurnames! as String + (NSString(string: " ") as String) + (participationAForenames! as String) as String))
                    playerANameString = "\(participationASurnames! as String) \(participationAForenames! as String)"
                }
                else if participationAForenames != nil && participationASurnames == nil
                {
                    matchCell.leftCornerPlayerForenamesLabel?.text = participationAForenames as String?
                    playerANameString = participationAForenames as String?
                }
                else if participationAForenames == nil && participationASurnames != nil
                {
                    matchCell.leftCornerPlayerForenamesLabel?.text = participationASurnames as String?
                    playerANameString = participationASurnames as String?
                }
                
                if participationBForenames != nil && participationBSurenames != nil
                {
                    //matchCell.rightCornerPlayerForenamesLabel?.text = (participationBSurenames! as String) + (NSString(string: " ") as String) + (participationBForenames! as String)
                    //playerBNameString =  ((participationBSurenames! as String + (NSString(string: " ")as String) + (participationBForenames! as String) as String))
                    matchCell.rightCornerPlayerForenamesLabel?.text = "\(participationBSurenames! as String) \(participationBForenames! as String)"
                    playerBNameString =  "\(participationBSurenames! as String)  \(participationBForenames! as String)"
                }
                else if participationBForenames != nil && participationBSurenames == nil
                {
                    matchCell.rightCornerPlayerForenamesLabel?.text = participationBForenames as String?
                    playerBNameString =  participationBForenames as String?
                }
                else if participationBForenames == nil && participationBSurenames != nil
                {
                    matchCell.rightCornerPlayerForenamesLabel?.text = participationBSurenames as String?
                    playerBNameString = participationBSurenames as String?
                }
            }
            else
            {
                if participationAForenames != nil && participationASurnames != nil
                {
                    //matchCell.leftCornerPlayerForenamesLabel?.text = participationAForenames! as String + (NSString(string: " ") as String) + (participationASurnames! as String)
                    //playerANameString = (participationAForenames! as String) + (NSString(string: " ") as String) + (participationASurnames! as String)
                    matchCell.leftCornerPlayerForenamesLabel?.text = "\(participationAForenames! as String) \(participationASurnames! as String)"
                    playerANameString = "\(participationAForenames! as String) \(participationASurnames! as String)"
                }
                else if participationAForenames != nil && participationASurnames == nil
                {
                    matchCell.leftCornerPlayerForenamesLabel?.text = participationAForenames as String?
                    playerANameString = participationAForenames as String?
                }
                else if participationAForenames == nil && participationASurnames != nil
                {
                    matchCell.leftCornerPlayerForenamesLabel?.text = participationASurnames as String?
                    playerANameString = participationASurnames as String?
                }
                
                if participationBForenames != nil && participationBSurenames != nil
                {
                    //matchCell.rightCornerPlayerForenamesLabel?.text = (participationBForenames! as String) + (NSString(string: " ") as String) + (participationBSurenames! as String)
                    //playerBNameString =  (participationBForenames! as String) + (NSString(string: " ")as String) + (participationBSurenames! as String)
                    
                    matchCell.rightCornerPlayerForenamesLabel?.text = "\(participationBForenames! as String) \(participationBSurenames! as String)"
                    playerBNameString =  "\(participationBForenames! as String) \(participationBSurenames! as String)"
                }
                else if participationBForenames != nil && participationBSurenames == nil
                {
                    matchCell.rightCornerPlayerForenamesLabel?.text = participationBForenames as String?
                    playerBNameString =  participationBForenames as String?
                }
                else if participationBForenames == nil && participationBSurenames != nil
                {
                    matchCell.rightCornerPlayerForenamesLabel?.text = participationBSurenames as String?
                    playerBNameString = participationBSurenames as String?
                }
            }
            
            
            
            if  participationAPlayerImageData != nil && participationAPlayerImageData != Data(base64Encoded: "", options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
            {
                participationAPlayerImage = UIImage(data: participationA.player.picture! as Data)
                matchCell.leftCornerPlayerView?.image = participationAPlayerImage
            }
            else
            {
                
                let myStringArr:NSArray = (playerANameString?.components(separatedBy: CharacterSet(charactersIn: " ")))! as NSArray
                var nameInitials:String? = ""
                let myArray:NSArray = NSArray(array: myStringArr)
                for aString in myArray as NSArray
                {
                    if (aString as? String != nil)
                    {
                        if (aString as! NSString).length > 0
                        {
                            //nameInitials = nameInitials! + aString.substringToIndex(1).capitalizedString
                            nameInitials = "\(nameInitials!)\((aString as AnyObject).substring(to: 1).capitalized)"
                        }
                    
                    }
                    
                }
            
                let playerImage:UIImage = self.imageFromText(nameInitials!)!
                matchCell.leftCornerPlayerView?.image = playerImage
            }
            
            
            if  participationBPlayerImageData != nil && participationBPlayerImageData != Data(base64Encoded: "", options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
            {
                participationBPlayerImage = UIImage(data: participationB.player.picture! as Data)
                matchCell.rightCornerPlayerView?.image = participationBPlayerImage
            }
            else
            {
                let myStringArr = playerBNameString?.components(separatedBy: CharacterSet(charactersIn: " "))
                var nameInitials:String? = ""
                let myArray:NSArray = NSArray(array: myStringArr!)
                for aString in myArray as NSArray
                {
                    if (aString as? String != nil)
                    {
                            if (aString as! NSString).length > 0
                            {
                    //nameInitials = nameInitials! + aString.substringToIndex(1).capitalizedString
                                nameInitials = "\(nameInitials!)\((aString as AnyObject).substring(to: 1).capitalized)"
                            }
                        
                    }
                }
                
                let playerImage:UIImage = self.imageFromText(nameInitials!)!
                
                matchCell.rightCornerPlayerView?.image = playerImage
                
            }
            
            
            for aTrophy:Trophy in participationB.trophies.allObjects as! [Trophy]
            {
                let value = aTrophy.score!.int32Value
                if aTrophy.substracts
                {
                    rightScoreCount = rightScoreCount! - Int(value)
                }
                else
                {
                    rightScoreCount = rightScoreCount! + Int(value)
                }
                
            }
            
            for aTrophy:Trophy in participationA.trophies.allObjects as! [Trophy]
            {
                let value = aTrophy.score!.int32Value
                
                if aTrophy.substracts
                {
                    leftScoreCount = leftScoreCount! - Int(value)
                }
                else
                {
                    leftScoreCount = leftScoreCount! + Int(value)
                }
            }
            
            
            
            
            matchCell.setLeftScore(100 - rightScoreCount! + leftScoreCount!, andRightScoreAnimated: 100 - leftScoreCount! + rightScoreCount!)
            
            matchCell.matchNumberLabel?.text = "\(indexPath.row + 1 )"
            matchCell.setNeedsDisplay()
        }
        }
        return matchCell
    }
    
    @objc func showContactsModalView()
    {
        if self.editMode == false
        {
            
            if self.facebookContacts
            {
                
                    if self.updatedFacebookContactsMutableArray != nil
                    {
                    self.facebookContactsMutableArray = self.updatedFacebookContactsMutableArray
                    self.updatedFacebookContactsMutableArray = nil
                    }
                    else
                    {
                    self.facebookContactsMutableArray = getStoredFacebookContacts()
                    }
                                //self.facebookContactsMutableArray = getStoredFacebookContacts()
                                if self.contactsSearchResultTVC == nil
                                {
                                    self.contactsSearchResultTVC = IKSContactsTVC()
                                    self.contactsSearchResultTVC?.tableView.dataSource = self
                                    self.contactsSearchResultTVC?.tableView.delegate = self
                                    self.contactsSearchResultTVC?.navigationItem.title = NSLocalizedString("Select 2 Persons",comment:"")
                                    self.contactsSearchResultTVC?.navigationController?.navigationBar.barStyle = UIBarStyle.default
                                    self.contactsSearchResultTVC?.navigationController?.navigationBar.setBackgroundImage(self.imageWithColor(UIColor(red: 65/255, green: 93/255, blue: 174/255, alpha: 1.0)), for: UIBarMetrics.default)
                                    
                                    self.contactsTVC?.navigationItem.title = NSLocalizedString("Select 2 Persons",comment:"")
                                    
                                    
                                }
                                
                                if self.contactsSearchController == nil
                                {
                                    self.contactsSearchController = UISearchController(searchResultsController: self.contactsSearchResultTVC!)
                                    self.contactsSearchController?.hidesNavigationBarDuringPresentation = true
                                    //self.contactsSearchController?.dimsBackgroundDuringPresentation = false
                                    self.contactsSearchController?.searchBar.delegate = self
                                    self.contactsSearchController?.searchBar.sizeToFit()
                                }
                                
                                if self.contactsTVC == nil
                                {
                                    self.contactsTVC = IKSContactsTVC()
                                    self.cancelPersonsSelectionBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Cancel",comment:""), style: UIBarButtonItem.Style.plain, target: self, action: #selector(MyViewController.cancelPersonsSelection))
                                    self.contactsTVC?.navigationItem.leftBarButtonItem = self.cancelPersonsSelectionBarButtonItem
                                    self.commitPersonsSelectionBarButtonItem = UIBarButtonItem(title: NSLocalizedString("OK",comment:""), style: UIBarButtonItem.Style.plain, target: self, action: #selector(MyViewController.commitPersonsSelection))
                                    self.contactsTVC?.navigationItem.rightBarButtonItem = self.commitPersonsSelectionBarButtonItem
                                    self.contactsTVC?.tableView.tableHeaderView = self.contactsSearchController?.searchBar
                                    self.contactsSearchController?.searchBar.delegate = self
                                    self.contactsTVC?.tableView.dataSource = self
                                    self.contactsTVC?.tableView.delegate = self
                                    
                                }
                                if self.aNewClientNavigationController == nil
                                {
                                    self.aNewClientNavigationController = UINavigationController()
                                }
                                self.aNewClientNavigationController?.setViewControllers([self.contactsTVC!], animated: false)
                                self.aNewClientNavigationController!.navigationBar.barTintColor = UIColor(red: 65/255, green: 93/255, blue: 174/255, alpha: 1.0)
                                self.aNewClientNavigationController!.navigationBar.isTranslucent = false
                                self.aNewClientNavigationController!.navigationBar.tintColor = UIColor.white
                                self.aNewClientNavigationController?.extendedLayoutIncludesOpaqueBars = true
                                self.present(self.aNewClientNavigationController!, animated: true, completion: nil)

            }
            else
            {        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        switch authorizationStatus
        {

            case CNAuthorizationStatus.notDetermined:
            if self.createAddressBook()
            {
                self.contactsSearchResultTVC = IKSContactsTVC()
                let store = CNContactStore()
                store.requestAccess(for: .contacts) { (granted, error) -> Void in
                    if granted {
                        let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                            CNContactImageDataKey,CNContactFamilyNameKey,CNContactGivenNameKey,CNContactThumbnailImageDataKey,CNContactOrganizationNameKey] as [Any]
                        
                        let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch as! [CNKeyDescriptor])
                        
                        let contacts: NSMutableArray = []
                        
                        do {
                            try store.enumerateContacts(with: fetchRequest, usingBlock: { (contact, stop) -> Void in
                                contacts.add(contact)
                            })
                        }
                        catch let error as NSError {
                            print(error.localizedDescription)
                        }

                        self.addressBookContactsMutableArray = contacts
                        self.userCardSelectionAddressBookContactsMutableArray = contacts
                        
                        if self.contactsSearchResultTVC == nil
                        {
                           
                            self.contactsSearchResultTVC?.tableView.dataSource = self
                            self.contactsSearchResultTVC?.tableView.delegate = self
                            self.contactsSearchResultTVC?.navigationItem.title = NSLocalizedString("Select 2 Persons",comment:"")
                            self.contactsSearchResultTVC?.navigationController?.navigationBar.barStyle = UIBarStyle.black
                            self.contactsSearchResultTVC?.navigationController?.navigationBar.tintColor = UIColor(red: CGFloat(246.0/255.0), green: CGFloat(0.0/255.0), blue: CGFloat(105.0/255.0), alpha: CGFloat(1.0))
                            
                            self.contactsTVC?.navigationItem.title = NSLocalizedString("Select 2 Persons",comment:"")
                            
                            
                        }
                        
                        if self.contactsSearchController == nil
                        {
                            self.contactsSearchController = UISearchController(searchResultsController: self.contactsSearchResultTVC!)
                            self.contactsSearchController?.hidesNavigationBarDuringPresentation = true
                            //self.contactsSearchController?.dimsBackgroundDuringPresentation = true
                            self.contactsSearchController?.searchBar.delegate = self
                            self.contactsSearchController?.searchBar.sizeToFit()
                        }
                        if self.contactsTVC == nil
                        {
                            self.contactsTVC = IKSContactsTVC()
                            self.cancelPersonsSelectionBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Cancel",comment:""), style: UIBarButtonItem.Style.plain, target: self, action: #selector(MyViewController.cancelPersonsSelection))
                            self.contactsTVC?.navigationItem.leftBarButtonItem = self.cancelPersonsSelectionBarButtonItem
                            self.commitPersonsSelectionBarButtonItem = UIBarButtonItem(title: NSLocalizedString("OK",comment:""), style: UIBarButtonItem.Style.plain, target: self, action: #selector(MyViewController.commitPersonsSelection))
                            self.contactsTVC?.navigationItem.rightBarButtonItem = self.commitPersonsSelectionBarButtonItem
                            self.contactsTVC?.tableView.tableHeaderView = self.contactsSearchController?.searchBar
                            self.contactsTVC?.tableView.dataSource = self
                            self.contactsTVC?.tableView.delegate = self

                            
                        }
                    
                        if self.aNewClientNavigationController == nil
                        {
                            self.aNewClientNavigationController = UINavigationController()
                        }
                        self.aNewClientNavigationController?.setViewControllers([self.contactsTVC!], animated: false)
                        self.aNewClientNavigationController!.navigationBar.barStyle = UIBarStyle.black
                        self.aNewClientNavigationController!.navigationBar.tintColor = UIColor(red: CGFloat(246.0/255.0), green: CGFloat(0.0/255.0), blue: CGFloat(105.0/255.0), alpha: CGFloat(1.0))
                        self.aNewClientNavigationController!.navigationBar.isTranslucent = false
                        self.aNewClientNavigationController?.extendedLayoutIncludesOpaqueBars = true
                        self.present(self.aNewClientNavigationController!, animated: true, completion: nil)
                        
                    }
                    else
                    {
                        
                    }
                }
       
            }
        case CNAuthorizationStatus.restricted:
            let alert = UIAlertController(title: NSLocalizedString("Contacts Acccess",comment:""), message: NSLocalizedString("eSpleen requires access to your contacts, the app does not send any data, we do not spy on you.",comment:""), preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: NSLocalizedString("Yes Take me to Privacy Settings",comment:""), style: UIAlertAction.Style.default) { (okSelected) -> Void in
                
                let URL = Foundation.URL(string: UIApplication.openSettingsURLString)
                UIApplication.shared.open(URL!, options: [:], completionHandler: {
                    (success) in
                    print("->: \(success)")
                })
            }
            
            let cancelButton = UIAlertAction(title: NSLocalizedString("No I'll do it later",comment:""), style: UIAlertAction.Style.cancel) { (cancelSelected) -> Void in
                
            }
            
            alert.addAction(okButton)
            alert.addAction(cancelButton)
            self.present(alert, animated: true, completion: nil)
           case CNAuthorizationStatus.denied:
            let alert = UIAlertController(title: NSLocalizedString("Contacts Acccess",comment:""), message: NSLocalizedString("eSpleen requires access to your contacts, the app does not send any data, we do not spy on you.",comment:""), preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: NSLocalizedString("Yes Take me to Privacy Settings",comment:""), style: UIAlertAction.Style.default) { (okSelected) -> Void in
            
                let URL = Foundation.URL(string: UIApplication.openSettingsURLString)
                UIApplication.shared.open(URL!, options: [:], completionHandler: {
                    (success) in
                    print("->: \(success)")
                })
            }
            
            let cancelButton = UIAlertAction(title: NSLocalizedString("No I'll do it later",comment:""), style: UIAlertAction.Style.cancel) { (cancelSelected) -> Void in
                
            }
            
            alert.addAction(okButton)
            alert.addAction(cancelButton)
            self.present(alert, animated: true, completion: nil)
        case CNAuthorizationStatus.authorized:
            if self.createAddressBook()
            {
                
                let store = CNContactStore()
                let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                    CNContactImageDataKey,CNContactFamilyNameKey,CNContactGivenNameKey,CNContactThumbnailImageDataKey,CNContactOrganizationNameKey] as [Any]
                
                let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch as! [CNKeyDescriptor])
                
                let contacts: NSMutableArray = []
                
               let queue = DispatchQueue(label: "EnumerateContacts")
                queue.async {
                    do {
                        try store.enumerateContacts(with: fetchRequest, usingBlock: { (contact, stop) -> Void in
                            contacts.add(contact)
                        })
                    }
                    catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }
                
                
                self.addressBookContactsMutableArray = contacts
                self.userCardSelectionAddressBookContactsMutableArray = contacts
                
                if self.contactsSearchResultTVC == nil
                {
                    self.contactsSearchResultTVC = IKSContactsTVC()
                    self.contactsSearchResultTVC?.tableView.dataSource = self
                    self.contactsSearchResultTVC?.tableView.delegate = self
                    self.contactsSearchResultTVC?.navigationItem.title = NSLocalizedString("Select 2 Persons",comment:"")
                    self.contactsSearchResultTVC?.navigationController?.navigationBar.barStyle = UIBarStyle.black
                    self.contactsSearchResultTVC?.navigationController?.navigationBar.tintColor = UIColor(red: CGFloat(246.0/255.0), green: CGFloat(0.0/255.0), blue: CGFloat(105.0/255.0), alpha: CGFloat(1.0))
                    
                    
                }
                if self.contactsTVC == nil
                {
                    self.contactsTVC = IKSContactsTVC()
                    self.cancelPersonsSelectionBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Cancel",comment:""), style: UIBarButtonItem.Style.plain, target: self, action: #selector(MyViewController.cancelPersonsSelection))
                    self.contactsTVC?.navigationItem.leftBarButtonItem = self.cancelPersonsSelectionBarButtonItem
                    
                    self.commitPersonsSelectionBarButtonItem = UIBarButtonItem(title: "OK", style: UIBarButtonItem.Style.plain, target: self, action: #selector(MyViewController.commitPersonsSelection))
                    self.contactsTVC?.navigationItem.rightBarButtonItem = self.commitPersonsSelectionBarButtonItem
                    
                    
                    
                    self.contactsSearchController = UISearchController(searchResultsController: self.contactsSearchResultTVC!)
                    self.contactsSearchController?.hidesNavigationBarDuringPresentation = true
                    //self.contactsSearchController?.dimsBackgroundDuringPresentation = true
                    self.contactsSearchController?.searchBar.delegate = self
                    self.contactsSearchController?.searchBar.sizeToFit()
                    self.contactsTVC?.tableView.tableHeaderView = self.contactsSearchController?.searchBar
                    
                    self.contactsTVC?.tableView.dataSource = self
                    self.contactsTVC?.tableView.delegate = self
                    
                }
                
                
                let aNewClientNavigationController:UINavigationController = UINavigationController(rootViewController: self.contactsTVC!)
                aNewClientNavigationController.navigationBar.barStyle = UIBarStyle.black
                aNewClientNavigationController.navigationBar.tintColor = UIColor(red: CGFloat(246.0/255.0), green: CGFloat(0.0/255.0), blue: CGFloat(105.0/255.0), alpha: CGFloat(1.0))
                self.present(aNewClientNavigationController, animated: true, completion: nil)
            }
        @unknown default:
            break
            

        }
        }
        }
        else
        {
            self.deleteCurrentMatch()
        }
    }


    func tableView(_ tableView: UITableView,
    numberOfRowsInSection section: Int) -> Int
    {
        if tableView == self.menuTableView
        {
        let number = Int(UIScreen.main.bounds.size.height/44) + 2
        return Int(number)
        }
        
        if tableView == self.scoresTableView && self.matchesArray.count > 0
        {
        return self.leftTrophiesArray.count
        }
            
        
        if tableView == self.contactsTVC?.tableView
        {
            if self.facebookContacts
            {
                if self.facebookContactsMutableArray != nil
                {
             return (self.facebookContactsMutableArray?.count)!
                }
                else
                {
                return 0
                }
            }
            else
            {
                if (self.addressBookContactsMutableArray != nil)
                {
                    return self.addressBookContactsMutableArray!.count
                }
                else
                {
                    self.addressBookContactsMutableArray = NSMutableArray()
                    return self.addressBookContactsMutableArray!.count
                }
            }
        }
        
        if tableView == self.contactsSearchResultTVC?.tableView
        {
            if self.facebookContacts
            {
                if let abcsrma = self.facebookContactsSearchResultsMutableArray
                {
                    return abcsrma.count
                }
            }
            else
            {
                if let abcsrma = self.addressBookContactsSearchResultsMutableArray
                {
                return abcsrma.count
                }
            }
        }
        
        if tableView == self.userCardSelectionContactsTVC?.tableView
        {
            
                if let abcsrma = self.userCardSelectionAddressBookContactsMutableArray
                {
                    return abcsrma.count
                }
            
        }
        
        if tableView == self.userCardSelectionContactsSearchResultTVC?.tableView
        {
            
                if let abcsrma = self.userCardSelectionAddressBookContactsSearchResultsMutableArray
                {
                    return abcsrma.count
                }
            
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView,
    cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        

        if tableView == self.menuTableView
        {
            
            let cell:IKSMenuCell =  IKSMenuCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "aMenuCell")
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            let lastIndex = Int(UIScreen.main.bounds.size.height/44) + 1
            
            switch indexPath.row
            {
            case 1:
                if isLoggedIn()
                {
                
                cell.centerIconImageView?.image = UIImage(named: "human.png")
                }
                else
                {
                    let defaults = UserDefaults.standard
                    var userCardID:String? = nil
                    userCardID = defaults.object(forKey: "userCardID") as? String
                    var searchResultArray:NSArray?
                    var userCard:CNContact?
                    if self.userCardSelectionAddressBookContactsMutableArray == nil
                    {
                    self.loadUserCardSelectionContacts()
                    }
                    if userCardID != nil
                    {
                        let comparisonOptions:NSString.CompareOptions = [NSString.CompareOptions.caseInsensitive, NSString.CompareOptions.diacriticInsensitive]
                        
                        let predicate: NSPredicate = NSPredicate( block: { (person, bindings) -> Bool in
                            let identifier:String! = (person as AnyObject).identifier
                            if identifier.range(of: userCardID!, options: comparisonOptions, range: nil, locale: nil) != nil
                            {
                                return true
                            }
                            return false
                        })
                        
                        
                        
                        
                        searchResultArray = self.userCardSelectionAddressBookContactsMutableArray?.filtered(using: predicate) as NSArray?
                        if searchResultArray != nil && searchResultArray?.count > 0
                        {
                            userCard = searchResultArray?.object(at: 0) as? CNContact
                            if userCard!.thumbnailImageData != nil
                            {
                            cell.centerIconImageView?.image = UIImage(data: userCard!.thumbnailImageData!)
                            }
                            else
                            {
                                cell.centerIconImageView?.image = UIImage(named: "human.png")
                            }
                        }
                        else
                        {
                            cell.centerIconImageView?.image = UIImage(named: "human.png")
                        }
                        
                    }
                    else
                    {
                    cell.centerIconImageView?.image = UIImage(named: "human.png")
                    }
                }
            case 2:

                
                let meCardButton:UIButton = UIButton(type: UIButton.ButtonType.custom)
                
                meCardButton.frame = CGRect(x: (cell.frame.size.width * 0.41) - (((cell.frame.width/7)*5)/2), y: cell.frame.height-(cell.frame.height*0.75), width: (cell.frame.width/7)*5, height: cell.frame.height*0.7)
                
                meCardButton.addTarget(self, action: #selector(MyViewController.loadUserAddressbookCardRquest), for: UIControl.Event.touchUpInside)
                
                meCardButton.setTitleColor(UIColor.white, for: UIControl.State())
                meCardButton.titleLabel!.font = UIFont(name: "DINCondensed-bold", size: 16)!
                //meCardButton.contentEdgeInsets = UIEdgeInsets(top: 2.0, left: 0.0, bottom: 0.0, right: 0.0)
                meCardButton.backgroundColor = UIColor(red: 243/255, green: 18/255, blue:107/255, alpha: 1.0)
                let defaults = UserDefaults.standard
                var userCardID:String? = nil
                userCardID = defaults.object(forKey: "userCardID") as? String
                var searchResultArray:NSArray?
                var userCard:CNContact?
                if userCardID != nil
                {
                    let comparisonOptions:NSString.CompareOptions = [NSString.CompareOptions.caseInsensitive, NSString.CompareOptions.diacriticInsensitive]
                    
                    let predicate: NSPredicate = NSPredicate( block: { (person, bindings) -> Bool in
                        let identifier: String? = (person as AnyObject).identifier
                        if identifier?.range(of: userCardID!, options: comparisonOptions, range: nil, locale: nil) != nil
                        {
                            return true
                        }
                        return false
                    })
                    
                    searchResultArray = self.userCardSelectionAddressBookContactsMutableArray?.filtered(using: predicate) as NSArray?
                    if searchResultArray != nil && searchResultArray?.count > 0
                    {
                        userCard = searchResultArray?.object(at: 0) as? CNContact
                        
                        
                        if self.getPreferedLanguage() == "ja-JP"
                        {
                            if userCard?.givenName != nil && userCard?.familyName != nil
                            {
                                meCardButton.setTitle("\((userCard?.familyName)!) \((userCard?.givenName)!)", for: UIControl.State())
                                
                            }
                            else if userCard?.givenName != nil && userCard?.familyName == nil
                            {
                                
                                meCardButton.setTitle((userCard?.givenName)!, for: UIControl.State())
                            }
                            else if userCard?.givenName == nil && userCard?.familyName != nil
                            {
                                meCardButton.setTitle((userCard?.familyName)!, for: UIControl.State())
                                
                            }
                            else if userCard?.organizationName != nil
                            {
                                meCardButton.setTitle((userCard?.organizationName)!, for: UIControl.State())
                                
                            }
                            else
                            {
                                
                                meCardButton.setTitle(NSLocalizedString("Unknown Contact",comment:""), for: UIControl.State())
                                
                            }
                        }
                        else
                            
                        {
                            if userCard?.givenName != nil && userCard?.familyName != nil
                            {
                                meCardButton.setTitle("\((userCard?.givenName)!) \((userCard?.familyName)!)", for: UIControl.State())
                                
                            }
                            else if userCard?.givenName != nil && userCard?.familyName == nil
                            {
                                
                                meCardButton.setTitle((userCard?.givenName)!, for: UIControl.State())
                            }
                            else if userCard?.givenName == nil && userCard?.familyName != nil
                            {
                                meCardButton.setTitle((userCard?.familyName)!, for: UIControl.State())
                                
                            }
                            else if userCard?.organizationName != nil
                            {
                                meCardButton.setTitle((userCard?.organizationName)!, for: UIControl.State())
                                
                            }
                            else
                            {
                                
                                meCardButton.setTitle(NSLocalizedString("Unknown Contact",comment:""), for: UIControl.State())
                                
                            }
                        }
                        
                    
                    }
                    
                }
                else
                {
                    meCardButton.setTitle(NSLocalizedString("Select my contact card",comment:""), for: UIControl.State())
                }
                cell.addSubview(meCardButton)
                cell.contentView.bringSubviewToFront(meCardButton)
                
                
            case lastIndex - 6:
                cell.iconImageView?.image = self.getTintedImage(UIImage(named: "instructions.png")!, withColor: UIColor(red: CGFloat(255.0/255.0), green: CGFloat(255.0/255.0), blue: CGFloat(255.0/255.0), alpha: CGFloat(1.0)))
                cell.mainTextLabel?.font = UIFont(name: "DINCondensed-bold", size: 14)!
                cell.mainTextLabel?.textAlignment = NSTextAlignment.center
                cell.mainTextLabel?.text = NSLocalizedString("Instructions",comment:"")
                cell.selectionStyle = UITableViewCell.SelectionStyle.default
            case lastIndex - 5:
                cell.iconImageView?.image = self.getTintedImage(UIImage(named: "mail.png")!, withColor: UIColor(red: CGFloat(255.0/255.0), green: CGFloat(255.0/255.0), blue: CGFloat(255.0/255.0), alpha: CGFloat(1.0)))
                cell.mainTextLabel?.font = UIFont(name: "DINCondensed-bold", size: 14)!
                cell.mainTextLabel?.textAlignment = NSTextAlignment.center
                cell.mainTextLabel?.text = NSLocalizedString("Contact us",comment:"")
                
                cell.selectionStyle = UITableViewCell.SelectionStyle.default
            
                
            case lastIndex - 3:
                cell.mainTextLabel?.text = ""
                cell.centerIconImageView?.image = UIImage(named: "bucle.png")
            case lastIndex - 2:
                cell.mainTextLabel?.textAlignment = NSTextAlignment.center
                cell.longTextLabel?.font = UIFont(name: "DINCondensed-bold", size: 14)!
                cell.longTextLabel?.text = "v.1.1\n2015"
                
            default:
                cell.textLabel?.text = ""
    
            }
            return cell
        }
        
        if tableView == self.scoresTableView
        {
            
            let cell:IKSTrophyCell?
            let bigCell:IKSTrophyBigCell?
            let selectedATrophy:Trophy?
            let selectedBTrophy:Trophy?
                
                if self.readMoreIndexPath != nil && self.readMoreIndexPath!.row == indexPath.row
                {
                    bigCell = self.scoresTableView?.dequeueReusableCell(withIdentifier: "aBigTrophyCell", for: indexPath) as? IKSTrophyBigCell
                    bigCell!.selectionStyle = UITableViewCell.SelectionStyle.none
                    if self.editMode == true
                    {
                        bigCell!.backgroundColor = UIColor(red: CGFloat(231.0/255.0), green: CGFloat(237.0/255.0), blue: CGFloat(234.0/255.0), alpha: CGFloat(1.0))
                        
                        selectedATrophy = self.leftTrophiesArray.object(at: indexPath.row) as? Trophy
                        selectedBTrophy = self.rightTrophiesArray.object(at: indexPath.row) as? Trophy
                        if selectedATrophy!.substracts
                        {
                            bigCell!.rightImageView?.image = UIImage(named: "taker.png")!
                            bigCell!.leftImageView?.image = UIImage(named: "takel.png")!
                        }
                        else
                        {
                            bigCell!.rightImageView?.image = UIImage(named: "giver.png")!
                            bigCell!.leftImageView?.image = UIImage(named: "givel.png")!
                        }
                        let currentMatch:Match = self.matchesArray.object(at: self.currentSection()) as! Match
                        let cornerSortDescriptor = NSSortDescriptor(key: "corner", ascending: true)
                        let matchesParticipants:NSArray? =  NSArray(array: currentMatch.participants!.allObjects).sortedArray(using: [cornerSortDescriptor]) as NSArray
                        if matchesParticipants != nil && matchesParticipants?.count == 2
                        {
                         
                            
                            bigCell!.nameLabel?.textColor = UIColor(red: CGFloat(51.0/255.0), green: CGFloat(51.0/255.0), blue: CGFloat(51.0/255.0), alpha: CGFloat(1.0))
                            bigCell!.nameLabel?.text = selectedATrophy!.name as String?
                            
                            bigCell!.rightIconCounterLabel?.textColor = UIColor.black
                            bigCell!.leftIconCounterLabel?.textColor = UIColor.black
                            
                            bigCell!.rightIconCounterLabel?.text = selectedBTrophy!.score!.stringValue
                            bigCell!.leftIconCounterLabel?.text = selectedATrophy!.score!.stringValue
                            
                        }
                    }
                    else if self.editMode == false
                    {
                        if self.editingIndexPath == indexPath
                        {
                            bigCell!.backgroundColor = UIColor(red: CGFloat(231.0/255.0), green: CGFloat(237.0/255.0), blue: CGFloat(234.0/255.0), alpha: CGFloat(1.0))
                           
                            selectedATrophy = self.leftTrophiesArray.object(at: indexPath.row) as? Trophy
                            selectedBTrophy = self.rightTrophiesArray.object(at: indexPath.row) as? Trophy
                            if selectedATrophy!.substracts
                            {
                                
                                bigCell!.rightImageView?.image = UIImage(named: "giverb.png")!
                                bigCell!.leftImageView?.image = UIImage(named: "givelb.png")!
                                bigCell!.button1ImageView?.image = getTintedImage(UIImage(named: "h.png")!, withColor: UIColor(red: CGFloat(51.0/255.0), green: CGFloat(51.0/255.0), blue: CGFloat(51.0/255.0), alpha: CGFloat(1.0)))

                            }
                            else
                            {
                                bigCell!.rightImageView?.image = UIImage(named: "giver.png")!
                                bigCell!.leftImageView?.image = UIImage(named: "givel.png")!
                                bigCell!.button1ImageView?.image = getTintedImage(UIImage(named: "bh.png")!, withColor: UIColor(red: CGFloat(51.0/255.0), green: CGFloat(51.0/255.0), blue: CGFloat(51.0/255.0), alpha: CGFloat(1.0)))
                            }
                            let currentMatch:Match = self.matchesArray.object(at: self.currentSection()) as! Match
                            let cornerSortDescriptor = NSSortDescriptor(key: "corner", ascending: true)
                            let matchesParticipants:NSArray? =  NSArray(array: currentMatch.participants!.allObjects).sortedArray(using: [cornerSortDescriptor]) as NSArray
                            if matchesParticipants != nil && matchesParticipants?.count == 2
                            {
                                self.dbManager?.fillTrophyEmptyOptionals(selectedATrophy!)
                                self.dbManager?.fillTrophyEmptyOptionals(selectedBTrophy!)
                                bigCell!.nameLabel?.textColor = UIColor(red: CGFloat(51.0/255.0), green: CGFloat(51.0/255.0), blue: CGFloat(51.0/255.0), alpha: CGFloat(1.0))
                                bigCell!.nameLabel?.text = selectedATrophy!.name as String?
                                
                                bigCell!.rightIconCounterLabel?.textColor = UIColor.black
                                bigCell!.leftIconCounterLabel?.textColor = UIColor.black
                                
                                bigCell!.rightIconCounterLabel?.text = selectedBTrophy!.score!.stringValue
                                bigCell!.leftIconCounterLabel?.text = selectedATrophy!.score!.stringValue
                                bigCell!.button2ImageView!.image = getTintedImage(UIImage(named: "plusminus.png")!, withColor: UIColor(red: CGFloat(51.0/255.0), green: CGFloat(51.0/255.0), blue: CGFloat(51.0/255.0), alpha: CGFloat(1.0)))
                                bigCell!.button3ImageView!.image = getTintedImage(UIImage(named: "editingsm.png")!, withColor: UIColor(red: CGFloat(51.0/255.0), green: CGFloat(51.0/255.0), blue: CGFloat(51.0/255.0), alpha: CGFloat(1.0)))
                                bigCell!.button5ImageView!.image = getTintedImage(UIImage(named: "trashsm.png")!, withColor: UIColor(red: CGFloat(51.0/255.0), green: CGFloat(51.0/255.0), blue: CGFloat(51.0/255.0), alpha: CGFloat(1.0)))
                                
                            }

                        }
                        else
                        {
                        bigCell!.backgroundColor = UIColor(red: CGFloat(51.0/255.0), green: CGFloat(51.0/255.0), blue: CGFloat(51.0/255.0), alpha: CGFloat(1.0))

                            selectedATrophy = self.leftTrophiesArray.object(at: indexPath.row) as? Trophy
                            selectedBTrophy = self.rightTrophiesArray.object(at: indexPath.row) as? Trophy
                            if selectedATrophy!.substracts
                            {
                                bigCell!.rightImageView?.image = UIImage(named: "takerb.png")!
                                bigCell!.leftImageView?.image = UIImage(named: "takelb.png")!
                                bigCell!.button1ImageView?.image = getTintedImage(UIImage(named: "h.png")!, withColor: UIColor(red: CGFloat(231.0/255.0), green: CGFloat(237.0/255.0), blue: CGFloat(234.0/255.0), alpha: CGFloat(1.0)))
                            }
                            else
                            {
                                bigCell!.rightImageView?.image = UIImage(named: "taker.png")!
                                bigCell!.leftImageView?.image = UIImage(named: "takel.png")!
                                bigCell!.button1ImageView?.image = getTintedImage(UIImage(named: "bh.png")!, withColor: UIColor(red: CGFloat(231.0/255.0), green: CGFloat(237.0/255.0), blue: CGFloat(234.0/255.0), alpha: CGFloat(1.0)))
                            }
                        let currentMatch:Match = self.matchesArray.object(at: self.currentSection()) as! Match
                        let cornerSortDescriptor = NSSortDescriptor(key: "corner", ascending: true)
                            let matchesParticipants:NSArray? =  NSArray(array: currentMatch.participants!.allObjects).sortedArray(using: [cornerSortDescriptor]) as NSArray
                        if matchesParticipants != nil && matchesParticipants?.count == 2
                        {
                            bigCell!.nameLabel?.textColor = UIColor(red: CGFloat(231.0/255.0), green: CGFloat(237.0/255.0), blue: CGFloat(234.0/255.0), alpha: CGFloat(1.0))
                            bigCell!.nameLabel?.text = selectedATrophy!.name as String?
                            bigCell!.rightIconCounterLabel?.textColor = UIColor(red: CGFloat(231.0/255.0), green: CGFloat(237.0/255.0), blue: CGFloat(234.0/255.0), alpha: CGFloat(1.0))
                            bigCell!.leftIconCounterLabel?.textColor = UIColor(red: CGFloat(231.0/255.0), green: CGFloat(237.0/255.0), blue: CGFloat(234.0/255.0), alpha: CGFloat(1.0))
                            bigCell!.leftIconCounterLabel?.text = selectedATrophy!.score!.stringValue
                            bigCell!.rightIconCounterLabel?.text = selectedBTrophy!.score!.stringValue
                            
                            
                            
                            bigCell!.button2ImageView!.image = getTintedImage(UIImage(named: "plusminus.png")!, withColor: UIColor(red: CGFloat(231.0/255.0), green: CGFloat(237.0/255.0), blue: CGFloat(234.0/255.0), alpha: CGFloat(1.0)))
                            bigCell!.button3ImageView!.image = getTintedImage(UIImage(named: "editingsm.png")!, withColor: UIColor(red: CGFloat(231.0/255.0), green: CGFloat(237.0/255.0), blue: CGFloat(234.0/255.0), alpha: CGFloat(1.0)))
                            bigCell!.button5ImageView!.image = getTintedImage(UIImage(named: "trashsm.png")!, withColor: UIColor(red: CGFloat(231.0/255.0), green: CGFloat(237.0/255.0), blue: CGFloat(234.0/255.0), alpha: CGFloat(1.0)))
                            
                        }
                    }
                    }
                    return bigCell!
                }
                else
                {
                    cell = self.scoresTableView?.dequeueReusableCell(withIdentifier: "aTrophyCell", for: indexPath) as? IKSTrophyCell
                    cell!.selectionStyle = UITableViewCell.SelectionStyle.none
                    if self.editMode == true
                    {
                        
                        cell!.backgroundColor = UIColor(red: CGFloat(231.0/255.0), green: CGFloat(237.0/255.0), blue: CGFloat(234.0/255.0), alpha: CGFloat(1.0))
                        
                        selectedATrophy = self.leftTrophiesArray.object(at: indexPath.row) as? Trophy
                        selectedBTrophy = self.rightTrophiesArray.object(at: indexPath.row) as? Trophy
                        
                        if selectedATrophy!.substracts
                        {
                            cell!.rightImageView?.image = UIImage(named: "giverb.png")!
                            cell!.leftImageView?.image = UIImage(named: "givelb.png")!
                            
                        }
                        else
                        {
                            
                            cell!.rightImageView?.image = UIImage(named: "giver.png")!
                            cell!.leftImageView?.image = UIImage(named: "givel.png")!
                        }
                        let currentMatch:Match = self.matchesArray.object(at: self.currentSection()) as! Match
                        let cornerSortDescriptor = NSSortDescriptor(key: "corner", ascending: true)
                        let matchesParticipants:NSArray? =  NSArray(array: currentMatch.participants!.allObjects).sortedArray(using: [cornerSortDescriptor]) as NSArray
                        if matchesParticipants != nil && matchesParticipants?.count == 2
                        {
                            let participantA = matchesParticipants?.object(at: 0) as! Participation
                            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
                            let participantATrophies:NSArray = NSArray(array: participantA.trophies.allObjects).sortedArray(using: [nameSortDescriptor]) as NSArray
                            //ordenar trofeos por nombre
                            if indexPath.row < participantATrophies.count
                            {
                            
                                
                                cell!.nameLabel?.textColor = UIColor(red: CGFloat(51.0/255.0), green: CGFloat(51.0/255.0), blue: CGFloat(51.0/255.0), alpha: CGFloat(1.0))
                                
                                cell!.nameLabel?.text = selectedATrophy!.name as String?
                                
                            }
                            
                        }
                    }
                    else if self.editMode == false
                    {
                    
                        cell!.backgroundColor = UIColor(red: CGFloat(51.0/255.0), green: CGFloat(51.0/255.0), blue: CGFloat(51.0/255.0), alpha: CGFloat(1.0))
                       
                        selectedATrophy = self.leftTrophiesArray.object(at: indexPath.row) as? Trophy
                        if selectedATrophy!.substracts
                        {
                            
                            cell!.rightImageView?.image = UIImage(named: "takerb.png")!
                            cell!.leftImageView?.image = UIImage(named: "takelb.png")!
                        }
                        else
                        {
                        
                            
                            cell!.rightImageView?.image = UIImage(named: "taker.png")!
                            cell!.leftImageView?.image = UIImage(named: "takel.png")!
                        }
                        
                        let currentMatch:Match = self.matchesArray.object(at: self.currentSection()) as! Match
                        let cornerSortDescriptor = NSSortDescriptor(key: "corner", ascending: true)
                        let matchesParticipants:NSArray? =  NSArray(array: currentMatch.participants!.allObjects).sortedArray(using: [cornerSortDescriptor]) as NSArray
                        if matchesParticipants != nil && matchesParticipants?.count == 2
                        {
                        
                            let participantA = matchesParticipants?.object(at: 0) as! Participation
        
                            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
          
                            let participantATrophies:NSArray = NSArray(array: participantA.trophies.allObjects).sortedArray(using: [nameSortDescriptor]) as NSArray
     
                            //ordenar trofeos por nombre
                            if indexPath.row < participantATrophies.count
                            {
                                let selectedATrophy:Trophy = self.leftTrophiesArray.object(at: indexPath.row) as! Trophy

                                cell!.nameLabel?.textColor = UIColor.white

                                cell!.nameLabel?.text = selectedATrophy.name as String?

                            }
                            
                           
                        }
                }
                    return cell!
        }
        
        }
        if tableView == self.contactsTVC?.tableView
        {
            if self.facebookContacts
            {
            let personCell:UITableViewCell = UITableViewCell()
                if selectedContactsReferences.count == 1
                {
                    let firstIndex:Int? = self.facebookContactsMutableArray?.index(of: self.selectedContactsReferences.object(at: 0))
                    if indexPath.row == firstIndex
                    {
                        personCell.accessoryType = UITableViewCell.AccessoryType.checkmark
                    }
                }
                else if selectedContactsReferences.count == 2
                {
                    let firstIndex:Int? = self.facebookContactsMutableArray?.index(of: self.selectedContactsReferences.object(at: 0))
                    let secondIndex:Int? = self.facebookContactsMutableArray?.index(of: self.selectedContactsReferences.object(at: 1))
                    if indexPath.row == firstIndex || indexPath.row == secondIndex
                    {
                        personCell.accessoryType = UITableViewCell.AccessoryType.checkmark
                    }
                }

                let friendDataDictionary:NSDictionary = (self.facebookContactsMutableArray?.object(at: indexPath.row))! as! NSDictionary
                let forenames:String? = friendDataDictionary.object(forKey: "first_name") as? String
                let surenames:String? = friendDataDictionary.object(forKey: "last_name") as? String
                
                if self.getPreferedLanguage() == "ja-JP"
                {
                    if forenames != nil && surenames != nil
                    {
                        personCell.textLabel?.text = "\(surenames!) \(forenames!)"
                    }
                    else if forenames != nil && surenames == nil
                    {
                        personCell.textLabel?.text = forenames!
                    }
                    else if forenames == nil && surenames != nil
                    {
                        personCell.textLabel?.text = surenames!
                    }
                    else
                    {
                        personCell.textLabel?.text = NSLocalizedString("Unknown Contact",comment:"")
                    }
                }
                else
                {
                    if forenames != nil && surenames != nil
                    {
                        personCell.textLabel?.text = "\(forenames!) \(surenames!)"
                    }
                    else if forenames != nil && surenames == nil
                    {
                        personCell.textLabel?.text = forenames!
                    }
                    else if forenames == nil && surenames != nil
                    {
                        personCell.textLabel?.text = surenames!
                    }
                    else
                    {
                        personCell.textLabel?.text = NSLocalizedString("Unknown Contact",comment:"")
                    }
                }
                
                

            return personCell
            }
            else
            {
            
                let personCell:UITableViewCell = UITableViewCell()
                if selectedContactsReferences.count == 1
                {
                    let firstIndex:Int? = self.addressBookContactsMutableArray?.index(of: self.selectedContactsReferences.object(at: 0))
                    if indexPath.row == firstIndex
                    {
                        personCell.accessoryType = UITableViewCell.AccessoryType.checkmark
                    }
                }
                else if selectedContactsReferences.count == 2
                {
                    let firstIndex:Int? = self.addressBookContactsMutableArray?.index(of: self.selectedContactsReferences.object(at: 0))
                    let secondIndex:Int? = self.addressBookContactsMutableArray?.index(of: self.selectedContactsReferences.object(at: 1))
                    if indexPath.row == firstIndex || indexPath.row == secondIndex
                    {
                        personCell.accessoryType = UITableViewCell.AccessoryType.checkmark
                    }
                }
                let forenames:String? = (self.addressBookContactsMutableArray?.object(at: indexPath.row) as AnyObject).givenName
                let surenames:String? = (self.addressBookContactsMutableArray?.object(at: indexPath.row) as AnyObject).familyName
                let companyName:String? = (self.addressBookContactsMutableArray?.object(at: indexPath.row) as AnyObject).organizationName
                if forenames != nil && surenames != nil
                {
                    personCell.textLabel?.text = "\(forenames!) \(surenames!)"
                }
                else if forenames != nil && surenames == nil
                {
                    personCell.textLabel?.text = forenames!
                }
                else if forenames == nil && surenames != nil
                {
                    personCell.textLabel?.text = surenames!
                }
                else if forenames == nil && surenames == nil && companyName != nil
                {
                    personCell.textLabel?.text = companyName!
                }
                else
                {
                    personCell.textLabel?.text = NSLocalizedString("Unknown Contact",comment:"")
                }
                return personCell
            }
        }
        
        if tableView == self.contactsSearchResultTVC?.tableView
        {
            
            if self.facebookContacts
            {
                let personCell:UITableViewCell = UITableViewCell()
                if selectedContactsReferences.count == 1
                {
                    let firstIndex:Int? = self.facebookContactsSearchResultsMutableArray?.index(of: self.selectedContactsReferences.object(at: 0))
                    if indexPath.row == firstIndex
                    {
                        personCell.accessoryType = UITableViewCell.AccessoryType.checkmark
                    }
                }
                else if selectedContactsReferences.count == 2
                {
                    let firstIndex:Int? = self.facebookContactsSearchResultsMutableArray?.index(of: self.selectedContactsReferences.object(at: 0))
                    let secondIndex:Int? = self.facebookContactsSearchResultsMutableArray?.index(of: self.selectedContactsReferences.object(at: 1))
                    if indexPath.row == firstIndex || indexPath.row == secondIndex
                    {
                        personCell.accessoryType = UITableViewCell.AccessoryType.checkmark
                    }
                }
                let friendDataDictionary:NSDictionary = (self.facebookContactsSearchResultsMutableArray?.object(at: indexPath.row))! as! NSDictionary
                let forenames:String? = friendDataDictionary.object(forKey: "first_name") as? String
                let surenames:String? = friendDataDictionary.object(forKey: "last_name") as? String
                if self.getPreferedLanguage() == "ja-JP"
                {
                    if forenames != nil && surenames != nil
                    {
                        personCell.textLabel?.text = "\(surenames!) \(forenames!)"
                    }
                    else if forenames != nil && surenames == nil
                    {
                        personCell.textLabel?.text = forenames!
                    }
                    else if forenames == nil && surenames != nil
                    {
                        personCell.textLabel?.text = surenames!
                    }
                    else
                    {
                        personCell.textLabel?.text = NSLocalizedString("Unknown Contact",comment:"")
                    }
                }
                else
                {
                    if forenames != nil && surenames != nil
                    {
                        personCell.textLabel?.text = "\(forenames!) \(surenames!)"
                    }
                    else if forenames != nil && surenames == nil
                    {
                        personCell.textLabel?.text = forenames!
                    }
                    else if forenames == nil && surenames != nil
                    {
                        personCell.textLabel?.text = surenames!
                    }
                    else
                    {
                        personCell.textLabel?.text = NSLocalizedString("Unknown Contact",comment:"")
                    }
                }
                return personCell
            }
            else
            {
                let personCell:UITableViewCell = UITableViewCell()
                if selectedContactsReferences.count == 1
                {
                    let firstIndex:Int? = self.addressBookContactsSearchResultsMutableArray?.index(of: self.selectedContactsReferences.object(at: 0))
                    if indexPath.row == firstIndex
                    {
                        personCell.accessoryType = UITableViewCell.AccessoryType.checkmark
                    }
                }
                else if selectedContactsReferences.count == 2
                {
                    let firstIndex:Int? = self.addressBookContactsSearchResultsMutableArray?.index(of: self.selectedContactsReferences.object(at: 0))
                    let secondIndex:Int? = self.addressBookContactsSearchResultsMutableArray?.index(of: self.selectedContactsReferences.object(at: 1))
                    if indexPath.row == firstIndex || indexPath.row == secondIndex
                    {
                        personCell.accessoryType = UITableViewCell.AccessoryType.checkmark
                    }
                }
                let forenames:String? = (self.addressBookContactsSearchResultsMutableArray?.object(at: indexPath.row) as AnyObject).givenName
                let surenames:String? = (self.addressBookContactsSearchResultsMutableArray?.object(at: indexPath.row) as AnyObject).familyName
                let companyName:String? = (self.addressBookContactsSearchResultsMutableArray?.object(at: indexPath.row) as AnyObject).organizationName
                if self.getPreferedLanguage() == "ja-JP"
                {
                    if forenames != nil && surenames != nil
                    {
                        personCell.textLabel?.text = "\(surenames!) \(forenames!)!"
                    }
                    else if forenames != nil && surenames == nil
                    {
                        personCell.textLabel?.text = forenames!
                    }
                    else if forenames == nil && surenames != nil
                    {
                        personCell.textLabel?.text = surenames!
                    }
                    else if forenames == nil && surenames == nil && companyName != nil
                    {
                        personCell.textLabel?.text = companyName!
                    }
                    else
                    {
                        personCell.textLabel?.text = NSLocalizedString("Unknown Contact",comment:"")
                    }
                }
                else
                {
                    if forenames != nil && surenames != nil
                    {
                        personCell.textLabel?.text = "\(forenames!) \(surenames!)"
                    }
                    else if forenames != nil && surenames == nil
                    {
                        personCell.textLabel?.text = forenames!
                    }
                    else if forenames == nil && surenames != nil
                    {
                        personCell.textLabel?.text = surenames!
                    }
                    else if forenames == nil && surenames == nil && companyName != nil
                    {
                        personCell.textLabel?.text = companyName!
                    }
                    else
                    {
                        personCell.textLabel?.text = NSLocalizedString("Unknown Contact",comment:"")
                    }
                }
                return personCell
            }
            
        }
        
        if tableView == self.userCardSelectionContactsTVC?.tableView
        {
            
            let personCell:UITableViewCell = UITableViewCell()
            let forenames:String? = (self.userCardSelectionAddressBookContactsMutableArray?.object(at: indexPath.row) as AnyObject).givenName
            let surenames:String? = (self.userCardSelectionAddressBookContactsMutableArray?.object(at: indexPath.row) as AnyObject).familyName
            let companyName:String? = (self.userCardSelectionAddressBookContactsMutableArray?.object(at: indexPath.row) as AnyObject).organizationName
            if self.getPreferedLanguage() == "ja-JP"
            {
                if forenames != nil && surenames != nil
                {
                    personCell.textLabel?.text = "\(surenames!) \(forenames!)"
                }
                else if forenames != nil && surenames == nil
                {
                    personCell.textLabel?.text = forenames!
                }
                else if forenames == nil && surenames != nil
                {
                    personCell.textLabel?.text = surenames!
                }
                else if forenames == nil && surenames == nil && companyName != nil
                {
                    personCell.textLabel?.text = companyName!
                }
                else
                {
                    personCell.textLabel?.text = NSLocalizedString("Unknown Contact",comment:"")
                }
            }
            else
            {
                if forenames != nil && surenames != nil
                {
                    personCell.textLabel?.text = "\(forenames!) \(surenames!)"
                }
                else if forenames != nil && surenames == nil
                {
                    personCell.textLabel?.text = forenames!
                }
                else if forenames == nil && surenames != nil
                {
                    personCell.textLabel?.text = surenames!
                }
                else if forenames == nil && surenames == nil && companyName != nil
                {
                    personCell.textLabel?.text = companyName!
                }
                else
                {
                    personCell.textLabel?.text = NSLocalizedString("Unknown Contact",comment:"")
                }
            }
            
            
            var userCardIndex:Int? = nil
            if self.userCard != nil
            {
                if self.userCardSelectionAddressBookContactsMutableArray != nil && self.userCardSelectionAddressBookContactsMutableArray?.count > 0
                {
                    userCardIndex = self.userCardSelectionAddressBookContactsMutableArray?.index(of: self.userCard!)
                    if userCardIndex != nil && indexPath.row == userCardIndex
                    {
                        personCell.accessoryType = UITableViewCell.AccessoryType.checkmark
                    }
                }
            }
            
            return personCell
        }
        if  tableView == self.userCardSelectionContactsSearchResultTVC?.tableView
        {
            let personCell:UITableViewCell = UITableViewCell()
            let forenames:String? = (self.userCardSelectionAddressBookContactsSearchResultsMutableArray?.object(at: indexPath.row) as AnyObject).givenName
            let surenames:String? = (self.userCardSelectionAddressBookContactsSearchResultsMutableArray?.object(at: indexPath.row) as AnyObject).familyName
            let companyName:String? = (self.userCardSelectionAddressBookContactsSearchResultsMutableArray?.object(at: indexPath.row) as AnyObject).organizationName
           
            
            if self.getPreferedLanguage() == "ja-JP"
            {
                if forenames != nil && surenames != nil
                {
                    personCell.textLabel?.text = "\(surenames!) \(forenames!)"
                }
                else if forenames != nil && surenames == nil
                {
                    personCell.textLabel?.text = forenames!
                }
                else if forenames == nil && surenames != nil
                {
                    personCell.textLabel?.text = surenames!
                }
                else if forenames == nil && surenames == nil && companyName != nil
                {
                    personCell.textLabel?.text = companyName!
                }
                else
                {
                    personCell.textLabel?.text = NSLocalizedString("Unknown Contact",comment:"")
                }
            }
            else
            {
                if forenames != nil && surenames != nil
                {
                    personCell.textLabel?.text = "\(forenames!) \(surenames!)"
                }
                else if forenames != nil && surenames == nil
                {
                    personCell.textLabel?.text = forenames!
                }
                else if forenames == nil && surenames != nil
                {
                    personCell.textLabel?.text = surenames!
                }
                else if forenames == nil && surenames == nil && companyName != nil
                {
                    personCell.textLabel?.text = companyName!
                }
                else
                {
                    personCell.textLabel?.text = NSLocalizedString("Unknown Contact",comment:"")
                }
            }
            
            var userCardIndex:Int? = nil
            if self.userCard != nil
            {
                
                
                
                if self.userCardSelectionAddressBookContactsSearchResultsMutableArray != nil && self.userCardSelectionAddressBookContactsSearchResultsMutableArray?.count > 0
                {
                    userCardIndex = self.userCardSelectionAddressBookContactsSearchResultsMutableArray?.index(of: self.userCard!)
                    if userCardIndex != nil && indexPath.row == userCardIndex
                    {
                        personCell.accessoryType = UITableViewCell.AccessoryType.checkmark
                    }
                }
            }
            return personCell
        }

    return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        
        if tableView == self.userCardSelectionContactsTVC?.tableView
        {
            
            
                var firstPlayerCell:UITableViewCell?
                let selectedContact:CNContact? = self.userCardSelectionAddressBookContactsMutableArray?.object(at: indexPath.row) as? CNContact
                if selectedContact != nil
                {
                    if userCardSelectionSelectedContactsReferences.count > 0
                    {
                        
                        let firstRef:CNContact = userCardSelectionSelectedContactsReferences.object(at: 0) as! CNContact
                        let equalS = selectedContact?.isEqual(firstRef)
                        if equalS == true
                        {
                            self.userCardSelectionContactsTVC?.tableView.beginUpdates()
                            self.userCardSelectionSelectedContactsReferences.removeObject(at: 0)
                            self.userCard = nil
                            
                            firstPlayerCell = self.userCardSelectionContactsTVC?.tableView.cellForRow(at: IndexPath(row: 0, section: indexPath.section))
                            firstPlayerCell?.accessoryType = UITableViewCell.AccessoryType.none
                            firstPlayerCell?.setSelected(false, animated: true)
                            
                            self.userCardSelectionContactsTVC?.tableView.endUpdates()
                        }
                        else
                        {
                            firstPlayerCell = self.userCardSelectionContactsTVC?.tableView.cellForRow(at: IndexPath(row: 0, section: indexPath.section))
                            firstPlayerCell?.accessoryType = UITableViewCell.AccessoryType.none
                            
                            firstPlayerCell = self.userCardSelectionContactsSearchResultTVC?.tableView.cellForRow(at: IndexPath(row: 0, section: indexPath.section))
                            firstPlayerCell?.accessoryType = UITableViewCell.AccessoryType.none
                            self.userCardSelectionContactsTVC?.tableView.beginUpdates()
                            userCardSelectionSelectedContactsReferences.removeObject(at: 0)
                            userCardSelectionSelectedContactsReferences.insert(selectedContact!, at: 0)
                            self.userCardSelectionAddressBookContactsMutableArray?.removeObject(at: indexPath.row)
                            self.userCardSelectionAddressBookContactsMutableArray?.insert(selectedContact!, at: 0)
                            self.userCardSelectionContactsTVC?.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
                            firstPlayerCell = self.userCardSelectionContactsTVC?.tableView.cellForRow(at: IndexPath(row: 0, section: indexPath.section))
                            firstPlayerCell?.accessoryType = UITableViewCell.AccessoryType.none
                            
                            
                            let firstPlayerCellIndexPath:IndexPath? = IndexPath(row: 0, section: indexPath.section)
                            self.userCardSelectionContactsTVC?.tableView.insertRows(at: [firstPlayerCellIndexPath!], with: UITableView.RowAnimation.fade)
                            self.userCardSelectionContactsTVC?.tableView.endUpdates()
                            firstPlayerCell = self.userCardSelectionContactsTVC?.tableView.cellForRow(at: IndexPath(row: 0, section: indexPath.section))
                            firstPlayerCell?.accessoryType = UITableViewCell.AccessoryType.checkmark
                            
                        }
                        
                        
                       
                      

                    }
                    else
                    {
                        firstPlayerCell = self.userCardSelectionContactsTVC?.tableView.cellForRow(at: IndexPath(row: 0, section: indexPath.section))
                        firstPlayerCell?.accessoryType = UITableViewCell.AccessoryType.none
                        
                        firstPlayerCell = self.userCardSelectionContactsSearchResultTVC?.tableView.cellForRow(at: IndexPath(row: 0, section: indexPath.section))
                        firstPlayerCell?.accessoryType = UITableViewCell.AccessoryType.none
                        self.userCardSelectionContactsTVC?.tableView.beginUpdates()
                        userCardSelectionSelectedContactsReferences.insert(selectedContact!, at: 0)
                        self.userCardSelectionAddressBookContactsMutableArray?.removeObject(at: indexPath.row)
                        self.userCardSelectionAddressBookContactsMutableArray?.insert(selectedContact!, at: 0)
                        self.userCardSelectionContactsTVC?.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
                        let firstPlayerCellIndexPath:IndexPath? = IndexPath(row: 0, section: indexPath.section)
                        self.userCardSelectionContactsTVC?.tableView.insertRows(at: [firstPlayerCellIndexPath!], with: UITableView.RowAnimation.fade)
                        self.userCardSelectionContactsTVC?.tableView.endUpdates()
                        firstPlayerCell = self.userCardSelectionContactsTVC?.tableView.cellForRow(at: IndexPath(row: 0, section: 0))
                        firstPlayerCell?.accessoryType = UITableViewCell.AccessoryType.checkmark
                        
                        
                    }
                }
                
            
            

        }
        else if tableView == self.userCardSelectionContactsSearchResultTVC?.tableView
        {
            var firstPlayerCell:UITableViewCell?
            let selectedContact:CNContact? = self.userCardSelectionAddressBookContactsSearchResultsMutableArray?.object(at: indexPath.row) as? CNContact
            
            var mainTableCorrespondingIndexpath:IndexPath?
            
            if selectedContact != nil
            {
                self.userCardSelectionContactsSearchResultTVC?.tableView.beginUpdates()
                self.userCardSelectionContactsTVC?.tableView.beginUpdates()
                
                if userCardSelectionSelectedContactsReferences.count > 0
                {
                    
                    let firstRef:CNContact = userCardSelectionSelectedContactsReferences.object(at: 0) as! CNContact
                    let equalF = selectedContact?.isEqual(firstRef)
                    if equalF == true
                    {
                        
                        
                        
                        let selectedContactIndexInSearchResultsTV:Int? = self.userCardSelectionAddressBookContactsSearchResultsMutableArray?.index(of: selectedContact!)
                        let selectedContactIndexPathInSearchResultsTV:IndexPath = IndexPath(row: selectedContactIndexInSearchResultsTV!, section: 0)
                        let firstPlayerCellIndexPath:IndexPath? = IndexPath(row: 0, section: 0)
                        userCardSelectionSelectedContactsReferences.removeObject(at: 0)
                        self.userCardSelectionContactsTVC?.tableView.endUpdates()
                        self.userCardSelectionContactsSearchResultTVC?.tableView.endUpdates()
                        
                        firstPlayerCell = self.userCardSelectionContactsSearchResultTVC?.tableView.cellForRow(at: selectedContactIndexPathInSearchResultsTV)
                        firstPlayerCell?.accessoryType = UITableViewCell.AccessoryType.none
                        firstPlayerCell?.setSelected(false, animated: true)
                        
                        firstPlayerCell = self.userCardSelectionContactsTVC?.tableView.cellForRow(at: firstPlayerCellIndexPath!)
                        firstPlayerCell?.accessoryType = UITableViewCell.AccessoryType.none
                        
                        
                        
                    }
                    else
                    {
                        firstPlayerCell = self.userCardSelectionContactsTVC?.tableView.cellForRow(at: IndexPath(row: 0, section: indexPath.section))
                        firstPlayerCell?.accessoryType = UITableViewCell.AccessoryType.none
                        
                        firstPlayerCell = self.userCardSelectionContactsSearchResultTVC?.tableView.cellForRow(at: IndexPath(row: 0, section: indexPath.section))
                        firstPlayerCell?.accessoryType = UITableViewCell.AccessoryType.none
                        userCardSelectionSelectedContactsReferences.removeObject(at: 0)
                        userCardSelectionSelectedContactsReferences.insert(selectedContact!, at: 0)
                        
                        let indexPathSection:IndexPath? = IndexPath(row: 0, section: indexPath.section)
                        let row = self.userCardSelectionAddressBookContactsMutableArray?.index(of: selectedContact!)
                        mainTableCorrespondingIndexpath = IndexPath(row:row!, section:0)
                        userCardSelectionSelectedContactsReferences.removeObject(at: 0)
                        userCardSelectionSelectedContactsReferences.insert(selectedContact!, at: 0)
                        
                        self.userCardSelectionAddressBookContactsMutableArray?.removeObject(at: row!)
                        self.userCardSelectionAddressBookContactsMutableArray?.insert(selectedContact!, at: 0)
                        
                        firstPlayerCell = self.userCardSelectionContactsTVC?.tableView.cellForRow(at: IndexPath(row: 0, section: indexPath.section))
                        firstPlayerCell?.accessoryType = UITableViewCell.AccessoryType.none
                        
                        self.userCardSelectionContactsTVC?.tableView.deleteRows(at: [mainTableCorrespondingIndexpath!], with: UITableView.RowAnimation.none)
                        self.userCardSelectionContactsTVC?.tableView.insertRows(at: [indexPathSection!], with: UITableView.RowAnimation.none)
                        
                        
                        self.userCardSelectionContactsTVC?.tableView.endUpdates()
                        
                        self.userCardSelectionAddressBookContactsSearchResultsMutableArray?.removeObject(at: indexPath.row)
                        self.userCardSelectionAddressBookContactsSearchResultsMutableArray?.insert(selectedContact!, at: 0)
                        
                        self.userCardSelectionContactsSearchResultTVC?.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.none)
                        self.userCardSelectionContactsSearchResultTVC?.tableView.insertRows(at: [indexPathSection!], with: UITableView.RowAnimation.fade)
                        self.userCardSelectionContactsSearchResultTVC?.tableView.endUpdates()
                        
                        
                        
                        firstPlayerCell = self.userCardSelectionContactsTVC?.tableView.cellForRow(at: IndexPath(row: 0, section: indexPath.section))
                        firstPlayerCell?.accessoryType = UITableViewCell.AccessoryType.checkmark
                        
                        firstPlayerCell = self.userCardSelectionContactsSearchResultTVC?.tableView.cellForRow(at: IndexPath(row: 0, section: indexPath.section))
                        firstPlayerCell?.accessoryType = UITableViewCell.AccessoryType.checkmark
                        
                        
                    }
                    
                    
                }
                else
                {
                    firstPlayerCell = self.userCardSelectionContactsTVC?.tableView.cellForRow(at: IndexPath(row: 0, section: indexPath.section))
                    firstPlayerCell?.accessoryType = UITableViewCell.AccessoryType.none
                    
                    firstPlayerCell = self.userCardSelectionContactsSearchResultTVC?.tableView.cellForRow(at: IndexPath(row: 0, section: indexPath.section))
                    firstPlayerCell?.accessoryType = UITableViewCell.AccessoryType.none
                    
                    let indexPathSection:IndexPath? = IndexPath(row: 0, section: indexPath.section)
                    let row = self.userCardSelectionAddressBookContactsMutableArray?.index(of: selectedContact!)
                    mainTableCorrespondingIndexpath = IndexPath(row:row!, section:0)
                    userCardSelectionSelectedContactsReferences.insert(selectedContact!, at: 0)
                    
                    self.userCardSelectionAddressBookContactsMutableArray?.removeObject(at: row!)
                    self.userCardSelectionAddressBookContactsMutableArray?.insert(selectedContact!, at: 0)
                    
                    
                    self.userCardSelectionContactsTVC?.tableView.deleteRows(at: [mainTableCorrespondingIndexpath!], with: UITableView.RowAnimation.none)
                    self.userCardSelectionContactsTVC?.tableView.insertRows(at: [indexPathSection!], with: UITableView.RowAnimation.none)
                    self.userCardSelectionContactsTVC?.tableView.endUpdates()
                    
                    self.userCardSelectionAddressBookContactsSearchResultsMutableArray?.removeObject(at: indexPath.row)
                    self.userCardSelectionAddressBookContactsSearchResultsMutableArray?.insert(selectedContact!, at: 0)

                    self.userCardSelectionContactsSearchResultTVC?.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.none)
                    self.userCardSelectionContactsSearchResultTVC?.tableView.insertRows(at: [indexPathSection!], with: UITableView.RowAnimation.fade)
                    self.userCardSelectionContactsSearchResultTVC?.tableView.endUpdates()
                    
                    firstPlayerCell = self.userCardSelectionContactsTVC?.tableView.cellForRow(at: IndexPath(row: 0, section: indexPath.section))
                    firstPlayerCell?.accessoryType = UITableViewCell.AccessoryType.checkmark
                    
                    firstPlayerCell = self.userCardSelectionContactsSearchResultTVC?.tableView.cellForRow(at: IndexPath(row: 0, section: indexPath.section))
                    firstPlayerCell?.accessoryType = UITableViewCell.AccessoryType.checkmark
                    
                    if self.menuTableView != nil
                    {
                        self.menuTableView?.reloadRows(at: [IndexPath(row: 1, section: 0),IndexPath(row: 2, section: 0)], with: UITableView.RowAnimation.automatic)
                    }
                  
                }
                
            }
            self.userCardSelectionContactsSearchController?.isActive = false
        }
        else if tableView == self.contactsTVC?.tableView
        {
            
            if self.facebookContacts
            {
                var firstPlayerCell:UITableViewCell?
                var secondPlayerCell:UITableViewCell?
                let selectedContact:NSDictionary? = self.facebookContactsMutableArray?.object(at: indexPath.row) as? NSDictionary
                if selectedContact != nil
                {
                    //
                    
                    if selectedContactsReferences.count == 2
                    {
                        let firstRef:NSDictionary = selectedContactsReferences.object(at: 0)  as! NSDictionary
                        let secondRef:NSDictionary = selectedContactsReferences.object(at: 1) as! NSDictionary
                        let equalS = selectedContact?.isEqual(secondRef)
                        if selectedContact?.isEqual(firstRef) == true
                        {
                            self.contactsTVC?.tableView.beginUpdates()
                            selectedContactsReferences.removeObject(at: 0)
                            self.facebookContactsMutableArray?.removeObject(at: 0)
                            self.facebookContactsMutableArray?.insert(selectedContact!, at: 1)
                            let firstPlayerCellIndexPath:IndexPath? = IndexPath(row: 0, section: indexPath.section)
                            self.contactsTVC?.tableView.deleteRows(at: [firstPlayerCellIndexPath!], with: UITableView.RowAnimation.fade)
                            let secondPlayerCellIndexPath:IndexPath? = IndexPath(row: 1, section: indexPath.section)
                            self.contactsTVC?.tableView.insertRows(at: [secondPlayerCellIndexPath!], with: UITableView.RowAnimation.fade)
                            self.contactsTVC?.tableView.endUpdates()
                            firstPlayerCell = self.contactsTVC?.tableView.cellForRow(at: secondPlayerCellIndexPath!)
                            firstPlayerCell?.accessoryType = UITableViewCell.AccessoryType.none
                            
                        }
                        else if equalS == true
                        {
                            self.contactsTVC?.tableView.beginUpdates()
                            selectedContactsReferences.removeObject(at: 1)
                            
                            let secondPlayerCellIndexPath:IndexPath? = IndexPath(row: 1, section: indexPath.section)
                            self.contactsTVC?.tableView.endUpdates()
                            secondPlayerCell = self.contactsTVC?.tableView.cellForRow(at: secondPlayerCellIndexPath!)
                            secondPlayerCell?.accessoryType = UITableViewCell.AccessoryType.none
                            
                        }
                        else
                        {
                            self.contactsTVC?.tableView.beginUpdates()
                            selectedContactsReferences.removeObject(at: 1)
                            selectedContactsReferences.insert(selectedContact!, at: 0)
                            
                            self.contactsTVC?.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
                            
                            self.facebookContactsMutableArray?.removeObject(at: indexPath.row)
                            self.facebookContactsMutableArray?.insert(selectedContact!, at: 0)
                            
                            secondPlayerCell = self.contactsTVC?.tableView.cellForRow(at: IndexPath(row: 1, section: indexPath.section))
                            secondPlayerCell?.accessoryType = UITableViewCell.AccessoryType.none
                            
                            
                            let firstPlayerCellIndexPath:IndexPath? = IndexPath(row: 0, section: indexPath.section)
                            self.contactsTVC?.tableView.insertRows(at: [firstPlayerCellIndexPath!], with: UITableView.RowAnimation.fade)
                            self.contactsTVC?.tableView.endUpdates()
                            firstPlayerCell = self.contactsTVC?.tableView.cellForRow(at: IndexPath(row: 0, section: indexPath.section))
                            firstPlayerCell?.accessoryType = UITableViewCell.AccessoryType.checkmark
                        }
                        
                    }
                        
                    else if selectedContactsReferences.count == 1
                    {
                        let firstRef:NSDictionary = selectedContactsReferences.object(at: 0) as! NSDictionary
                        let equal = selectedContact?.isEqual(firstRef)
                        if equal == true
                        {
                            self.contactsTVC?.tableView.beginUpdates()
                            selectedContactsReferences.removeObject(at: 0)
                            let firstPlayerCellIndexPath:IndexPath? = IndexPath(row: 0, section: 0)
                            self.contactsTVC?.tableView.endUpdates()
                            firstPlayerCell = self.contactsTVC?.tableView.cellForRow(at: firstPlayerCellIndexPath!)
                            firstPlayerCell?.accessoryType = UITableViewCell.AccessoryType.none
                            
                        }
                        else
                        {
                            self.contactsTVC?.tableView.beginUpdates()
                            let firstPlayerCellIndexPath:IndexPath? = IndexPath(row: 0, section: 0)
                            
                            selectedContactsReferences.insert(selectedContact!, at: 0)
                            
                            self.facebookContactsMutableArray?.removeObject(at: indexPath.row)
                            
                            self.facebookContactsMutableArray?.insert(selectedContact!, at: 0)
                            
                            self.contactsTVC?.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
                            
                            self.contactsTVC?.tableView.insertRows(at: [firstPlayerCellIndexPath!], with: UITableView.RowAnimation.fade)
                            
                            self.contactsTVC?.tableView.endUpdates()
                            
                            firstPlayerCell = self.contactsTVC?.tableView.cellForRow(at: IndexPath(row: 0, section: 0))
                            firstPlayerCell?.accessoryType = UITableViewCell.AccessoryType.checkmark
                        }
                    }
                    else
                    {
                        
                        self.contactsTVC?.tableView.beginUpdates()
                        selectedContactsReferences.insert(selectedContact!, at: 0)
                        self.facebookContactsMutableArray?.removeObject(at: indexPath.row)
                        self.facebookContactsMutableArray?.insert(selectedContact!, at: 0)
                        self.contactsTVC?.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
                        let firstPlayerCellIndexPath:IndexPath? = IndexPath(row: 0, section: indexPath.section)
                        self.contactsTVC?.tableView.insertRows(at: [firstPlayerCellIndexPath!], with: UITableView.RowAnimation.fade)
                        self.contactsTVC?.tableView.endUpdates()
                        firstPlayerCell = self.contactsTVC?.tableView.cellForRow(at: IndexPath(row: 0, section: 0))
                        firstPlayerCell?.accessoryType = UITableViewCell.AccessoryType.checkmark
                    }
                }

            }
            else
            {
                var firstPlayerCell:UITableViewCell?
                var secondPlayerCell:UITableViewCell?
                let selectedContact:CNContact? = self.addressBookContactsMutableArray?.object(at: indexPath.row) as? CNContact
                if selectedContact != nil
                {
                    //
                    
                    if selectedContactsReferences.count == 2
                    {
                        let firstRef:CNContact = selectedContactsReferences.object(at: 0)  as! CNContact
                        let secondRef:CNContact = selectedContactsReferences.object(at: 1) as! CNContact
                        //let equalF = selectedContact?.isEqual(firstRef)
                        let equalS = selectedContact?.isEqual(secondRef)
                        if selectedContact?.isEqual(firstRef) == true
                        {
                            self.contactsTVC?.tableView.beginUpdates()
                            selectedContactsReferences.removeObject(at: 0)
                            self.addressBookContactsMutableArray?.removeObject(at: 0)
                            self.addressBookContactsMutableArray?.insert(selectedContact!, at: 1)
                            let firstPlayerCellIndexPath:IndexPath? = IndexPath(row: 0, section: indexPath.section)
                            self.contactsTVC?.tableView.deleteRows(at: [firstPlayerCellIndexPath!], with: UITableView.RowAnimation.fade)
                            let secondPlayerCellIndexPath:IndexPath? = IndexPath(row: 1, section: indexPath.section)
                            self.contactsTVC?.tableView.insertRows(at: [secondPlayerCellIndexPath!], with: UITableView.RowAnimation.fade)
                            self.contactsTVC?.tableView.endUpdates()
                            firstPlayerCell = self.contactsTVC?.tableView.cellForRow(at: secondPlayerCellIndexPath!)
                            firstPlayerCell?.accessoryType = UITableViewCell.AccessoryType.none
                            
                        }
                        else if equalS == true
                        {
                            self.contactsTVC?.tableView.beginUpdates()
                            selectedContactsReferences.removeObject(at: 1)
                            
                            let secondPlayerCellIndexPath:IndexPath? = IndexPath(row: 1, section: indexPath.section)
                            self.contactsTVC?.tableView.endUpdates()
                            secondPlayerCell = self.contactsTVC?.tableView.cellForRow(at: secondPlayerCellIndexPath!)
                            secondPlayerCell?.accessoryType = UITableViewCell.AccessoryType.none
                            
                        }
                        else
                        {
                            self.contactsTVC?.tableView.beginUpdates()
                            selectedContactsReferences.removeObject(at: 1)
                            selectedContactsReferences.insert(selectedContact!, at: 0)
                            
                            self.contactsTVC?.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
                            
                            self.addressBookContactsMutableArray?.removeObject(at: indexPath.row)
                            self.addressBookContactsMutableArray?.insert(selectedContact!, at: 0)
                            
                            secondPlayerCell = self.contactsTVC?.tableView.cellForRow(at: IndexPath(row: 1, section: indexPath.section))
                            secondPlayerCell?.accessoryType = UITableViewCell.AccessoryType.none
                            
                            
                            let firstPlayerCellIndexPath:IndexPath? = IndexPath(row: 0, section: indexPath.section)
                            self.contactsTVC?.tableView.insertRows(at: [firstPlayerCellIndexPath!], with: UITableView.RowAnimation.fade)
                            self.contactsTVC?.tableView.endUpdates()
                            firstPlayerCell = self.contactsTVC?.tableView.cellForRow(at: IndexPath(row: 0, section: indexPath.section))
                            firstPlayerCell?.accessoryType = UITableViewCell.AccessoryType.checkmark
                        }
                        
                    }
                        
                    else if selectedContactsReferences.count == 1
                    {
                        let firstRef:CNContact = selectedContactsReferences.object(at: 0) as! CNContact
                        let equal = selectedContact?.isEqual(firstRef)
                        if equal == true
                        {
                            self.contactsTVC?.tableView.beginUpdates()
                            selectedContactsReferences.removeObject(at: 0)
                            let firstPlayerCellIndexPath:IndexPath? = IndexPath(row: 0, section: 0)
                            self.contactsTVC?.tableView.endUpdates()
                            firstPlayerCell = self.contactsTVC?.tableView.cellForRow(at: firstPlayerCellIndexPath!)
                            firstPlayerCell?.accessoryType = UITableViewCell.AccessoryType.none
                            
                        }
                        else
                        {
                            self.contactsTVC?.tableView.beginUpdates()
                            let firstPlayerCellIndexPath:IndexPath? = IndexPath(row: 0, section: 0)
                            
                            selectedContactsReferences.insert(selectedContact!, at: 0)
                            
                            self.addressBookContactsMutableArray?.removeObject(at: indexPath.row)
                            
                            self.addressBookContactsMutableArray?.insert(selectedContact!, at: 0)
                            
                            self.contactsTVC?.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
                            
                            self.contactsTVC?.tableView.insertRows(at: [firstPlayerCellIndexPath!], with: UITableView.RowAnimation.fade)
                            
                            self.contactsTVC?.tableView.endUpdates()
                            
                            firstPlayerCell = self.contactsTVC?.tableView.cellForRow(at: IndexPath(row: 0, section: 0))
                            firstPlayerCell?.accessoryType = UITableViewCell.AccessoryType.checkmark
                        }
                    }
                    else
                    {
                        
                        let defaults = UserDefaults.standard
                        var userCardID:String? = nil
                        userCardID = defaults.object(forKey: "userCardID") as? String
                        var searchResultArray:NSArray?
                        var userCard:CNContact?
                        var userCardIndexPath:IndexPath?
                        if userCardID != nil
                        {
                            let comparisonOptions:NSString.CompareOptions = [NSString.CompareOptions.caseInsensitive, NSString.CompareOptions.diacriticInsensitive]
                            
                            let predicate: NSPredicate = NSPredicate( block: { (person, bindings) -> Bool in
                                let identifier: String? = (person as AnyObject).identifier
                                if identifier?.range(of: userCardID!, options: comparisonOptions, range: nil, locale: nil) != nil
                                {
                                    return true
                                }
                                return false
                            })
                            
                            searchResultArray = self.addressBookContactsMutableArray?.filtered(using: predicate) as NSArray?
                            if searchResultArray != nil && searchResultArray?.count > 0
                            {
                                userCard = searchResultArray?.object(at: 0) as? CNContact
                            
                            }
                            
                        }
                        
                        self.contactsTVC?.tableView.beginUpdates()
                        selectedContactsReferences.insert(selectedContact!, at: 0)
                        self.addressBookContactsMutableArray?.removeObject(at: indexPath.row)
                        self.addressBookContactsMutableArray?.insert(selectedContact!, at: 0)
                        self.contactsTVC?.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
                        let firstPlayerCellIndexPath:IndexPath? = IndexPath(row: 0, section: indexPath.section)
                        self.contactsTVC?.tableView.insertRows(at: [firstPlayerCellIndexPath!], with: UITableView.RowAnimation.fade)
                        if userCard != nil && !userCardSuggestionUsed
                        {
                            userCardIndexPath = IndexPath(row: (self.addressBookContactsMutableArray?.index(of: userCard!))!, section: indexPath.section)
                            self.selectedContactsReferences.insert(userCard!, at: 0)
                            self.addressBookContactsMutableArray?.removeObject(at: userCardIndexPath!.row)
                            self.addressBookContactsMutableArray?.insert(userCard!, at: 0)
                            self.contactsTVC?.tableView.deleteRows(at: [userCardIndexPath!], with: UITableView.RowAnimation.fade)
                            let secondPlayerCellIndexPath:IndexPath? = IndexPath(row: 1, section: indexPath.section)
                            self.contactsTVC?.tableView.insertRows(at: [secondPlayerCellIndexPath!], with: UITableView.RowAnimation.fade)
                            self.userCardSuggestionUsed = true
                        }
                        self.contactsTVC?.tableView.endUpdates()
                        firstPlayerCell = self.contactsTVC?.tableView.cellForRow(at: IndexPath(row: 0, section: 0))
                        firstPlayerCell?.accessoryType = UITableViewCell.AccessoryType.checkmark
                    }
                }

            }
            
        }
        
        else if tableView == self.contactsSearchResultTVC?.tableView
        {
            
            var firstPlayerCell:UITableViewCell?
            var secondPlayerCell:UITableViewCell?
            let selectedContact:CNContact? = self.addressBookContactsSearchResultsMutableArray?.object(at: indexPath.row) as? CNContact
            
            var mainTableCorrespondingIndexpath:IndexPath?
            
            if selectedContact != nil
            {
            self.contactsSearchResultTVC?.tableView.beginUpdates()
            self.contactsTVC?.tableView.beginUpdates()
            
            if selectedContactsReferences.count == 2
            {
                let firstRef:CNContact = selectedContactsReferences.object(at: 0) as! CNContact
                let secondRef:CNContact = selectedContactsReferences.object(at: 1) as! CNContact
                let equalF = selectedContact?.isEqual(firstRef)
                let equalS = selectedContact?.isEqual(secondRef)
                if equalF == true
                {
                    
                    selectedContactsReferences.removeObject(at: 0)
                    
                    
                   
                    let selectedContactIndexInSearchResultsTV:Int? = self.addressBookContactsSearchResultsMutableArray?.index(of: selectedContact!)
                    
                    let selectedContactIndexPathInSearchResultsTV:IndexPath = IndexPath(row: selectedContactIndexInSearchResultsTV!, section: 0)
                    
                    let firstPlayerCellIndexPath:IndexPath? = IndexPath(row: 0, section: 0)
                    
                    let secondPlayerCellIndexPath:IndexPath? = IndexPath(row: 1, section: 0)
                    
                    if self.addressBookContactsMutableArray?.count > 1
                    {
                    self.addressBookContactsMutableArray?.removeObject(at: 0)
                        
                    self.addressBookContactsMutableArray?.insert(selectedContact!, at: 1)
                        self.contactsTVC?.tableView.deleteRows(at: [firstPlayerCellIndexPath!], with: UITableView.RowAnimation.fade)
                        self.contactsTVC?.tableView.insertRows(at: [secondPlayerCellIndexPath!], with: UITableView.RowAnimation.fade)
                    self.contactsTVC?.tableView.endUpdates()
                    }
                    else
                    {
                        self.contactsTVC?.tableView.insertRows(at: [firstPlayerCellIndexPath!], with: UITableView.RowAnimation.fade)
                    self.contactsTVC?.tableView.endUpdates()
                    }
                
                    self.contactsSearchResultTVC?.tableView.endUpdates()
                    
                    firstPlayerCell = self.contactsSearchResultTVC?.tableView.cellForRow(at: selectedContactIndexPathInSearchResultsTV)
                    firstPlayerCell?.accessoryType = UITableViewCell.AccessoryType.none
                    
                    firstPlayerCell?.setSelected(false, animated: true)

                    firstPlayerCell = self.contactsTVC?.tableView.cellForRow(at: secondPlayerCellIndexPath!)
                    firstPlayerCell?.accessoryType = UITableViewCell.AccessoryType.none
                    
                    
                    
                }
                else if equalS == true
                {
                    selectedContactsReferences.removeObject(at: 1)
                    
                    let secondPlayerCellIndexPath:IndexPath? = IndexPath(row: 1, section: 0)
                    
                    let selectedContactIndexInSearchResultsTV:Int? = self.addressBookContactsSearchResultsMutableArray?.index(of: selectedContact!)
                    
                    let selectedContactIndexPathInSearchResultsTV:IndexPath = IndexPath(row: selectedContactIndexInSearchResultsTV!, section: 0)
                  
                    self.contactsSearchResultTVC?.tableView.endUpdates()
                  
                    self.contactsTVC?.tableView.endUpdates()
    
                    firstPlayerCell = self.contactsSearchResultTVC?.tableView.cellForRow(at: selectedContactIndexPathInSearchResultsTV)
                    firstPlayerCell?.accessoryType = UITableViewCell.AccessoryType.none
                    
                    firstPlayerCell?.setSelected(false, animated: true)
                    
                    firstPlayerCell = self.contactsTVC?.tableView.cellForRow(at: secondPlayerCellIndexPath!)
                    firstPlayerCell?.accessoryType = UITableViewCell.AccessoryType.none
                    
                }
                else
                {
                    let topIndexPathSection:IndexPath? = IndexPath(row: 0, section: indexPath.section)
                    let row = self.addressBookContactsMutableArray?.index(of: selectedContact!)
                    mainTableCorrespondingIndexpath = IndexPath(row:row!, section:0)
                    
                    self.selectedContactsReferences.removeObject(at: 1)
                    self.selectedContactsReferences.insert(selectedContact!, at: 0)
                    secondPlayerCell = self.contactsSearchResultTVC?.tableView.cellForRow(at: IndexPath(row: 1, section: indexPath.section))
                    secondPlayerCell?.accessoryType = UITableViewCell.AccessoryType.none
                    secondPlayerCell = self.contactsTVC?.tableView.cellForRow(at: IndexPath(row: 1, section: indexPath.section))
                    secondPlayerCell?.accessoryType = UITableViewCell.AccessoryType.none
                    
                    self.addressBookContactsMutableArray?.removeObject(at: row!)
                    self.addressBookContactsMutableArray?.insert(selectedContact!, at: 0)
                    
                    
                    self.contactsTVC?.tableView.deleteRows(at: [mainTableCorrespondingIndexpath!], with: UITableView.RowAnimation.none)
                    self.contactsTVC?.tableView.insertRows(at: [topIndexPathSection!], with: UITableView.RowAnimation.fade)
                    
                    self.addressBookContactsSearchResultsMutableArray?.removeObject(at: indexPath.row)
                    self.addressBookContactsSearchResultsMutableArray?.insert(selectedContact!, at: 0)
                    
                    self.contactsSearchResultTVC?.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.none)
                    self.contactsSearchResultTVC?.tableView.insertRows(at: [topIndexPathSection!], with: UITableView.RowAnimation.fade)
                    
                    self.contactsTVC?.tableView.endUpdates()
                    self.contactsSearchResultTVC?.tableView.endUpdates()
                    
                    
                    
                    firstPlayerCell = self.contactsTVC?.tableView.cellForRow(at: IndexPath(row: 0, section: indexPath.section))
                    firstPlayerCell?.accessoryType = UITableViewCell.AccessoryType.checkmark
                    firstPlayerCell = self.contactsSearchResultTVC?.tableView.cellForRow(at: IndexPath(row: 0, section: indexPath.section))
                    firstPlayerCell?.accessoryType = UITableViewCell.AccessoryType.checkmark
                }
                
                
                
            }
            else if selectedContactsReferences.count == 1
            {
      
                let firstRef:CNContact = selectedContactsReferences.object(at: 0) as! CNContact
                let equal = selectedContact?.isEqual(firstRef)
                if equal == true
                {
                    selectedContactsReferences.removeObject(at: 0)
                    let firstPlayerCellIndexPath:IndexPath? = IndexPath(row: 0, section: indexPath.section)
                    
                    self.contactsTVC?.tableView.endUpdates()
                    self.contactsSearchResultTVC?.tableView.endUpdates()
                    
                    firstPlayerCell = self.contactsSearchResultTVC?.tableView.cellForRow(at: firstPlayerCellIndexPath!)
                    firstPlayerCell?.accessoryType = UITableViewCell.AccessoryType.none
                    
                    firstPlayerCell = self.contactsTVC?.tableView.cellForRow(at: IndexPath(row: 0, section: indexPath.section))
                    firstPlayerCell?.accessoryType = UITableViewCell.AccessoryType.none
                }
                else
                {
                    let indexPathSection:IndexPath? = IndexPath(row: 0, section: indexPath.section)
                    let row = self.addressBookContactsMutableArray?.index(of: selectedContact!)
                    mainTableCorrespondingIndexpath = IndexPath(row:row!, section:0)
                    
                    selectedContactsReferences.insert(selectedContact!, at: 0)
                    self.addressBookContactsMutableArray?.removeObject(at: row!)
                    self.addressBookContactsMutableArray?.insert(selectedContact!, at: 0)
                    
                    self.addressBookContactsSearchResultsMutableArray?.removeObject(at: indexPath.row)
                    self.addressBookContactsSearchResultsMutableArray?.insert(selectedContact!, at: 0)
                    
                    
                    self.contactsTVC?.tableView.deleteRows(at: [mainTableCorrespondingIndexpath!], with: UITableView.RowAnimation.none)
                    self.contactsTVC?.tableView.insertRows(at: [indexPathSection!], with: UITableView.RowAnimation.fade)
                    self.contactsTVC?.tableView.endUpdates()
                    
                    self.contactsSearchResultTVC?.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.none)
                    self.contactsSearchResultTVC?.tableView.insertRows(at: [indexPathSection!], with: UITableView.RowAnimation.fade)
                    self.contactsSearchResultTVC?.tableView.endUpdates()
                    
                    
                    
                    
                    
                    
                    firstPlayerCell = self.contactsTVC?.tableView.cellForRow(at: IndexPath(row: 0, section: indexPath.section))
                    firstPlayerCell?.accessoryType = UITableViewCell.AccessoryType.checkmark
                    firstPlayerCell = self.contactsSearchResultTVC?.tableView.cellForRow(at: IndexPath(row: 0, section: indexPath.section))
                    firstPlayerCell?.accessoryType = UITableViewCell.AccessoryType.checkmark
                }
                
            }
            else
            {
                let defaults = UserDefaults.standard
                var userCardID:String? = nil
                userCardID = defaults.object(forKey: "userCardID") as? String
                var searchResultArray:NSArray?
                var userCard:CNContact?
                var userCardIndexPath:IndexPath?
                if userCardID != nil
                {
                    let comparisonOptions:NSString.CompareOptions = [NSString.CompareOptions.caseInsensitive, NSString.CompareOptions.diacriticInsensitive]
                    
                    let predicate: NSPredicate = NSPredicate( block: { (person, bindings) -> Bool in
                        let identifier: String? = (person as AnyObject).identifier
                        if identifier?.range(of: userCardID!, options: comparisonOptions, range: nil, locale: nil) != nil
                        {
                            return true
                        }
                        return false
                    })
                    
                    searchResultArray = self.addressBookContactsMutableArray?.filtered(using: predicate) as NSArray?
                    if searchResultArray != nil && searchResultArray?.count > 0
                    {
                        userCard = searchResultArray?.object(at: 0) as? CNContact
                        
                    }
                    
                }

                
                let indexPathSection:IndexPath? = IndexPath(row: 0, section: indexPath.section)
                let row = self.addressBookContactsMutableArray?.index(of: selectedContact!)
                mainTableCorrespondingIndexpath = IndexPath(row:row!, section:0)
                selectedContactsReferences.insert(selectedContact!, at: 0)
                
                self.addressBookContactsMutableArray?.removeObject(at: row!)
                self.addressBookContactsMutableArray?.insert(selectedContact!, at: 0)
                
                    
                    
                self.contactsTVC?.tableView.deleteRows(at: [mainTableCorrespondingIndexpath!], with: UITableView.RowAnimation.none)
                self.contactsTVC?.tableView.insertRows(at: [indexPathSection!], with: UITableView.RowAnimation.none)
                
                self.addressBookContactsSearchResultsMutableArray?.removeObject(at: indexPath.row)
                self.addressBookContactsSearchResultsMutableArray?.insert(selectedContact!, at: 0)
                
                self.contactsSearchResultTVC?.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.none)
                self.contactsSearchResultTVC?.tableView.insertRows(at: [indexPathSection!], with: UITableView.RowAnimation.fade)
                
                if userCard != nil && !userCardSuggestionUsed
                {
                    userCardIndexPath = IndexPath(row: (self.addressBookContactsMutableArray?.index(of: userCard!))!, section: indexPath.section)
                    
                    self.selectedContactsReferences.insert(userCard!, at: 0)
                    
                    self.addressBookContactsMutableArray?.removeObject(at: userCardIndexPath!.row)
                    self.addressBookContactsMutableArray?.insert(userCard!, at: 0)
                    
                    self.contactsTVC?.tableView.deleteRows(at: [userCardIndexPath!], with: UITableView.RowAnimation.fade)
                    let secondPlayerCellIndexPath:IndexPath? = IndexPath(row: 1, section: indexPath.section)
                    self.contactsTVC?.tableView.insertRows(at: [secondPlayerCellIndexPath!], with: UITableView.RowAnimation.fade)
                    
                    
                    
                    self.userCardSuggestionUsed = true
                }
                
                self.contactsTVC?.tableView.endUpdates()
                self.contactsSearchResultTVC?.tableView.endUpdates()
                
                firstPlayerCell = self.contactsTVC?.tableView.cellForRow(at: IndexPath(row: 0, section: indexPath.section))
                firstPlayerCell?.accessoryType = UITableViewCell.AccessoryType.checkmark
                
                firstPlayerCell = self.contactsSearchResultTVC?.tableView.cellForRow(at: IndexPath(row: 0, section: indexPath.section))
                firstPlayerCell?.accessoryType = UITableViewCell.AccessoryType.checkmark
                
                
            }
        
            }
            self.contactsSearchController?.isActive = false
            
        }
            
        else if tableView == self.scoresTableView
        {
        
            
        }
        else if tableView == self.menuTableView
        {
            if indexPath.row == Int(UIScreen.main.bounds.size.height/44) - 5
                {
                    tableView.deselectRow(at: indexPath, animated: true)
                    self.loadTutorial()
                }
            else if indexPath.row == Int(UIScreen.main.bounds.size.height/44) - 4
            {
            tableView.deselectRow(at: indexPath, animated: true)
            self.sendReport(self)
            }
        }
        else
        {
        tableView.deselectRow(at: indexPath, animated: true)
        }

    
    }
    
    override var shouldAutorotate: Bool
    {
        return false
        
        
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask{
        return UIInterfaceOrientationMask.portrait
    }
    
    func fetchEntities()
    {

    do {
        try self.matchesFetchedResultsController!.performFetch()
        self.matchesArray =  NSMutableArray(array: self.matchesFetchedResultsController!.fetchedObjects!)
    } catch let error1 as NSError {
        NSLog("Unresolved error %@, %@", error1, error1.userInfo)
    }
    }
    
    
    func fetchTrophies()
    {
        if self.matchesArray.count > 0
        {
        let currentMatch: Match? = self.matchesArray.object(at: self.currentSection()) as? Match
        self.leftTrophiesPredicate = NSPredicate(format: "(ANY participations.match == %@) AND (ANY participations.corner ==[c] 'l')", currentMatch!)
        self.rightTrophiesPredicate = NSPredicate(format: "(ANY participations.match == %@) AND (ANY participations.corner ==[c] 'r')", currentMatch!)
        self.leftTrophiesFetchResultsEntityDescription = NSEntityDescription.entity(forEntityName: "Trophy", in: managedObjectContext!)
        self.rightTophiesFetchResultsEntityDescription = NSEntityDescription.entity(forEntityName: "Trophy", in: managedObjectContext!)
        self.leftTrophiesSortDescriptor = NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
        self.rightTrophiesSortDescriptor = NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
        
            
        let leftTrophiesFetchRequest = NSFetchRequest<NSFetchRequestResult>()
        leftTrophiesFetchRequest.sortDescriptors = [leftTrophiesSortDescriptor!]
        leftTrophiesFetchRequest.entity = self.leftTrophiesFetchResultsEntityDescription
        leftTrophiesFetchRequest.predicate = leftTrophiesPredicate
        self.leftTrophiesFetchedResultsController = NSFetchedResultsController(fetchRequest: leftTrophiesFetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        
        
        self.leftTrophiesFetchedResultsController?.delegate = self
            
        let rightTrophiesFetchRequest = NSFetchRequest<NSFetchRequestResult>()
        rightTrophiesFetchRequest.sortDescriptors = [rightTrophiesSortDescriptor!]
        rightTrophiesFetchRequest.entity = self.rightTophiesFetchResultsEntityDescription
        rightTrophiesFetchRequest.predicate = rightTrophiesPredicate
        self.rightTrophiesFetchedResultsController = NSFetchedResultsController(fetchRequest: rightTrophiesFetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        
        self.rightTrophiesFetchedResultsController?.delegate = self
            
            do {
                try self.leftTrophiesFetchedResultsController!.performFetch()
                self.leftTrophiesArray =  NSMutableArray(array: self.leftTrophiesFetchedResultsController!.fetchedObjects!)
            } catch let error1 as NSError {

                NSLog("Unresolved error %@, %@", error1, error1.userInfo)
            }

            do {
                try self.rightTrophiesFetchedResultsController!.performFetch()
                self.rightTrophiesArray =  NSMutableArray(array: self.rightTrophiesFetchedResultsController!.fetchedObjects!)
            } catch let error1 as NSError {
                NSLog("Unresolved error %@, %@", error1, error1.userInfo)
            }
        
        
        }
    }
    
     func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller.fetchRequest.entity?.name == "Trophy"
        {
        self.scoresTableView?.beginUpdates()
        }
        
        if controller.fetchRequest.entity?.name == "Match"
        {
        }
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        if controller == self.matchesFetchedResultsController
        {
            switch type
            {
            case NSFetchedResultsChangeType.insert:
                self.matchesArray.add(anObject)
                let index = IndexPath(item: self.matchesArray.index(of: anObject), section: 0)
                if self.matchesArray.count == 1
                {
                    self.collectionView?.reloadData()
                }
                else
                {
                    self.collectionView?.insertItems(at: [index])
                }
                self.collectionView?.scrollToItem(at: index, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
                self.fetchTrophies()
            case NSFetchedResultsChangeType.delete:
                let index = IndexPath(item: self.matchesArray.index(of: anObject), section: 0)
                
                self.matchesArray.remove(anObject)
                self.collectionView?.deleteItems(at: [index])
                if matchesArray.count > 0
                {
                    self.collectionView?.scrollToItem(at: IndexPath(row: currentSection(), section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
                }
                
            default:
                _ = IndexPath(item: self.matchesArray.index(of: anObject), section: 0)
            }
            
        }
        else if controller == self.leftTrophiesFetchedResultsController
        {
            switch type
            {
            case NSFetchedResultsChangeType.insert:
                let indexRow = newIndexPath?.row
                self.leftTrophiesArray.insert(anObject, at: indexRow!)
                self.scoresTableView?.insertRows(at: [newIndexPath!], with: UITableView.RowAnimation.fade)

            case NSFetchedResultsChangeType.delete:
                let customIndexPath = IndexPath(row: leftTrophiesArray.index(of: anObject), section: 0)
                let customIndexPathRow = customIndexPath.row
                self.leftTrophiesArray.removeObject(at: customIndexPathRow)
                self.scoresTableView?.deleteRows(at: [indexPath!], with: UITableView.RowAnimation.fade)
            case NSFetchedResultsChangeType.update:
                let indexRow = indexPath?.row
                self.leftTrophiesArray.replaceObject(at: indexRow!, with: anObject)
                self.scoresTableView?.reloadRows(at: [indexPath!], with: UITableView.RowAnimation.fade)
            case NSFetchedResultsChangeType.move:
                self.leftTrophiesArray.removeObject(at: (indexPath?.row)!)
                self.leftTrophiesArray.insert(anObject, at: newIndexPath!.row)
                self.scoresTableView?.reloadRows(at: [indexPath!,newIndexPath!], with: UITableView.RowAnimation.fade)
            @unknown default:
                break
                
            }
            
        }
        else if controller == self.rightTrophiesFetchedResultsController
        {
        
           switch type
            {
            case NSFetchedResultsChangeType.insert:
                let indexRow = newIndexPath?.row
                self.rightTrophiesArray.insert(anObject, at: indexRow!)
            case NSFetchedResultsChangeType.delete:
                let customIndexPath = IndexPath(row: rightTrophiesArray.index(of: anObject), section: 0)
                let customIndexPathRow = customIndexPath.row
                self.rightTrophiesArray.removeObject(at: customIndexPathRow)
            case NSFetchedResultsChangeType.update:
                let indexRow = indexPath?.row
                self.rightTrophiesArray.replaceObject(at: indexRow!, with: anObject)
           case NSFetchedResultsChangeType.move:
                self.rightTrophiesArray.removeObject(at: (indexPath?.row)!)
                self.rightTrophiesArray.insert(anObject, at: newIndexPath!.row)
               self.scoresTableView?.reloadRows(at: [indexPath!,newIndexPath!], with: UITableView.RowAnimation.fade)
           @unknown default:
               break
            }
            
        }

    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller.fetchRequest.entity?.name == "Trophy"
        {
            self.scoresTableView?.endUpdates()
        }
        
        if controller.fetchRequest.entity?.name == "Match"
        {
            
        }
    }
    
    func createAddressBook() -> Bool {
        if self.addressBook != nil {
            return true
        }
        let err : Unmanaged<CFError>? = nil
        let adbk : CNContactStore? = CNContactStore()
        if adbk == nil {
            print(err!)
            self.addressBook = nil
            return false
        }
        self.addressBook = adbk
        return true
    }
    
    @objc func cancelPersonsSelection()
    {
        self.contactsTVC?.dismiss(animated: true, completion: nil)
        self.selectedContactsReferences.removeAllObjects()
        self.contactsTVC = nil
        self.userCardSuggestionUsed = false
    }
    @objc func deleteCurrentMatch()
    {
        
        let alert = UIAlertController(title: NSLocalizedString("Delete match",comment:""), message: NSLocalizedString("Are you sure you want to delete the match?",comment:""), preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: NSLocalizedString("OK",comment:""), style: UIAlertAction.Style.default) { (okSelected) -> Void in
            if self.matchesArray.count > 0
            {
                let currentMatch: Match = self.matchesArray.object(at: self.currentSection()) as! Match
                self.dbManager?.deleteMatch(currentMatch)
            }
        }
        let cancelButton = UIAlertAction(title: NSLocalizedString("Cancel",comment:""), style: UIAlertAction.Style.cancel, handler: nil)
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func commitPersonsSelection()
    {
        //hay que verificar que tenga elementos antes de ejecutar estas instrucciones
        if(self.selectedContactsReferences.count == 2)
        {
            
            let contactAforenames:String?
            let contactAsurenames:String?
            let contactACompanyName:String?
            let contactAFacebookID:String?
            let contactAAddressBookID:String?
            let contactBforenames:String?
            let contactBsurenames:String?
            var contactBCompanyName:String?
            var playerA:Player?
            var playerB:Player?
            var match:Match?
            var contactAPictureData:Data?
            var contactBPictureData:Data?
            let contactBFacebookID:String?
            let contactBAddressBookID:String?
            
            if self.facebookContacts
            {
                let contactA:NSDictionary = self.facebookContactsMutableArray!.object(at: 0) as! NSDictionary
                let contactB:NSDictionary = self.facebookContactsMutableArray!.object(at: 1) as! NSDictionary
                contactAforenames = contactA.object(forKey: "first_name") as? String
                contactAsurenames = contactA.object(forKey: "last_name")as? String
                contactACompanyName = nil
                contactAFacebookID = contactA.object(forKey: "id")as? String
                contactBforenames = contactB.object(forKey: "first_name")as? String
                contactBsurenames = contactB.object(forKey: "last_name")as? String
                contactBCompanyName = nil
                contactBFacebookID = contactB.object(forKey: "id")as? String
                contactAAddressBookID = ""
                contactBAddressBookID = ""
                
                
                    if let pictureDictionary = contactA.object(forKey: "picture") as? NSDictionary
                    {

                        if let dataDictionary = pictureDictionary.object(forKey: "data") as? NSDictionary
                        {

                            if let urlString = dataDictionary.object(forKey: "url") as? String
                            {
   
                                var error:NSError?
                                if (URL(string: urlString) as NSURL?)?.checkResourceIsReachableAndReturnError(&error) != nil
                                {

                                    let pictureData = try? Data(contentsOf: URL(string:urlString)!)
                                    if pictureData != nil
                                        {
                                        contactAPictureData = pictureData
                                        }
                                }
                            }
                        }
                    }
  
                    
                    
                
                
                    if let pictureDictionary = contactB.object(forKey: "picture") as? NSDictionary
                    {
                        if let dataDictionary = pictureDictionary.object(forKey: "data") as? NSDictionary
                        {
                            if let urlString = dataDictionary.object(forKey: "url") as? String
                            {
                                var error:NSError?
                                if (URL(string: urlString) as NSURL?)?.checkResourceIsReachableAndReturnError(&error) != true
                                {
                                    let pictureData = try? Data(contentsOf: URL(string:urlString)!)
                                    if pictureData != nil
                                    {
                                        contactBPictureData = pictureData
                                    }
                                }
                            }
                        }
                    }
  
            }
            else
            {
                let contactA:CNContact = self.selectedContactsReferences.object(at: 0) as! CNContact
                let contactB:CNContact = self.selectedContactsReferences.object(at: 1) as! CNContact
                contactAforenames = contactA.givenName
                contactAsurenames = contactA.familyName
                contactACompanyName = contactA.organizationName
                contactAFacebookID = nil
                contactBforenames = contactB.givenName
                contactBsurenames = contactB.familyName
                contactBCompanyName = contactB.organizationName
                contactBFacebookID = nil
                contactAAddressBookID = contactA.identifier
                contactBAddressBookID = contactB.identifier
                
                if((contactA.imageData) != nil)
                {
                    contactAPictureData = contactA.thumbnailImageData
                }
                if(contactB.imageData != nil)
                {
                    contactBPictureData = contactB.thumbnailImageData
                }
            }
            // SE ESTA HACIENDO UNA DOBLE VERIFICACION ESYO DEBERIA ESTAR DENTRO DE DBMANADGER YA QUE DENTRO DE SETPLAYER HAY OTRAS VERIFICACIONES
            //SE DEBERIA PODER PASAR TRANQUILAMENTE VALORES NULOS
            if self.facebookContacts && contactAFacebookID != nil
            {
                if let hashA = ("\(contactAforenames!) \(contactAsurenames!)").md5() {
                    playerA = (self.dbManager?.getPlayerWithFacebookID(contactAFacebookID))!
                    if playerA == nil
                    {
                        let aPlayer = self.dbManager?.createPlayer()
                        playerA = (self.dbManager?.setPlayer((aPlayer)!, id: NSUUID().uuidString, nameHash: hashA, forenames: contactAforenames as NSString?, surenames: contactAsurenames as NSString?, addressBookID: "", facebookID: contactAFacebookID as NSString?, googlePlusID: "", twitterID: "", gamecenterID: "", mobageID: "", mixiID: "", weiboID: "", picture: contactAPictureData))!
                    }
                    playerA?.picture = contactAPictureData! as NSData as Data
                }
                
            }
            else if contactAAddressBookID != nil
            {
            let hashA = ("\(contactAforenames!) \(contactAsurenames!)").md5()
                playerA = self.dbManager?.getPlayerWithABID(contactAAddressBookID)
                    if playerA == nil
                    {
                        playerA = self.dbManager?.createPlayer()
                        print(playerA as Any)
                        playerA = self.dbManager?.setPlayer(
                            playerA!,
                            id: NSUUID().uuidString,
                            nameHash: hashA,
                            forenames: (contactAforenames as NSString?),
                            surenames: contactAsurenames as NSString?,
                            addressBookID: contactAAddressBookID as NSString?,
                            facebookID: "",
                            googlePlusID: "",
                            twitterID: "",
                            gamecenterID: "",
                            mobageID: "",
                            mixiID: "",
                            weiboID: "",
                            picture: contactAPictureData
                            )
                    }
                playerA?.picture = contactAPictureData
                
                
            }
            else if contactAforenames != nil && contactAsurenames != nil
            {
                
                if let hashA = ("\(contactAforenames!) \(contactAsurenames!)").md5() {
                    playerA = (self.dbManager?.getPlayerWithNameHash(hashA))
                    if playerA == nil
                    {
                        playerA = (self.dbManager?.createPlayer())!
                        playerA = (self.dbManager?.setPlayer(playerA!, id: NSUUID().uuidString, nameHash: hashA, forenames: contactAforenames as NSString?, surenames: contactAsurenames as NSString?, addressBookID: contactAAddressBookID as NSString?, facebookID: "", googlePlusID: "", twitterID: "", gamecenterID: "", mobageID: "", mixiID: "", weiboID: "", picture: contactAPictureData))!
                    }
                }
            }
            else if contactAforenames != nil && contactAsurenames == nil
            {
                if let hashA = contactAforenames?.md5() {
                    playerA = (self.dbManager?.getPlayerWithNameHash(hashA))!
                    if playerA == nil
                    {
                        playerA = (self.dbManager?.createPlayer())!
                        playerA = (self.dbManager?.setPlayer(playerA!, id: "", nameHash: hashA, forenames: contactAforenames as NSString?, surenames: nil, addressBookID: contactAAddressBookID as NSString?, facebookID: "", googlePlusID: "", twitterID: "", gamecenterID: "", mobageID: "", mixiID: "", weiboID: "", picture: contactAPictureData))!
                    }
                }
            }
            else if contactAforenames == nil && contactAsurenames != nil
            {
                if let hashA = contactAsurenames?.md5() {
                    playerA = (self.dbManager?.getPlayerWithNameHash(hashA))!
                    if playerA == nil
                    {
                        playerA = (self.dbManager?.createPlayer())!
                        playerA = (self.dbManager?.setPlayer(playerA!, id: NSUUID().uuidString, nameHash: hashA, forenames: "", surenames: contactAsurenames as NSString?, addressBookID: contactAAddressBookID as NSString?, facebookID: "", googlePlusID: "", twitterID: "", gamecenterID: "", mobageID: "", mixiID: "", weiboID: "", picture: contactAPictureData))!
                    }
                }
            }
            else if contactACompanyName != nil
            {
                if let hashA = contactACompanyName?.md5() {
                    playerA = (self.dbManager?.getPlayerWithNameHash(hashA))!
                    if playerA == nil
                    {
                        playerA = (self.dbManager?.createPlayer())!
                        playerA = (self.dbManager?.setPlayer(playerA!, id: NSUUID().uuidString, nameHash: hashA, forenames: "", surenames: "", addressBookID: contactAAddressBookID as NSString?, facebookID: "", googlePlusID: "", twitterID: "", gamecenterID: "", mobageID: "", mixiID: "", weiboID: "", picture: contactAPictureData))!
                    }
                }
            }
        
        
            if self.facebookContacts && contactBFacebookID != nil
            {
                if let hashB = ("\(contactBforenames!) \(contactBsurenames!)").md5() {
                    playerB = (self.dbManager?.getPlayerWithFacebookID(contactBFacebookID))!
                    if playerB == nil
                    {
                        playerB = (self.dbManager?.createPlayer())!
                        playerB = ((self.dbManager?.setPlayer(playerB!, id: NSUUID().uuidString, nameHash: hashB, forenames: contactBforenames as NSString?, surenames: contactBsurenames as NSString?, addressBookID: "", facebookID: contactBFacebookID as NSString?, googlePlusID: "", twitterID: nil, gamecenterID: "", mobageID: "", mixiID: "", weiboID: "", picture: contactBPictureData)!))!
                    }
                    
                    playerB?.picture = contactBPictureData! as NSData as Data
                }
                
            }
            else if contactBAddressBookID != nil
            {
                let hashB = ("\(contactBforenames!) \(contactBsurenames!)").md5()
                playerB = (self.dbManager?.getPlayerWithABID(contactBAddressBookID))
                    if playerB == nil
                    {
                        playerB = self.dbManager?.createPlayer()
                        playerB = (self.dbManager?.setPlayer(playerB!, id: NSUUID().uuidString, nameHash: hashB, forenames: contactBforenames as NSString?, surenames: contactBsurenames as NSString?, addressBookID: contactBAddressBookID as NSString?, facebookID: "", googlePlusID: "", twitterID: "", gamecenterID: "", mobageID: "", mixiID: "", weiboID: "", picture: contactBPictureData))!
                    }
                playerB?.picture = contactBPictureData
                
                
            }
            else if contactBforenames != nil && contactBsurenames != nil
            {
                if let hashB = ("\(contactBforenames!) \(contactBsurenames!)").md5() {
                    playerB = (self.dbManager?.getPlayerWithNameHash(hashB))!
                    if playerB == nil
                    {
                        playerB = (self.dbManager?.createPlayer())!
                        playerB = (self.dbManager?.setPlayer(playerB!, id: NSUUID().uuidString, nameHash: hashB, forenames: contactBforenames as NSString?, surenames: contactBsurenames as NSString?, addressBookID: contactBAddressBookID as NSString?, facebookID: "", googlePlusID: "", twitterID: "", gamecenterID: "", mobageID: "", mixiID: "", weiboID: "", picture: contactBPictureData))!
                    }
                }

            }
            else if contactBforenames != nil && contactBsurenames == nil
            {
                if let hashB = contactBforenames?.md5() {
                    playerB = (self.dbManager?.getPlayerWithNameHash(hashB))!
                    if playerB == nil
                    {
                        playerB = (self.dbManager?.createPlayer())!
                        playerB = (self.dbManager?.setPlayer(playerB!, id: NSUUID().uuidString, nameHash: hashB, forenames: contactBforenames as NSString?, surenames: "", addressBookID:contactBAddressBookID as NSString?, facebookID: "", googlePlusID: "", twitterID: "", gamecenterID: "", mobageID: "", mixiID: "", weiboID: "", picture: contactBPictureData))!
                    }
                }
            }
            else if contactBforenames == nil && contactBsurenames != nil
            {
                if let hashB = contactBsurenames?.md5() {
                    playerB = (self.dbManager?.getPlayerWithNameHash(hashB))!
                    if playerB == nil
                    {
                        playerB = (self.dbManager?.createPlayer())!
                        playerB = (self.dbManager?.setPlayer(playerB!, id: NSUUID().uuidString, nameHash: hashB, forenames: nil, surenames: contactBsurenames as NSString? , addressBookID: contactBAddressBookID as NSString?, facebookID: "", googlePlusID: "", twitterID: "", gamecenterID: "", mobageID: "", mixiID: "", weiboID: "", picture: contactBPictureData))!
                    }
                }
            }
            else if contactBCompanyName != nil
            {
                if let hashB = contactBCompanyName?.md5() {
                    playerB = (self.dbManager?.getPlayerWithNameHash(hashB))!
                    if playerB == nil
                    {
                        playerB = (self.dbManager?.createPlayer())!
                        playerB = (self.dbManager?.setPlayer(playerB!, id: NSUUID().uuidString, nameHash: hashB, forenames: contactBCompanyName as NSString?, surenames: "", addressBookID: contactBAddressBookID as NSString?, facebookID: "", googlePlusID: "", twitterID: "", gamecenterID: "", mobageID: "", mixiID: "", weiboID: "", picture: contactBPictureData))!
                    }
                }
            }
            
        if playerA != nil && playerB != nil
        {

            match = self.dbManager?.createMatch()
            _ = self.dbManager?.addPlayer(playerA!, toMatch: match!, corner: "l")
            _ = self.dbManager?.addPlayer(playerB!, toMatch: match!, corner: "r")
        }
           
        self.dismiss(animated: true, completion: nil)
        self.selectedContactsReferences.removeAllObjects()
        self.contactsTVC = nil
        self.userCardSuggestionUsed = false
        }
        else
        {
       
        }
        
    }
    
    @objc func addTrophyToCurrentMatch()
    {
        if self.editMode == false
        {
            
            if self.matchesArray.count > 0
            
            {
                let currentMatch: Match = self.matchesArray.object(at: self.currentSection()) as! Match
                
                
                if currentMatch.participants != nil && currentMatch.participants?.count > 1
                {
                    let alert = UIAlertController(title: NSLocalizedString("Trophy Name",comment:""), message: NSLocalizedString("Give the trophy a name",comment:""), preferredStyle: UIAlertController.Style.alert)
                    let okButton = UIAlertAction(title: NSLocalizedString("OK",comment:""), style: UIAlertAction.Style.default) { (okSelected) -> Void in
                    
                    let aTrophy:Trophy? = self.dbManager?.createTrophy()
                    let trophyNameString = self.trophyNameTextFiled?.text
                    aTrophy?.name = trophyNameString! as NSString
                    _ = self.dbManager?.addTrophy(aTrophy, toMatch: currentMatch)
                }
                    let cancelButton = UIAlertAction(title: NSLocalizedString("Cancel",comment:""), style: UIAlertAction.Style.cancel) { (cancelSelected) -> Void in
                    
                }
                alert.addTextField(configurationHandler: {(textField: UITextField!) in
                    textField.placeholder = NSLocalizedString("Trophy Name",comment:"")
                    textField.isSecureTextEntry = false
                    self.trophyNameTextFiled = textField
                })
                    
                alert.addAction(okButton)
                alert.addAction(cancelButton)
                self.present(alert, animated: true, completion: nil)
                }
                else
                {
                }
            }
            
        }
        else if self.editMode == true
        {
        if self.selectedTrophies.count > 0
            {
            self.removeSelectedTrophies()
            }
        }
    }
    
    
    @objc func cellTapped(_ tapGestureRecognizer:UITapGestureRecognizer)
    {
        let inScoresTableviewTapPosition = tapGestureRecognizer.location(in: self.scoresTableView)
        let selectedCellIndex = self.scoresTableView?.indexPathForRow(at: inScoresTableviewTapPosition)
        if(self.navigationController?.view.frame.origin.x == 0 && selectedCellIndex != nil )
        {
        
        let cell = self.scoresTableView?.cellForRow(at: selectedCellIndex!)
        let inCellTapPosition = tapGestureRecognizer.location(in: cell)
        let currentMatchIndexPath:IndexPath = IndexPath(row: currentSection(), section: 0)
        let matchCell:IKSMatchCell = self.collectionView?.cellForItem(at: currentMatchIndexPath) as! IKSMatchCell
        let currentMatch: Match? = self.matchesArray.object(at: self.currentSection()) as? Match
        let cornerSortDescriptor = NSSortDescriptor(key: "corner", ascending: true)
        let factoryArray:NSArray? = currentMatch?.participants!.allObjects as NSArray?
            let matchedParticipants:NSArray? =  factoryArray?.sortedArray(using: [cornerSortDescriptor]) as NSArray?
        let participationA:Participation = matchedParticipants?.object(at: 0) as! Participation
        let participationB:Participation = matchedParticipants?.object(at: 1) as! Participation
        var rightScoreCount:Int? = 0
        var leftScoreCount:Int? = 0
        let scoresCellWidth = cell!.frame.size.width
        let scoresCellHeight = cell!.frame.size.height
        let leftXPos  =  scoresCellWidth * 0.3125
        let rightXPos =  scoresCellWidth * 0.6875
        var cellHeightCorrection = 1.0
        
        if self.readMoreIndexPath != nil && self.readMoreIndexPath?.row == selectedCellIndex?.row
        {
            cellHeightCorrection = 0.33
        }
        let maxLeftYPos  =  (CGFloat(scoresCellHeight) * CGFloat(cellHeightCorrection)) + (self.scoresTableView?.rectForRow(at: selectedCellIndex!).origin.y)!
            
        let maxRightYPos =  (CGFloat(scoresCellHeight) * CGFloat(cellHeightCorrection)) + (self.scoresTableView?.rectForRow(at: selectedCellIndex!).origin.y)!
            
        let minLeftYPos  =  (self.scoresTableView?.rectForRow(at: selectedCellIndex!).origin.y)!
        let minRightYPos =  (self.scoresTableView?.rectForRow(at: selectedCellIndex!).origin.y)!
            
        
        if inScoresTableviewTapPosition.x <= leftXPos && inScoresTableviewTapPosition.y <= maxLeftYPos && inScoresTableviewTapPosition.y >= minLeftYPos
        {
         
            if (cell as? IKSTrophyCell != nil)
            {
                UIView.animate(withDuration: 0.11, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations: {(cell as! IKSTrophyCell).leftImageView!.transform = CGAffineTransform(scaleX: 6.0, y: 6.0)}, completion: {completion in UIView.animate(withDuration: 0.1, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations: {(cell as! IKSTrophyCell).leftImageView!.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)}, completion: {completion in
                })})
            }
            else if (cell as? IKSTrophyBigCell != nil)
            {
                UIView.animate(withDuration: 0.11, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations: {(cell as! IKSTrophyBigCell).leftImageView!.transform = CGAffineTransform(scaleX: 6.0, y: 6.0)}, completion: {completion in UIView.animate(withDuration: 0.1, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations: {(cell as! IKSTrophyBigCell).leftImageView!.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)}, completion: {completion in
                })})
            }
            
            
            
            if matchedParticipants != nil && matchedParticipants?.count == 2
            {
                
                let participantA = matchedParticipants?.object(at: 0) as! Participation
                let participantATrophies:NSMutableArray = NSMutableArray(array: participantA.trophies.allObjects)
                
                let selectedCellIndexRow = selectedCellIndex?.row
                //ordenar trofeos por nombre
                let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
                participantATrophies.sort(using: [nameSortDescriptor])
                let selectedATrophy:Trophy = self.leftTrophiesArray.object(at: selectedCellIndexRow!) as! Trophy
                var saveError:NSError?
                var selectedATrophyCount:Int? = 0
                if self.editMode == true
                {
                //selectedATrophyCount = Int(selectedATrophy.score!) - 1
                    selectedATrophyCount = Int(truncating: selectedATrophy.score!) - 1
                    
                if selectedATrophyCount < 0
                {
                    selectedATrophyCount = 0
                }
                }
                else if self.editMode == false
                {
                
                    if self.editingIndexPath == selectedCellIndex
                    {
                        
                    //selectedATrophyCount = Int(selectedATrophy.score!) - 1
                    selectedATrophyCount = Int(truncating:selectedATrophy.score!) - 1
                    }
                    else
                    {
                    //selectedATrophyCount = Int(selectedATrophy.score!) + 1
                        selectedATrophyCount = Int(truncating:selectedATrophy.score!) + 1
                    }
                }
                if selectedATrophyCount >= 0
                {
                    selectedATrophy.score = selectedATrophyCount! as NSNumber
                    selectedATrophy.modificationDate = Date() as NSDate
                    do {
                        try self.managedObjectContext!.save()
                    } catch let error as NSError {
                        saveError = error
                        NSLog("Unresolved error \(saveError!), \(saveError!.userInfo)")
                    }
                }
                
                for aTrophy:Trophy in participationB.trophies.allObjects as! [Trophy]
                {
                    let value = aTrophy.score!.int32Value
                    if aTrophy.substracts
                    {
                        rightScoreCount = rightScoreCount! - Int(value)
                    }
                    else
                    {
                        rightScoreCount = rightScoreCount! + Int(value)
                    }
                    
                }
                
                for aTrophy:Trophy in participationA.trophies.allObjects as! [Trophy]
                {
                    let value = aTrophy.score!.int32Value
                    
                    if aTrophy.substracts
                    {
                        leftScoreCount = leftScoreCount! - Int(value)
                    }
                    else
                    {
                        leftScoreCount = leftScoreCount! + Int(value)
                    }
                }
                
                
                if (cell as? IKSTrophyBigCell != nil)
                {
                    (cell as? IKSTrophyBigCell)!.leftIconCounterLabel?.text = selectedATrophy.score!.stringValue
                }
                
                
                matchCell.setLeftScore(100 - rightScoreCount! + leftScoreCount!, andRightScoreAnimated: 100 - leftScoreCount! + rightScoreCount!)
            }

        }
        else if inScoresTableviewTapPosition.x >= rightXPos && inScoresTableviewTapPosition.y <= maxRightYPos && inScoresTableviewTapPosition.y >= minRightYPos
        {
            if (cell as? IKSTrophyCell != nil)
            {
                UIView.animate(withDuration: 0.11, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations: {(cell as! IKSTrophyCell).rightImageView!.transform = CGAffineTransform(scaleX: 6.0, y: 6.0)}, completion: {completion in UIView.animate(withDuration: 0.1, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations: {(cell as! IKSTrophyCell).rightImageView!.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)}, completion: {completion in
            })})
            }
            else if (cell as? IKSTrophyBigCell != nil)
            {
                UIView.animate(withDuration: 0.11, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations: {(cell as! IKSTrophyBigCell).rightImageView!.transform = CGAffineTransform(scaleX: 6.0, y: 6.0)}, completion: {completion in UIView.animate(withDuration: 0.1, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations: {(cell as! IKSTrophyBigCell).rightImageView!.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)}, completion: {completion in
                })})
            }

            if matchedParticipants != nil && matchedParticipants?.count == 2
            {
                
                
                
                let participantB = matchedParticipants?.object(at: 1) as! Participation
                let participantBTrophies:NSMutableArray = NSMutableArray(array: participantB.trophies.allObjects)
                
                let selectedCellIndexRow = selectedCellIndex?.row
                let selectedBTrophy:Trophy = self.rightTrophiesArray.object(at: selectedCellIndexRow!) as! Trophy
    
                let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
                participantBTrophies.sort(using: [nameSortDescriptor])
                var selectedBTrophyCount:Int? = 0
                if self.editMode == true
                {
                    //selectedBTrophyCount = Int(selectedBTrophy.score!) - 1
                    selectedBTrophyCount = Int(truncating:selectedBTrophy.score!) - 1
                    if selectedBTrophyCount < 0
                    {
                        selectedBTrophyCount = 0
                    }
                }
                else if self.editMode == false
                {
                    
                    
                    if self.editingIndexPath == selectedCellIndex
                    {
                       //selectedBTrophyCount = Int(selectedBTrophy.score!) - 1
                        selectedBTrophyCount = Int(truncating:selectedBTrophy.score!) - 1
                    }
                    else
                    {
                        //selectedBTrophyCount = Int(selectedBTrophy.score!) + 1
                        selectedBTrophyCount = Int(truncating:selectedBTrophy.score!) + 1
                    }
                }
                
                if selectedBTrophyCount >= 0
                {
                    selectedBTrophy.score = selectedBTrophyCount! as NSNumber
                    selectedBTrophy.modificationDate = Date() as NSDate
                    
                    do {
                        try self.managedObjectContext!.save()
                    } catch let error as NSError {
                        
                        NSLog("Unresolved error \(error), \(error.userInfo)")
                    }
                }
                
                
                for aTrophy:Trophy in participationB.trophies.allObjects as! [Trophy]
                {
                    let value = aTrophy.score!.int32Value
                    
                    if aTrophy.substracts
                    {
                        rightScoreCount = rightScoreCount! - Int(value)
                    }
                    else
                    {
                        rightScoreCount = rightScoreCount! + Int(value)
                    }
                }
                
                for aTrophy:Trophy in participationA.trophies.allObjects as! [Trophy]
                {
                    let value = aTrophy.score!.int32Value
                    
                    if aTrophy.substracts
                    {
                        leftScoreCount = leftScoreCount! - Int(value)
                    }
                    else
                    {
                        leftScoreCount = leftScoreCount! + Int(value)
                    }
                    
                }
                
                if (cell as? IKSTrophyBigCell != nil)
                {
                (cell as? IKSTrophyBigCell)!.rightIconCounterLabel?.text = selectedBTrophy.score!.stringValue
                }
 
                
                matchCell.setLeftScore(100 - rightScoreCount! + leftScoreCount!, andRightScoreAnimated: 100 - leftScoreCount! + rightScoreCount!)
            }

        }
        else if (cell as? IKSTrophyBigCell != nil)
        {
            if ((cell as! IKSTrophyBigCell).button5View!.frame.contains(inCellTapPosition) == true)
            {
                self.selectedTrophies.add(selectedCellIndex!)
                self.removeSelectedTrophies()
            
            }
            
            else if ((cell as! IKSTrophyBigCell).button3View!.frame.contains(inCellTapPosition) == true)
            {
                
                UIView.animate(withDuration: 0.1, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations: {(cell as! IKSTrophyBigCell).button3View!.transform = CGAffineTransform(scaleX: 6.0, y: 6.0)}, completion: {completion in UIView.animate(withDuration: 0.0, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations: {(cell as! IKSTrophyBigCell).button3View!.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)}, completion: {completion in
                    
                    if self.editMode == false
                    {
                        
                        if self.matchesArray.count > 0
                            
                        {
                            let selectedCellIndexRow = selectedCellIndex?.row
                            let selectedATrophy:Trophy = self.leftTrophiesArray.object(at: selectedCellIndexRow!) as! Trophy
                            let selectedBTrophy:Trophy = self.rightTrophiesArray.object(at: selectedCellIndexRow!) as! Trophy
                            
                            let alert = UIAlertController(title: NSLocalizedString("Trophy Name",comment:""), message: NSLocalizedString("Give the trophy a name",comment:""), preferredStyle: UIAlertController.Style.alert)
                            let okButton = UIAlertAction(title: NSLocalizedString("OK",comment:""), style: UIAlertAction.Style.default) { (okSelected) -> Void in
                                
                                
                                let trophyNameString = self.trophyNameTextFiled?.text
                                
                                selectedATrophy.name = trophyNameString! as NSString
                                selectedBTrophy.name = trophyNameString! as NSString
                                self.dbManager?.saveContext()
                            }
                            let cancelButton = UIAlertAction(title: NSLocalizedString("Cancel",comment:""), style: UIAlertAction.Style.cancel) { (cancelSelected) -> Void in
                                
                            }
                            alert.addTextField(configurationHandler: {(textField: UITextField!) in
                                textField.placeholder = NSLocalizedString("Trophy Name",comment:"")
                                textField.isSecureTextEntry = false
                                textField.text = selectedATrophy.name as String?
                                self.trophyNameTextFiled = textField
                            })
                            alert.addAction(okButton)
                            alert.addAction(cancelButton)
                            
                            self.present(alert, animated: true, completion: nil)
                        }
                        
                    }
                    else if self.editMode == true
                    {
                        if self.selectedTrophies.count > 0
                        {
                            self.removeSelectedTrophies()
                        }
                    }
                    
                    
                })})
            
            }
            
            else if ((cell as! IKSTrophyBigCell).button2View!.frame.contains(inCellTapPosition) == true)
            {
            if self.editingIndexPath == nil
                {
                    self.editingIndexPath = selectedCellIndex
                    self.scoresTableView?.beginUpdates()
                    self.scoresTableView?.deselectRow(at: selectedCellIndex!, animated: false)
                self.scoresTableView?.reloadRows(at: [selectedCellIndex!], with: UITableView.RowAnimation.fade)
                    self.scoresTableView?.endUpdates()
                
                }
                else
                {
                    self.editingIndexPath = nil
                    self.scoresTableView?.beginUpdates()
                    self.scoresTableView?.deselectRow(at: selectedCellIndex!, animated: false)
                    self.scoresTableView?.reloadRows(at: [selectedCellIndex!], with: UITableView.RowAnimation.fade)
                    self.scoresTableView?.endUpdates()
                }
            }
            else if ((cell as! IKSTrophyBigCell).button1View!.frame.contains(inCellTapPosition) == true)
            {
                if self.editMode == false
                {
                    
                    if self.matchesArray.count > 0
                        
                    {
                        let selectedCellIndexRow = selectedCellIndex?.row
                        let selectedATrophy:Trophy = self.leftTrophiesArray.object(at: selectedCellIndexRow!) as! Trophy
                        let selectedBTrophy:Trophy = self.rightTrophiesArray.object(at: selectedCellIndexRow!) as! Trophy
                        
                        if selectedATrophy.substracts
                        {
                            selectedATrophy.substracts = false
                            selectedBTrophy.substracts = false
                        }
                        else
                        {
                            selectedATrophy.substracts = true
                            selectedBTrophy.substracts = true
                        }
                        
                        self.dbManager?.saveContext()
                        
                        for aTrophy:Trophy in participationB.trophies.allObjects as! [Trophy]
                        {
                            let value = aTrophy.score!.int32Value
                            
                            if aTrophy.substracts
                            {
                                rightScoreCount = rightScoreCount! - Int(value)
                            }
                            else
                            {
                                rightScoreCount = rightScoreCount! + Int(value)
                            }
                        }
                        
                        for aTrophy:Trophy in participationA.trophies.allObjects as! [Trophy]
                        {
                            let value = aTrophy.score!.int32Value
                            
                            if aTrophy.substracts
                            {
                                leftScoreCount = leftScoreCount! - Int(value)
                            }
                            else
                            {
                                leftScoreCount = leftScoreCount! + Int(value)
                            }
                            
                        }
                        
                        matchCell.setLeftScore(100 - rightScoreCount! + leftScoreCount!, andRightScoreAnimated: 100 - leftScoreCount! + rightScoreCount!)
                    }
                    
                }
                else if self.editMode == true
                {
                    if self.selectedTrophies.count > 0
                    {
                        
                    }
                }
                
            }
        }
        else
            {
                if self.editMode == true
                {
                    
                }
                else if self.editMode == false
                {
                    
                }

            }
            
        }
        
    }
    
    @objc func cellLongPressed(_ longPressGesturer:UILongPressGestureRecognizer)
    {
        let inScoresTableviewTapPosition = longPressGesturer.location(in: self.scoresTableView)
        let selectedCellIndex:IndexPath? = self.scoresTableView?.indexPathForRow(at: inScoresTableviewTapPosition)
        
        if longPressGesturer.state == UIGestureRecognizer.State.began
            
        {
            if selectedCellIndex != nil
            {
            
                if self.editingIndexPath != nil
                {
                    self.editingIndexPath = nil
                    
                }
                
            if self.readMoreIndexPath != nil && readMoreIndexPath!.row == selectedCellIndex!.row
            {
                
                self.readMoreIndexPath = nil
                self.scoresTableView?.beginUpdates()
                self.scoresTableView?.deselectRow(at: selectedCellIndex!, animated: false)
                self.scoresTableView?.reloadRows(at: [selectedCellIndex!], with: UITableView.RowAnimation.fade)
                self.scoresTableView?.endUpdates()
            }
            else if self.readMoreIndexPath != nil && readMoreIndexPath!.row != selectedCellIndex!.row
            {
                let oldIndexpath:IndexPath = self.readMoreIndexPath!
                
                self.scoresTableView?.beginUpdates()
                self.scoresTableView?.deselectRow(at: selectedCellIndex!, animated: false)
                self.readMoreIndexPath = nil
                self.scoresTableView?.reloadRows(at: [oldIndexpath], with: UITableView.RowAnimation.fade)
                self.readMoreIndexPath = selectedCellIndex
                self.scoresTableView?.reloadRows(at: [selectedCellIndex!], with: UITableView.RowAnimation.fade)
                self.scoresTableView?.endUpdates()
                
            }
                
            else
            {
                self.readMoreIndexPath = selectedCellIndex
                self.scoresTableView?.beginUpdates()
                self.scoresTableView?.deselectRow(at: selectedCellIndex!, animated: false)
                self.scoresTableView?.reloadRows(at: [selectedCellIndex!], with: UITableView.RowAnimation.fade)
                self.scoresTableView?.endUpdates()
            }
                
                
            
        }
        }
    }
    
    
    
    @objc func matchCellLongPressed(_ longPressGesturer:UILongPressGestureRecognizer)
    {
        
        if longPressGesturer.state == UIGestureRecognizer.State.began
            
        {
            let inScoresTableviewTapPosition = longPressGesturer.location(in: self.collectionView)
            let selectedCellIndexPath:IndexPath? = IndexPath(item: currentSection(), section: 0)
            if selectedCellIndexPath != nil
            {
                let matchCell:IKSMatchCell = (self.collectionView?.cellForItem(at: selectedCellIndexPath!) as? IKSMatchCell)!
                let pointInCell = matchCell.convert(inScoresTableviewTapPosition, from: self.collectionView)
                if  (matchCell.leftCornerView?.frame.contains(pointInCell) == true)
                {
                    UIView.animate(withDuration: 0.12, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations: {matchCell.leftCornerView?.alpha = 0.0;matchCell.leftCornerView?.transform = CGAffineTransform(scaleX: 1.7, y: 1.7)}, completion: {completion in UIView.animate(withDuration: 0.12, delay: 0.0, options: UIView.AnimationOptions.autoreverse, animations: {matchCell.leftCornerView?.alpha = 1.0;matchCell.leftCornerView?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)}, completion: {completion in })})
                }
                
                if  (matchCell.rightCornerView?.frame.contains(pointInCell) == true)
                {
                    UIView.animate(withDuration: 0.12, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations: {matchCell.rightCornerView?.alpha = 0.0;matchCell.rightCornerView?.transform = CGAffineTransform(scaleX: 1.7, y: 1.7)}, completion: {completion in UIView.animate(withDuration: 0.12, delay: 0.0, options: UIView.AnimationOptions.autoreverse, animations: {matchCell.rightCornerView?.alpha = 1.0;matchCell.rightCornerView?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)}, completion: {completion in })})
                }
            }
            else{

            }
        }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    func imageFromText(_ text:String) -> UIImage?
    {
    
    let font:UIFont = UIFont.init(name: "DINCondensed-bold", size: 25)!
    
    let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
    
        let textFontAttributes:[NSAttributedString.Key: Any] = [NSAttributedString.Key.paragraphStyle:paragraphStyle,NSAttributedString.Key.font:font]
    let size:CGSize  = CGSize(width: 46, height: 46)

    UIGraphicsBeginImageContextWithOptions(size,false,0.0)
    
        NSString(string: text).draw(in: CGRect(x: 0, y: 14, width: 46, height: 46), withAttributes: textFontAttributes)

    let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext();
    
    return image
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        if searchBar ==  self.contactsSearchController?.searchBar
        {
            self.filterContentForSearchText(searchText)
        }
        else if searchBar == self.userCardSelectionContactsSearchController!.searchBar
        {
        filterUserCardSelectionContactsForSearchText(searchText)
        }
        
    }
    
    func filterContentForSearchText(_ searchText:String)
    {
        let comparisonOptions:NSString.CompareOptions = [NSString.CompareOptions.caseInsensitive, NSString.CompareOptions.diacriticInsensitive]
        
        if facebookContacts
        {
            let predicate: NSPredicate = NSPredicate( block: { (person, bindings) -> Bool in
                let firstName: String = ((person as AnyObject).object(forKey: "first_name") as? String)!
                let lastName: String = ((person as AnyObject).object(forKey: "last_name") as? String)!
                if firstName.range(of: searchText, options: comparisonOptions, range: nil, locale: nil) != nil || lastName.range(of: searchText, options: comparisonOptions, range: nil, locale: nil) != nil
                {
                    return true
                }
                return false
            })
            
            let searchResultArray = self.facebookContactsMutableArray?.filtered(using: predicate)
            self.facebookContactsSearchResultsMutableArray = NSMutableArray(array: searchResultArray!, copyItems: false)
            self.contactsSearchResultTVC?.tableView.reloadData()
        }
        else
        {
            let predicate: NSPredicate = NSPredicate( block: { (person, bindings) -> Bool in
                let firstName: String = (person as AnyObject).givenName
                let lastName: String = (person as AnyObject).familyName
                let companyName:String = (person as AnyObject).organizationName
                if firstName.range(of: searchText, options: comparisonOptions, range: nil, locale: nil) != nil || lastName.range(of: searchText, options: comparisonOptions, range: nil, locale: nil) != nil || companyName.range(of: searchText, options: comparisonOptions, range: nil, locale: nil) != nil
                {
                    return true
                }
                return false
            })
            
            let searchResultArray = self.addressBookContactsMutableArray?.filtered(using: predicate)
            self.addressBookContactsSearchResultsMutableArray = NSMutableArray(array: searchResultArray!, copyItems: false)
            self.contactsSearchResultTVC?.tableView.reloadData()
        }
        
        

    }
    
    func filterUserCardSelectionContactsForSearchText(_ searchText:String)
    {
        let comparisonOptions:NSString.CompareOptions = [NSString.CompareOptions.caseInsensitive, NSString.CompareOptions.diacriticInsensitive]
        
            let predicate: NSPredicate = NSPredicate( block: { (person, bindings) -> Bool in
                let firstName = (person as AnyObject).givenName as String
                let lastName = (person as AnyObject).familyName as String
                
                let companyName:String = (person as AnyObject).organizationName
                if firstName.range(of: searchText, options: comparisonOptions, range: nil, locale: nil) != nil || lastName.range(of: searchText, options: comparisonOptions, range: nil, locale: nil) != nil || companyName.range(of: searchText, options: comparisonOptions, range: nil, locale: nil) != nil
                {
                    return true
                }
                return false
            })
            
            let searchResultArray = self.userCardSelectionAddressBookContactsMutableArray?.filtered(using: predicate)
            self.userCardSelectionAddressBookContactsSearchResultsMutableArray = NSMutableArray(array: searchResultArray!, copyItems: false)
            self.userCardSelectionContactsSearchResultTVC?.tableView.reloadData()
        
        
        
        
    }
    
    
    @objc func setIsEditing()
    {
    if self.editMode == true
        {
        self.editMode = false
        
            
        self.editButton?.setImage(self.getTintedImage(UIImage(named: "editing.png")!, withColor: UIColor(red: CGFloat(51.0/255.0), green: CGFloat(51.0/255.0), blue: CGFloat(51.0/255.0), alpha: CGFloat(1.0))) , for: UIControl.State())
        self.addMatchButton?.setImage(self.getTintedImage(UIImage(named: "add_match.png")!, withColor: UIColor(red: CGFloat(51.0/255.0), green: CGFloat(51.0/255.0), blue: CGFloat(51.0/255.0), alpha: CGFloat(1.0))) , for: UIControl.State())
        self.addTrophyButton?.setImage(self.getTintedImage(UIImage(named: "add_trophy.png")!, withColor: UIColor(red: CGFloat(51.0/255.0), green: CGFloat(51.0/255.0), blue: CGFloat(51.0/255.0), alpha: CGFloat(1.0))) , for: UIControl.State())
        self.configurationButton?.setImage(self.getTintedImage(UIImage(named: "gear.png")!, withColor: UIColor(red: CGFloat(51.0/255.0), green: CGFloat(51.0/255.0), blue: CGFloat(51.0/255.0), alpha: CGFloat(1.0))) , for: UIControl.State())
            self.scoresTableView?.backgroundColor = UIColor(red: CGFloat(51.0/255.0), green: CGFloat(51.0/255.0), blue: CGFloat(51.0/255.0), alpha: CGFloat(1.0))
            self.scoresTableView?.separatorColor = UIColor.white
            self.middleView.layer.borderColor = UIColor(red: CGFloat(231.0/255.0), green: CGFloat(237.0/255.0), blue: CGFloat(234.0/255.0), alpha: CGFloat(1.0)).cgColor
            self.middleView.layer.borderWidth = 0.5
            
            self.cleanSelectedTrohpies()
            self.scoresTableView?.reloadData()
        }
    else if self.editMode == false
        {
        self.editMode = true
        self.editButton?.setImage(self.getTintedImage(UIImage(named: "edit.png")!, withColor: UIColor(red: CGFloat(246.0/255.0), green: CGFloat(0.0/255.0), blue: CGFloat(105.0/255.0), alpha: CGFloat(1.0))) , for: UIControl.State())
        addMatchButton?.setImage(self.getTintedImage(UIImage(named: "remove_match.png")!, withColor: UIColor(red: CGFloat(246.0/255.0), green: CGFloat(0.0/255.0), blue: CGFloat(105.0/255.0), alpha: CGFloat(1.0))) , for: UIControl.State())
        self.addTrophyButton?.setImage(self.getTintedImage(UIImage(named: "remove_trophy.png")!, withColor: UIColor(red: CGFloat(246.0/255.0), green: CGFloat(0.0/255.0), blue: CGFloat(105.0/255.0), alpha: CGFloat(1.0))) , for: UIControl.State())
        self.configurationButton?.setImage(self.getTintedImage(UIImage(named: "gear.png")!, withColor: UIColor(red: CGFloat(246.0/255.0), green: CGFloat(0.0/255.0), blue: CGFloat(105.0/255.0), alpha: CGFloat(1.0))) , for: UIControl.State())
            self.scoresTableView?.backgroundColor = UIColor(red: CGFloat(231.0/255.0), green: CGFloat(237.0/255.0), blue: CGFloat(234.0/255.0), alpha: CGFloat(1.0))
            self.scoresTableView?.separatorColor = UIColor(red: CGFloat(51.0/255.0), green: CGFloat(51.0/255.0), blue: CGFloat(51.0/255.0), alpha: CGFloat(1.0))
            self.middleView.layer.borderColor = UIColor(red: CGFloat(51.0/255.0), green: CGFloat(51.0/255.0), blue: CGFloat(51.0/255.0), alpha: CGFloat(1.0)).cgColor
            self.middleView.layer.borderWidth = 0.5
            
            
        self.scoresTableView?.reloadData()
        }
    }
    
    func removeSelectedTrophies()
    {
        let trophiesCount = self.selectedTrophies.count
        let leftTrophiesToDelete:NSMutableArray = NSMutableArray()
        let rightTrophiesToDelete:NSMutableArray = NSMutableArray()
        
        let alert = UIAlertController(title: String(format: NSLocalizedString("Delete %d Trophy(ies)", comment: ""), trophiesCount), message: String(format: NSLocalizedString("Are you sure you want to delete %d trophy(es)", comment: ""), trophiesCount), preferredStyle: UIAlertController.Style.alert);
        
        let okButton = UIAlertAction(title: NSLocalizedString("OK",comment:""), style: UIAlertAction.Style.default) { (okSelected) -> Void in
            
            if self.matchesArray.count > 0
            {
                if self.leftTrophiesArray.count > 0
                {

                
                    
                    for aTrophyIndexPaht in self.selectedTrophies
                    {
                        if self.leftTrophiesArray.count > (aTrophyIndexPaht as! IndexPath).row
                        {
                        leftTrophiesToDelete.add(self.leftTrophiesArray.object(at: (aTrophyIndexPaht as! IndexPath).row))
                        }
                        if self.rightTrophiesArray.count > (aTrophyIndexPaht as! IndexPath).row
                        {
                        rightTrophiesToDelete.add(self.rightTrophiesArray.object(at: (aTrophyIndexPaht as! IndexPath).row))
                        }
                        
                    }
                    
                    for aTrophy in leftTrophiesToDelete
                    {
                    
                        self.dbManager?.deleteTrophy(aTrophy as? Trophy)
                    }
                    
                    for aTrophy in rightTrophiesToDelete
                    {
                        
                        self.dbManager?.deleteTrophy(aTrophy as? Trophy)
                    }
                    
                    
                    self.selectedTrophies.removeAllObjects()
                    self.readMoreIndexPath = nil
                    let visibleRows = self.scoresTableView?.indexPathsForVisibleRows
                    self.scoresTableView?.reloadRows(at: visibleRows!, with: UITableView.RowAnimation.none)

                    self.collectionView?.reloadItems(at: [IndexPath(row: self.currentSection(), section: 0)])
                }
                
            }
        }
        
        let cancelButton = UIAlertAction(title: NSLocalizedString("Cancel",comment:""), style: UIAlertAction.Style.cancel) { (okSelected) -> Void in
        }
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        self.present(alert, animated: true, completion: nil)
        
       
        
    }
    
    func cleanSelectedTrohpies()
    {
        //remover marca de seleccion
        if self.selectedTrophies.count > 0
        {
        self.selectedTrophies.removeAllObjects()
        }
    }
    
    func lockButtons()
    {
        self.removeMatchButton?.isEnabled = false
        self.editButton?.isEnabled = false
        self.addMatchButton?.isEnabled = false
        self.addTrophyButton?.isEnabled = false
        self.configurationButton?.isEnabled = false
        self.scoresTableView?.isUserInteractionEnabled = false
        
    }
    
    func unlockButtons()
    {
        self.removeMatchButton?.isEnabled = true
        self.editButton?.isEnabled = true
        self.addMatchButton?.isEnabled = true
        self.addTrophyButton?.isEnabled = true
        self.configurationButton?.isEnabled = true
        self.scoresTableView?.isUserInteractionEnabled = true
    }
    
    
    func isFirstRun() -> Bool
    {
    let defaults = UserDefaults.standard
    if defaults.object(forKey: "isFirstRun") as? Date != nil
    {
    return false
    }
    
    defaults.set(Date(), forKey: "isFirstRun")
        
    UserDefaults.standard.synchronize()
    return true
    }
    
    func loadUserCardSelectionContacts()
    {
        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        switch authorizationStatus
        {
            
        case CNAuthorizationStatus.restricted:
            let alert = UIAlertController(title: NSLocalizedString("Contacts Acccess",comment:""), message: NSLocalizedString("eSpleen requires access to your contacts, the app does not send any data, we do not spy on you.",comment:""), preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: NSLocalizedString("Yes Take me to Privacy Settings",comment:""), style: UIAlertAction.Style.default) { (okSelected) -> Void in
                
                let URL = Foundation.URL(string: UIApplication.openSettingsURLString)
                UIApplication.shared.open(URL!, options: [:], completionHandler: {
                    (success) in
                    print("->: \(success)")
                })
            }
            
            let cancelButton = UIAlertAction(title: NSLocalizedString("No I'll do it later",comment:""), style: UIAlertAction.Style.cancel) { (cancelSelected) -> Void in
                
            }
            
            alert.addAction(okButton)
            alert.addAction(cancelButton)
            self.present(alert, animated: true, completion: nil)
            
        case CNAuthorizationStatus.denied:
            let alert = UIAlertController(title: NSLocalizedString("Contacts Acccess",comment:""), message: NSLocalizedString("eSpleen requires access to your contacts, the app does not send any data, we do not spy on you.",comment:""), preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: NSLocalizedString("Yes Take me to Privacy Settings",comment:""), style: UIAlertAction.Style.default) { (okSelected) -> Void in
                
                let URL = Foundation.URL(string: UIApplication.openSettingsURLString)
                UIApplication.shared.open(URL!, options: [:], completionHandler: {
                    (success) in
                    print("->: \(success)")
                })
            }
            
            let cancelButton = UIAlertAction(title: NSLocalizedString("No I'll do it later",comment:""), style: UIAlertAction.Style.cancel) { (cancelSelected) -> Void in
                
            }
            
            alert.addAction(okButton)
            alert.addAction(cancelButton)
            self.present(alert, animated: true, completion: nil)
        case CNAuthorizationStatus.authorized:
            if self.createAddressBook()
            {
                
                let store = CNContactStore()
                let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                                   CNContactImageDataKey,CNContactFamilyNameKey,CNContactGivenNameKey,CNContactThumbnailImageDataKey,CNContactOrganizationNameKey] as [Any]
                
                let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch as! [CNKeyDescriptor])
                
                let contacts: NSMutableArray = []
                
                let queue = DispatchQueue(label: "EnumerateContacts")
                queue.async {
                    
                    do {
                        try store.enumerateContacts(with: fetchRequest, usingBlock: { (contact, stop) -> Void in
                            contacts.add(contact)
                        })
                    }
                    catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }
                
                self.userCardSelectionAddressBookContactsMutableArray = contacts
                
            }
        default:()
        }

    }
    
    
    @objc func loadUserAddressbookCardRquest()
    {
        
    
        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        switch authorizationStatus
        {
        case CNAuthorizationStatus.notDetermined:
            if self.createAddressBook()
            {
                let store = CNContactStore()
                store.requestAccess(for: .contacts, completionHandler:
                                        {(granted: Bool, error: Error?) -> Void in
                    if granted {
                                let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName),CNContactImageDataKey,CNContactFamilyNameKey,CNContactGivenNameKey,CNContactThumbnailImageDataKey,CNContactOrganizationNameKey] as [Any]
                                
                                let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch as! [CNKeyDescriptor])
                                
                                let contacts: NSMutableArray = []
                                
                                do {
                                    try store.enumerateContacts(with: fetchRequest, usingBlock: { (contact, stop) -> Void in
                                        contacts.add(contact)
                                    })
                                }
                                catch let error as NSError {
                                    print(error.localizedDescription)
                                }
                                
                                self.userCardSelectionAddressBookContactsMutableArray = contacts
                                
                                if self.userCardSelectionContactsSearchResultTVC == nil
                                {
                                    self.userCardSelectionContactsSearchResultTVC = IKSContactsTVC()
                                    self.userCardSelectionContactsSearchResultTVC?.tableView.dataSource = self
                                    self.userCardSelectionContactsSearchResultTVC?.tableView.delegate = self
                                    self.userCardSelectionContactsSearchResultTVC?.navigationItem.title = NSLocalizedString("Select Your Card",comment:"")
                                    self.userCardSelectionContactsSearchResultTVC?.navigationController?.navigationBar.barStyle = UIBarStyle.black
                                    self.userCardSelectionContactsSearchResultTVC?.navigationController?.navigationBar.tintColor = UIColor(red: CGFloat(246.0/255.0), green: CGFloat(0.0/255.0), blue: CGFloat(105.0/255.0), alpha: CGFloat(1.0))
                                    self.userCardSelectionContactsTVC?.navigationItem.title = NSLocalizedString("Select Your Card",comment:"")
                                    
                                    
                                }
                                
                                if self.userCardSelectionContactsSearchController == nil
                                {
                                    self.userCardSelectionContactsSearchController = UISearchController(searchResultsController: self.userCardSelectionContactsSearchResultTVC!)
                                    self.userCardSelectionContactsSearchController?.hidesNavigationBarDuringPresentation = true
                                    //self.userCardSelectionContactsSearchController?.dimsBackgroundDuringPresentation = true
                                    self.userCardSelectionContactsSearchController?.searchBar.delegate = self
                                    self.userCardSelectionContactsSearchController?.searchBar.sizeToFit()
                                }
                                if self.userCardSelectionContactsTVC == nil
                                {
                                    self.userCardSelectionContactsTVC = IKSContactsTVC()
                                    self.cancelPersonCardSelectionBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Cancel",comment:""), style: UIBarButtonItem.Style.plain, target: self, action: #selector(MyViewController.cancelUserAddressBookCardSelection))
                                    self.userCardSelectionContactsTVC?.navigationItem.leftBarButtonItem = self.cancelPersonCardSelectionBarButtonItem
                                    self.commitPersonCardSelectionBarButtonItem = UIBarButtonItem(title: NSLocalizedString("OK",comment:""), style: UIBarButtonItem.Style.plain, target: self, action: #selector(MyViewController.commitUserAddressBookCardSelection))
                                    self.userCardSelectionContactsTVC?.navigationItem.rightBarButtonItem = self.commitPersonCardSelectionBarButtonItem
                                    self.userCardSelectionContactsTVC?.tableView.tableHeaderView = self.userCardSelectionContactsSearchController?.searchBar
                                    self.userCardSelectionContactsTVC?.tableView.dataSource = self
                                    self.userCardSelectionContactsTVC?.tableView.delegate = self
                                    
                                    
                                }
                                
                                if self.userCardSelectionANewClientNavigationController == nil
                                {
                                    self.userCardSelectionANewClientNavigationController = UINavigationController()
                                }
                                
                                let defaults = UserDefaults.standard
                                var userCardID:String? = nil
                                userCardID = defaults.object(forKey: "userCardID") as? String
                                var searchResultArray:NSArray?
                                var userCardIndex:Int? = nil
                                if userCardID != nil
                                {
                                    let comparisonOptions:NSString.CompareOptions = [NSString.CompareOptions.caseInsensitive, NSString.CompareOptions.diacriticInsensitive]
                                    
                                    let predicate: NSPredicate = NSPredicate( block: { (person, bindings) -> Bool in
                                        let identifier:String! = (person as AnyObject).identifier
                                        if identifier.range(of: userCardID!, options: comparisonOptions, range: nil, locale: nil) != nil
                                        {
                                            return true
                                        }
                                        return false
                                    })
                                    
                                    searchResultArray = self.userCardSelectionAddressBookContactsMutableArray?.filtered(using: predicate) as NSArray?
                                    if searchResultArray != nil && searchResultArray?.count > 0
                                    {
                                        userCardIndex = self.userCardSelectionAddressBookContactsMutableArray?.index(of: (searchResultArray?.object(at: 0))!)
                                    }
                                }
                                if userCardIndex != nil
                                {
                                    
                                    let selectedContact:CNContact? = self.userCardSelectionAddressBookContactsMutableArray?.object(at: userCardIndex!) as? CNContact
                                    self.userCardSelectionAddressBookContactsMutableArray?.removeObject(at: userCardIndex!)
                                    self.userCardSelectionAddressBookContactsMutableArray?.insert(selectedContact!, at: 0)
                                    
                                }
                                self.userCardSelectionANewClientNavigationController?.setViewControllers([self.userCardSelectionContactsTVC!], animated: false)
                                self.userCardSelectionANewClientNavigationController!.navigationBar.barStyle = UIBarStyle.black
                                self.userCardSelectionANewClientNavigationController!.navigationBar.tintColor = UIColor(red: CGFloat(246.0/255.0), green: CGFloat(0.0/255.0), blue: CGFloat(105.0/255.0), alpha: CGFloat(1.0))
                                self.userCardSelectionANewClientNavigationController!.navigationBar.isTranslucent = false
                                self.userCardSelectionANewClientNavigationController?.extendedLayoutIncludesOpaqueBars = true
                                self.present(self.userCardSelectionANewClientNavigationController!, animated: true, completion: nil)
                        
                                }
                    
                
                                        })
            }
            
        case CNAuthorizationStatus.restricted:
            let alert = UIAlertController(title: NSLocalizedString("Contacts Acccess",comment:""), message: NSLocalizedString("eSpleen requires access to your contacts, the app does not send any data, we do not spy on you.",comment:""), preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: NSLocalizedString("Yes Take me to Privacy Settings",comment:""), style: UIAlertAction.Style.default) { (okSelected) -> Void in
                
                let URL = Foundation.URL(string: UIApplication.openSettingsURLString)
                UIApplication.shared.open(URL!, options: [:], completionHandler: {
                    (success) in
                    print("->: \(success)")
                })
            }
            
            let cancelButton = UIAlertAction(title: NSLocalizedString("No I'll do it later",comment:""), style: UIAlertAction.Style.cancel) { (cancelSelected) -> Void in
                
            }
            
            alert.addAction(okButton)
            alert.addAction(cancelButton)
            self.present(alert, animated: true, completion: nil)
            
        case .denied:
            let alert = UIAlertController(title: NSLocalizedString("Contacts Acccess",comment:""), message: NSLocalizedString("eSpleen requires access to your contacts, the app does not send any data, we do not spy on you.",comment:""), preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: NSLocalizedString("Yes Take me to Privacy Settings",comment:""), style: UIAlertAction.Style.default) { (okSelected) -> Void in
                
                let URL = Foundation.URL(string: UIApplication.openSettingsURLString)
                //UIApplication.shared.openURL(URL!)
                UIApplication.shared.open(URL!, options: [:], completionHandler: {
                    (success) in
                    print("->: \(success)")
                })
            }
            
            let cancelButton = UIAlertAction(title: NSLocalizedString("No I'll do it later",comment:""), style: UIAlertAction.Style.cancel) { (cancelSelected) -> Void in
                
            }
            
            alert.addAction(okButton)
            alert.addAction(cancelButton)
            self.present(alert, animated: true, completion: nil)
        case .authorized:
            if self.createAddressBook()
            {
            
                let store = CNContactStore()
                let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                    CNContactImageDataKey,CNContactFamilyNameKey,CNContactGivenNameKey,CNContactThumbnailImageDataKey,CNContactOrganizationNameKey] as [Any]
                
                let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch as! [CNKeyDescriptor])
                
                let contacts: NSMutableArray = []
                
                
                do {
                    try store.enumerateContacts(with: fetchRequest, usingBlock: { (contact, stop) -> Void in
                        contacts.add(contact)
                    })
                }
                catch let error as NSError {
                    print(error.localizedDescription)
                }
                
                self.userCardSelectionAddressBookContactsMutableArray = contacts
                
                if self.userCardSelectionContactsSearchResultTVC == nil
                {
                    self.userCardSelectionContactsSearchResultTVC = IKSContactsTVC()
                    self.userCardSelectionContactsSearchResultTVC?.tableView.dataSource = self
                    self.userCardSelectionContactsSearchResultTVC?.tableView.delegate = self
                    self.userCardSelectionContactsSearchResultTVC?.navigationItem.title = NSLocalizedString("Select 2 Persons",comment:"")
                    self.userCardSelectionContactsSearchResultTVC?.navigationController?.navigationBar.barStyle = UIBarStyle.black
                    self.userCardSelectionContactsSearchResultTVC?.navigationController?.navigationBar.tintColor = UIColor(red: CGFloat(246.0/255.0), green: CGFloat(0.0/255.0), blue: CGFloat(105.0/255.0), alpha: CGFloat(1.0))
                    
                    
                }
                if self.userCardSelectionContactsTVC == nil
                {
                    self.userCardSelectionContactsTVC = IKSContactsTVC()
                    self.cancelPersonCardSelectionBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Cancel",comment:""), style: UIBarButtonItem.Style.plain, target: self, action: #selector(MyViewController.cancelUserAddressBookCardSelection))
                    self.userCardSelectionContactsTVC?.navigationItem.leftBarButtonItem = self.cancelPersonCardSelectionBarButtonItem
                    
                    self.commitPersonCardSelectionBarButtonItem = UIBarButtonItem(title: "OK", style: UIBarButtonItem.Style.plain, target: self, action: #selector(MyViewController.commitUserAddressBookCardSelection))
                    self.userCardSelectionContactsTVC?.navigationItem.rightBarButtonItem = self.commitPersonCardSelectionBarButtonItem
                    
                    
                    
                    self.userCardSelectionContactsSearchController = UISearchController(searchResultsController: self.userCardSelectionContactsSearchResultTVC!)
                    self.userCardSelectionContactsSearchController?.hidesNavigationBarDuringPresentation = true
                   // self.userCardSelectionContactsSearchController?.dimsBackgroundDuringPresentation = true
                   
                    self.userCardSelectionContactsSearchController?.searchBar.delegate = self
                    self.userCardSelectionContactsSearchController?.searchBar.sizeToFit()
                    self.userCardSelectionContactsTVC?.tableView.tableHeaderView = self.userCardSelectionContactsSearchController?.searchBar
                    
                    self.userCardSelectionContactsTVC?.tableView.dataSource = self
                    self.userCardSelectionContactsTVC?.tableView.delegate = self
                    
                }
                
                let defaults = UserDefaults.standard
                var userCardID:String? = nil
                userCardID = defaults.object(forKey: "userCardID") as? String
                var searchResultArray:NSArray?
                var userCardIndex:Int? = nil
                if userCardID != nil
                {
                    let comparisonOptions:NSString.CompareOptions = [NSString.CompareOptions.caseInsensitive, NSString.CompareOptions.diacriticInsensitive]
                    
                    let predicate: NSPredicate = NSPredicate( block: { (person, bindings) -> Bool in
                        let identifier: String? = (person as AnyObject).identifier
                        if identifier?.range(of: userCardID!, options: comparisonOptions, range: nil, locale: nil) != nil
                        {
                            return true
                        }
                        return false
                    })
                    
                    searchResultArray = self.userCardSelectionAddressBookContactsMutableArray?.filtered(using: predicate) as NSArray?
                    if searchResultArray != nil && searchResultArray?.count > 0
                    {
                        userCardIndex = self.userCardSelectionAddressBookContactsMutableArray?.index(of: (searchResultArray?.object(at: 0))!)
                        
                        if self.userCardSelectionSelectedContactsReferences.count > 0
                        {
                            self.userCardSelectionSelectedContactsReferences.removeAllObjects()
                        }
                        self.userCardSelectionSelectedContactsReferences.insert((searchResultArray?.object(at: 0))!, at: 0)
                    }
                }
                if userCardIndex != nil
                {
                    
                    let selectedContact:CNContact? = self.userCardSelectionAddressBookContactsMutableArray?.object(at: userCardIndex!) as? CNContact
                    self.userCardSelectionAddressBookContactsMutableArray?.removeObject(at: userCardIndex!)
                    self.userCardSelectionAddressBookContactsMutableArray?.insert(selectedContact!, at: 0)
                    
                
                }
                
                let userCardSelectionANewClientNavigationController:UINavigationController = UINavigationController(rootViewController: self.userCardSelectionContactsTVC!)
                userCardSelectionANewClientNavigationController.navigationBar.barStyle = UIBarStyle.black
                userCardSelectionANewClientNavigationController.navigationBar.tintColor = UIColor(red: CGFloat(246.0/255.0), green: CGFloat(0.0/255.0), blue: CGFloat(105.0/255.0), alpha: CGFloat(1.0))
                self.present(userCardSelectionANewClientNavigationController, animated: true, completion: nil)
            }
            
        @unknown default:
            break
        }
    }
    @objc func cancelUserAddressBookCardSelection()
    {
        self.userCardSelectionContactsTVC?.dismiss(animated: true, completion: nil)
        self.userCardSelectionSelectedContactsReferences.removeAllObjects()
        self.userCardSelectionContactsTVC = nil
    
    }
    
    @objc func commitUserAddressBookCardSelection()
    {
        if self.userCardSelectionSelectedContactsReferences.count > 0
        {
            let defaults = UserDefaults.standard
            defaults.set((self.userCardSelectionSelectedContactsReferences.object(at: 0) as! CNContact).identifier, forKey: "userCardID")
            UserDefaults.standard.synchronize()
            
            
        }
        else
        {
            
            let defaults = UserDefaults.standard
            defaults.removeObject(forKey: "userCardID")
            UserDefaults.standard.synchronize()
        }
        self.loadDefaultContact()
        self.userCardSelectionContactsTVC?.dismiss(animated: true, completion: nil)
        self.userCardSelectionSelectedContactsReferences.removeAllObjects()
        self.userCardSelectionContactsTVC = nil
        
        if self.menuTableView != nil
        {
            self.menuTableView?.reloadData()
        }
        }
    
    @objc func loadFacebookLoginSuggestion()
    {
        
        
        /*let aViewController:UIViewController = UIViewController()
        aViewController.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        aViewController.view.addSubview(UIImageView(image: self.imageWithColor(UIColor.grayColor())))
        
        let loginButton:FBSDKLoginButton = FBSDKLoginButton()
        let laterButton:UIButton = UIButton(frame: CGRect(x: (aViewController.view.frame.width/2) - (((aViewController.view.frame.width/7)*6)/2), y: aViewController.view.frame.height-(aViewController.view.frame.height/6), width: (aViewController.view.frame.width/7)*6, height: aViewController.view.frame.height/13))
        laterButton.backgroundColor = UIColor.whiteColor()
        laterButton.setTitle("No quiero usar facebook", forState: UIControlState.Normal)
        laterButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        laterButton.addTarget(self, action: "dismissFacebookLoginSuggestion", forControlEvents: UIControlEvents.TouchUpInside)
        loginButton.delegate = self
        loginButton.readPermissions = ["public_profile", "email", "user_friends"];
        loginButton.frame = CGRect(x: (aViewController.view.frame.width/2) - (((aViewController.view.frame.width/7)*6)/2), y: aViewController.view.frame.height-(aViewController.view.frame.height/3), width: (aViewController.view.frame.width/7)*6, height: aViewController.view.frame.height/13)
        aViewController.view.addSubview(loginButton)
        aViewController.view.addSubview(laterButton)
        aViewController.view.bringSubviewToFront(loginButton)
        aViewController.view.bringSubviewToFront(laterButton)
        
        self.navigationController?.presentViewController(aViewController, animated: true, completion: nil)*/
    }
    
    
    func loadTutorial()
    {
        var index:Int = 0
         var image:UIImage? = nil
        if self.currentDeviceModel() == "iPhone6PS"
        {
            image = UIImage(named:"iPhone5\(self.getPreferedLanguage())\(index).png")
        }
        else
        {
            image = UIImage(named:"\(self.currentDeviceModel())\(self.getPreferedLanguage())\(index).png")
        }
        
        while image != nil
        {
            if self.currentDeviceModel() == "iPhone6PS"
            {
                image = UIImage(named:"iPhone5\(self.getPreferedLanguage())\(index).png")
            }
            else
            {
                image = UIImage(named:"\(self.currentDeviceModel())\(self.getPreferedLanguage())\(index).png")
            }
            
            if image != nil
            {
 
                let aViewController:UIViewController = UIViewController()
                aViewController.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                aViewController.view.addSubview(UIImageView(image: image))
            self.tutorialViewsMutableArray.add(aViewController)

            }
            index += 1
        }
        
        self.tutorialPageViewController = BCLTutorialPageViewController(transitionStyle: UIPageViewController.TransitionStyle.scroll, navigationOrientation: UIPageViewController.NavigationOrientation.horizontal, options: nil)
        if self.tutorialViewsMutableArray.count > 0
        {
    let arrayWithController:NSArray = [self.tutorialViewsMutableArray.object(at: 0)]
        
            self.tutorialPageViewController?.setViewControllers(arrayWithController as? [UIViewController], direction: UIPageViewController.NavigationDirection.forward, animated: true, completion: nil)
    
    self.tutorialPageViewController!.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
    self.tutorialPageViewController?.dataSource = self
    self.tutorialPageViewController?.delegate  = self
    self.tutorialPageViewController?.pageControl?.numberOfPages = self.tutorialViewsMutableArray.count - 1
    self.tutorialPageViewController?.pageControl?.currentPage = 0

    self.navigationController?.present(tutorialPageViewController!, animated: true, completion: nil)
        }
    }
    
    
    func getPreferedLanguage() -> String
    {
    let pre:NSArray = NSArray(array: Locale.preferredLanguages)
        if pre.count > 0
        {
    if (pre.object(at: 0) as! String).hasPrefix("en") {
    return "en"
    }
    else if (pre.object(at: 0) as! String).hasPrefix("es") {
    return  "es"
    }else if (pre.object(at: 0) as! String).hasPrefix("ja"){
    return "ja-JP"
    }
    else{
    return "en"
    }
        }
    return "en"
    }

    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let currentIndex:Int? = self.tutorialViewsMutableArray.index(of: viewController)
        self.tutorialPageViewController?.pageControl?.currentPage = currentIndex!
        if currentIndex == 0
        {
        return nil
        }
        return self.tutorialViewsMutableArray.object(at: currentIndex! - 1) as? UIViewController
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let currentIndex:Int = self.tutorialViewsMutableArray.index(of: viewController)
        let exitIndex:Int? = self.tutorialViewsMutableArray.count - 1
        self.tutorialPageViewController?.pageControl?.currentPage = currentIndex
        if currentIndex == exitIndex
        {
            
            Timer.scheduledTimer(timeInterval: 0.8, target: self, selector: #selector(MyViewController.dismissTutorialWith), userInfo: nil, repeats: false)
            Timer.scheduledTimer(timeInterval: 0.8, target: self, selector: #selector(MyViewController.loadFacebookLoginSuggestion), userInfo: nil, repeats: false)
            return nil

        }
        return self.tutorialViewsMutableArray.object(at: currentIndex + 1) as? UIViewController
    }
    
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int
    {

        return self.tutorialViewsMutableArray.count
    
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int
    {
    return self.tutorialViewsMutableArray.index(of: pageViewController)
    }
    
    func dismissFacebookLoginSuggestion()
    {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    func currentDeviceModel() -> String
    {
    if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone && UIScreen.main.bounds.size.height * UIScreen.main.scale == 960
        {
            return "iPhone4"
        }
        else if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone && UIScreen.main.bounds.size.height * UIScreen.main.scale == 1136
                {
                    return "iPhone5"
                }
            else if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone && UIScreen.main.bounds.size.height * UIScreen.main.scale == 1334
                    {
                        
                        return "iPhone6"
                    }
                    else if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone && UIScreen.main.bounds.size.height * UIScreen.main.scale == 1704
                        {
                            
                            return "iPhone6PS"
     
                        }
            else if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone && UIScreen.main.bounds.size.height * UIScreen.main.scale == 2208
    {
     
        return "iPhone6P"
        
        }
        
    return "iPhone4"
    }
    


    @objc func dismissTutorialWith()
    {
    self.navigationController?.dismiss(animated: true, completion: nil)
    self.tutorialViewsMutableArray.removeAllObjects()
    self.temporalFirstRun = false
    }
    
    func sendReport(_ sender : AnyObject) {
        
        if(MFMailComposeViewController.canSendMail()){
            
            myMail = MFMailComposeViewController()
            self.myMail.mailComposeDelegate = self
            myMail.setSubject("eSpleen")
            let toRecipients = ["soporte@bucle.co"]
            myMail.setToRecipients(toRecipients)
            
            let sentfrom = "\nEmail sent from my app"
            myMail.setMessageBody(sentfrom, isHTML: false)
            
            self.present(myMail, animated: true, completion: nil)
        }
        else{
            let alert = UIAlertController(title: NSLocalizedString("Alert",comment:""), message: NSLocalizedString("Your device cannot send emails",comment:""), preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK",comment:""), style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        self.dismiss(animated: true, completion: nil)

    }
    
    func imageWithColor(_ color:UIColor) -> UIImage
    {
     let rect:CGRect = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
     UIGraphicsBeginImageContext(rect.size)
     let context:CGContext = UIGraphicsGetCurrentContext()!
    
    context.setFillColor(color.cgColor)
    context.fill(rect)
    
    let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    
    return image
    }
    
    func drawDummyMatch()
    {

        var rightCornerScoreView: UIView?
        var leftCornerScoreView: UIView?
        var leftPlayerScoreLabel: UILabel?
        var rightPlayerScoreLabel:UILabel?
        
        var matchNumberLabel: UILabel?
        var matchNumberLabelView: UIView?
        
        let rightStartAngle = CGFloat(Double.pi/2)
        var rightEndAngle:CGFloat?
        var rightRingShapeLayer:CAShapeLayer?
        rightEndAngle = self.getAngleForScore(100)
        
        
        let leftStartAngle = CGFloat(Double.pi/2)
        var leftEndAngle:CGFloat?
        var leftRingShapeLayer:CAShapeLayer?
        leftEndAngle = self.getAngleForScore(100)
        
        let shapeLayerTopRight:CAShapeLayer = CAShapeLayer()
        let pathTopRight: CGMutablePath = CGMutablePath()
        
        let shapeLayerTopLeft:CAShapeLayer = CAShapeLayer()
        let pathTopLeft: CGMutablePath = CGMutablePath()
        
        
        
        
        leftCornerScoreView = UIView(frame: CGRect(x:self.collectionView!.frame.size.width * 0.34375,y:(self.collectionView!.frame.size.height/2) - (self.collectionView!.frame.size.height * 0.1006711409),width:self.collectionView!.frame.size.width * 0.15625,height:self.collectionView!.frame.size.height * 0.2013422819))
        leftCornerScoreView?.clipsToBounds = true
        leftCornerScoreView?.layer.cornerRadius = self.collectionView!.frame.size.height * 0.06711409396
        leftCornerScoreView?.backgroundColor = UIColor.clear
        leftPlayerScoreLabel = UILabel(frame: CGRect(x:0,y:self.collectionView!.frame.size.height * 0.01677852349,width:self.collectionView!.frame.size.width * 0.15625,height:self.collectionView!.frame.size.height * 0.2013422819))
        leftPlayerScoreLabel?.font = UIFont(name: "DINCondensed-bold", size:self.collectionView!.frame.size.height * 0.1677852349)
        
        leftPlayerScoreLabel?.textAlignment = NSTextAlignment.center
        leftPlayerScoreLabel?.textColor = UIColor(red: CGFloat(231.0/255.0), green: CGFloat(237.0/255.0), blue: CGFloat(234.0/255.0), alpha: CGFloat(1.0))
        leftPlayerScoreLabel?.text = "000"

        leftCornerScoreView?.addSubview(leftPlayerScoreLabel!)
        
        
        rightCornerScoreView = UIView(frame: CGRect(x:self.collectionView!.frame.size.width * 0.5,y:(self.collectionView!.frame.size.height/2)-(self.collectionView!.frame.size.height * 0.1006711409),width:self.collectionView!.frame.size.width * 0.15625,height:self.collectionView!.frame.size.height * 0.2013422819))
        rightCornerScoreView?.clipsToBounds = true
        rightCornerScoreView?.layer.cornerRadius = self.collectionView!.frame.size.height * 0.06711409396
        rightCornerScoreView?.backgroundColor = UIColor.clear
        rightPlayerScoreLabel = UILabel(frame: CGRect(x:0,y:self.collectionView!.frame.size.height * 0.01677852349,width:self.collectionView!.frame.size.width * 0.15625,height:self.collectionView!.frame.size.height * 0.2013422819))
        rightPlayerScoreLabel?.font = UIFont(name: "DINCondensed-bold", size:self.collectionView!.frame.size.height * 0.1677852349)
        rightPlayerScoreLabel?.textAlignment = NSTextAlignment.center
        rightPlayerScoreLabel?.numberOfLines = 0
        rightPlayerScoreLabel?.textColor = UIColor(red: CGFloat(231.0/255.0), green: CGFloat(237.0/255.0), blue: CGFloat(234.0/255.0), alpha: CGFloat(1.0))
        rightPlayerScoreLabel?.text = "000"
        rightCornerScoreView?.addSubview(rightPlayerScoreLabel!)
        
        if leftRingShapeLayer == nil
        {
            leftRingShapeLayer = CAShapeLayer()
        }
        
        leftRingShapeLayer?.path = UIBezierPath(arcCenter: CGPoint(x:((self.collectionView!.frame.size.width/4)) - 10 , y: (self.collectionView!.frame.size.height/2)), radius: self.collectionView!.frame.size.height * 0.1812080537, startAngle: leftStartAngle, endAngle: leftEndAngle!, clockwise: true).cgPath
        leftRingShapeLayer?.backgroundColor = UIColor.clear.cgColor
        leftRingShapeLayer?.fillColor = UIColor.clear.cgColor
        leftRingShapeLayer?.strokeColor = UIColor.lightGray.cgColor
        leftRingShapeLayer?.lineWidth = self.collectionView!.frame.size.height * 0.05369127517
    
        
        if rightRingShapeLayer == nil
        {
            rightRingShapeLayer = CAShapeLayer()
        }
        
        rightRingShapeLayer?.path = UIBezierPath(arcCenter: CGPoint(x:((self.collectionView!.frame.size.width/4)*3) + 10 , y: (self.collectionView!.frame.size.height/2)), radius: self.collectionView!.frame.size.height * 0.1812080537, startAngle: rightStartAngle, endAngle: rightEndAngle!, clockwise: true).cgPath
        rightRingShapeLayer?.backgroundColor = UIColor.clear.cgColor
        rightRingShapeLayer?.fillColor = UIColor.clear.cgColor
        rightRingShapeLayer?.strokeColor = UIColor.lightGray.cgColor
        rightRingShapeLayer?.lineWidth = self.collectionView!.frame.size.height * 0.05369127517
        
        
        
        
        pathTopRight.move(to:CGPoint(x:(self.collectionView!.frame.size.width/2) + (self.collectionView!.frame.size.width * 0.09375),y:self.collectionView!.frame.size.height * 0.1744966443))
        pathTopRight.addLine(to:CGPoint(x:(self.collectionView!.frame.size.width/2) + (self.collectionView!.frame.size.width * 0.0703125),y: (self.collectionView!.frame.size.height * 0.1744966443) - (self.collectionView!.frame.size.width * 0.015625)))
        pathTopRight.addLine(to:CGPoint(x:(self.collectionView!.frame.size.width/2) + (self.collectionView!.frame.size.width * 0.0703125),y: (self.collectionView!.frame.size.height * 0.1744966443) + (self.collectionView!.frame.size.width * 0.015625)))
        pathTopRight.addLine(to:CGPoint(x:(self.collectionView!.frame.size.width/2) + (self.collectionView!.frame.size.width * 0.09375),y: (self.collectionView!.frame.size.height * 0.1744966443)))
        
        
        shapeLayerTopRight.path = pathTopRight
        shapeLayerTopRight.fillColor =   UIColor.lightGray.cgColor
        shapeLayerTopRight.strokeColor = UIColor.lightGray.cgColor
        shapeLayerTopRight.bounds = CGRect(x: 300, y: (self.collectionView!.frame.size.height/2), width: 20.0, height: 20)
        shapeLayerTopRight.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        shapeLayerTopRight.position = CGPoint(x: 300, y: (self.collectionView!.frame.size.height/2))
        
        
        matchNumberLabelView = UIView(frame: CGRect(x:((self.collectionView!.frame.size.width/2) - ((self.collectionView!.frame.size.height * 0.1476510067)/2)),y:self.collectionView!.frame.size.height * 0.1006711409,width:self.collectionView!.frame.size.height * 0.1476510067,height:self.collectionView!.frame.size.height * 0.1476510067))
        matchNumberLabelView?.clipsToBounds = true
        matchNumberLabelView?.layer.cornerRadius = self.collectionView!.frame.size.height * 0.07382550336
        matchNumberLabelView?.backgroundColor = UIColor.lightGray
        matchNumberLabel = UILabel(frame: CGRect(x:0,y:self.collectionView!.frame.size.height * 0.01342281879,width:self.collectionView!.frame.size.height * 0.1476510067,height:self.collectionView!.frame.size.height * 0.1476510067))
        matchNumberLabel?.font = UIFont(name: "DINCondensed-bold", size: self.collectionView!.frame.size.height * 0.1006711409)
        matchNumberLabel?.textAlignment = NSTextAlignment.center
        matchNumberLabel?.textColor = UIColor.lightGray
        matchNumberLabelView?.addSubview(matchNumberLabel!)

        
        
        pathTopLeft.move(to: CGPoint(x:(self.collectionView!.frame.size.width/2) - (self.collectionView!.frame.size.width * 0.09375),y:(self.collectionView!.frame.size.height * 0.1744966443)))
        pathTopLeft.addLine(to:CGPoint(x:(self.collectionView!.frame.size.width/2) - (self.collectionView!.frame.size.width * 0.0703125),y: (self.collectionView!.frame.size.height * 0.1744966443) - (self.collectionView!.frame.size.width * 0.015625)))
        pathTopLeft.addLine(to:CGPoint(x:(self.collectionView!.frame.size.width/2) - (self.collectionView!.frame.size.width * 0.0703125),y: (self.collectionView!.frame.size.height * 0.1744966443) + (self.collectionView!.frame.size.width * 0.015625)))
        pathTopLeft.addLine(to:CGPoint(x:(self.collectionView!.frame.size.width/2) - (self.collectionView!.frame.size.width * 0.09375),y:(self.collectionView!.frame.size.height * 0.1744966443)))
        
        
        shapeLayerTopLeft.path = pathTopLeft
        shapeLayerTopLeft.fillColor =   UIColor.lightGray.cgColor
        shapeLayerTopLeft.strokeColor = UIColor.lightGray.cgColor
        shapeLayerTopLeft.bounds = CGRect(x: 20, y: (self.collectionView!.frame.size.height/2), width: 20.0, height: 20)
        shapeLayerTopLeft.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        shapeLayerTopLeft.position = CGPoint(x: 20, y: (self.collectionView!.frame.size.height/2))
        
        
        self.collectionView?.backgroundView = UIView()
        self.collectionView?.backgroundView!.layer.addSublayer(shapeLayerTopRight)
        self.collectionView?.backgroundView!.layer.addSublayer(shapeLayerTopLeft)
        self.collectionView?.backgroundView!.addSubview(leftCornerScoreView!)
        self.collectionView?.backgroundView!.addSubview(rightCornerScoreView!)
        self.collectionView?.backgroundView!.addSubview(matchNumberLabelView!)
        self.collectionView?.backgroundView!.layer.addSublayer(leftRingShapeLayer!)
        self.collectionView?.backgroundView!.layer.addSublayer(rightRingShapeLayer!)
    }
    
    func getAngleForScore(_ score:Int) -> CGFloat
    {
        
        let radians:CGFloat = CGFloat(Double.pi/180) * CGFloat(CGFloat(CGFloat(score*100)/10000)*360) + CGFloat(Double.pi/2)
        return CGFloat(radians)
    }
    
    
    /*func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if error == nil
        {
            
            //self.dbManager!.dumpDataFromFirebaseWithFacebookToken(FBSDKAccessToken.current())
      
        
        }
        //self.dismissFacebookLoginSuggestion()
    }*/
    
    /*func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    
    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }*/
    
    func contactsSwitchFlipped(_ control: UISegmentedControl)
         {
        if control.selectedSegmentIndex == 0 {
            
            self.facebookContacts = false
            let defaults = UserDefaults.standard
            defaults.set(false, forKey: "useFacebookContacts")
            UserDefaults.standard.synchronize()
            control.tintColor = UIColor(red: 91/255, green: 194/255, blue: 54/255, alpha: 1.0)
            self.menuTableView?.reloadRows(at: [IndexPath(row: 2, section: 0)], with: UITableView.RowAnimation.none)
            
            }
            else if control.selectedSegmentIndex == 1 {
                let defaults = UserDefaults.standard
                defaults.set(true, forKey: "useFacebookContacts")
                UserDefaults.standard.synchronize()
            
            
            self.facebookContacts = false
            control.tintColor = UIColor(red: 65/255, green: 93/255, blue: 174/255, alpha: 1.0)
            control.selectedSegmentIndex = 0
                control.sendActions(for: UIControl.Event.valueChanged)
            
            }
        
        
    }
    
    func isLoggedIn()-> Bool {
        
        /*let fbAccessToken = FBSDKAccessToken.current()
        if fbAccessToken != nil
        {
            return fbAccessToken!.tokenString  != nil
        }
        else
        {
            return false
        }*/
        return false
    }
    
    func getImageWithColor(_ color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

    
    func getStoredFacebookContacts() -> NSMutableArray?
    {
        let facebookContactsArray:NSArray? = self.dbManager?.getFacebookContacts()
        let contactsMutableArray:NSMutableArray? = NSMutableArray()
        if facebookContactsArray?.count > 0
        {
            for item in facebookContactsArray!
            {
                if let aContact:FacebookContact = item as? FacebookContact
                {
                    
                    let keys = Array(aContact.entity.attributesByName.keys)
                    let dict = aContact.dictionaryWithValues(forKeys: keys)
                    let aNSDictionary:NSDictionary = dict as NSDictionary
                    
                    contactsMutableArray!.add(aNSDictionary)
                }
            }
            return contactsMutableArray
        }
        return nil
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
    }
    
    func loadDefaultContact()
    {
        
        let defaults = UserDefaults.standard
        var userCardID:String? = nil
        userCardID = defaults.object(forKey: "userCardID") as? String
        var searchResultArray:NSArray?
        
        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        switch authorizationStatus
        {
        case CNAuthorizationStatus.notDetermined:()
        case CNAuthorizationStatus.authorized:
            if self.createAddressBook()
            {
            
                let store = CNContactStore()
                let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                    CNContactImageDataKey,CNContactFamilyNameKey,CNContactGivenNameKey,CNContactThumbnailImageDataKey,CNContactOrganizationNameKey] as [Any]
                
                let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch as! [CNKeyDescriptor])
                
                let contacts: NSMutableArray = []
                let queue = DispatchQueue(label: "EnumerateContacts")
                queue.async {
                    do {
                        try store.enumerateContacts(with: fetchRequest, usingBlock: { (contact, stop) -> Void in
                            contacts.add(contact)
                        })
                    }
                    catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }
                
                self.addressBookContactsMutableArray = contacts
                self.userCardSelectionAddressBookContactsMutableArray = contacts
            }
        case CNAuthorizationStatus.denied:()
        case CNAuthorizationStatus.restricted:()
        @unknown default:
            break
            
            
        }
        
        if userCardID != nil && self.userCardSelectionAddressBookContactsMutableArray != nil
        {
            let comparisonOptions:NSString.CompareOptions = [NSString.CompareOptions.caseInsensitive, NSString.CompareOptions.diacriticInsensitive]
            
            let predicate: NSPredicate = NSPredicate( block: { (person, bindings) -> Bool in
                let identifier: String! = (person as AnyObject).identifier
                if identifier.range(of: userCardID!, options: comparisonOptions, range: nil, locale: nil) != nil
                {
                    return true
                }
                return false
            })
            
            
            searchResultArray = self.userCardSelectionAddressBookContactsMutableArray?.filtered(using: predicate) as NSArray?
            if searchResultArray != nil && searchResultArray?.count > 0
            {
                self.userCard = searchResultArray?.object(at: 0) as? CNContact
                self.userCardSelectionSelectedContactsReferences.insert(self.userCard!, at: 0)
            }
        }
        
    }
    
    
    func createMainView()
    {
        
        
    }
}

