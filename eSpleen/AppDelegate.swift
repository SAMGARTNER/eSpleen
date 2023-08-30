//
//  AppDelegate.swift
//  iKeepScore
//
//  Created by Samir Augusto Arias Gartner on 19/11/14.
//  Copyright (c) 2014 Samir Gartner. All rights reserved.
//

import UIKit
import CoreData
//import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var mainViewController: MyViewController!
    var launchViewController: MyViewController!
    var mainNavigationController: UINavigationController!
    var mainView: UIView!
    var launchView: UIView!
    var dbManager:IKSDBManager = IKSDBManager()
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
       // FirebaseApp.configure()
        //dbManager.eSpleenRef = Database.database().reference()
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.mainView = UIView(frame: UIScreen.main.bounds)
        self.launchView = UIView(frame: UIScreen.main.bounds)
        
        self.mainViewController = MyViewController()
        self.launchViewController  = MyViewController()
        self.launchViewController.view = launchView
        
        self.mainNavigationController = UINavigationController(rootViewController: self.mainViewController!)
        self.window!.rootViewController = self.mainNavigationController
        self.window!.makeKeyAndVisible()
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.lightGray
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(red: CGFloat(246.0/255.0), green: CGFloat(0.0/255.0), blue: CGFloat(105.0/255.0), alpha: CGFloat(1.0))
        UIPageControl.appearance().backgroundColor = UIColor.clear
       // return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        return true

    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //FBSDKAppEvents.activateApp()
        /*if isLoggedIn()
        {
            
            let userDetailsRequest:FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "email, id, first_name, last_name, picture.type(large)"])
            userDetailsRequest.start(completionHandler: {
                (connection, userDetailsRequestResult, error) -> Void in
                
                if error == nil {
                    print(userDetailsRequestResult!)
                }
                else
                {
                    print("\(String(describing: error)) error solicitando usuario de facebook")
                }})
            //self.dbManager.syncDataInFirebaseWithFacebookToken(FBSDKAccessToken.current())
        }
        else
        {
        
        }*/
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.dbManager.saveContext()
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        //return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        //return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        return true
    }
    
    func isLoggedIn()-> Bool {
        
        //let fbAccessToken = FBSDKAccessToken.current()
        /*if fbAccessToken != nil
        {
        return fbAccessToken!.tokenString  != nil
        }
        else
        {
        return false
        }*/
        return false
    }
}



