//
//  AppDelegate.swift
//  BeaconDemo
//
//  Created by Hugo Rodriguez on 12/10/16.
//  Copyright © 2016 Clinpays. All rights reserved.
//

import UIKit
import FacebookCore
import Parse
import ParseFacebookUtilsV4

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ESTBeaconManagerDelegate {

    var window: UIWindow?
    private let beaconManager = ESTBeaconManager()
    
    // MARK: Private methods
    
    private func setupAppAppearance() {
        UINavigationBar.appearance().barTintColor = Constants.Colors.green
        UINavigationBar.appearance().translucent = false
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : Constants.Colors.white]
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    }
    
    private func registerParseSubclasses() {
        BDBusiness.registerSubclass()
        BDStars.registerSubclass()
    }
    
    private func setupEstimote() {
        self.beaconManager.delegate = self
        self.beaconManager.requestAlwaysAuthorization()
    }
    
    // MARK: Public methods
    
    func showLoginViewController() {
        let loginViewController = LoginViewController()
        self.window?.rootViewController = loginViewController
    }
    
    func showHomeViewController() {
        let homeViewController = HomeViewController()
        self.window?.rootViewController = homeViewController
    }
    
    func startMonitoringRegion () {
        self.beaconManager.startMonitoringForRegion(CLBeaconRegion(proximityUUID: NSUUID(UUIDString:"8492E75F-4FD6-469D-B132-043FE94921D8")!, major: 3724, minor: 19987, identifier: "monitored region"))

    }
    
    // MARK: Estimote delegate methods
    
    func beaconManager(manager: AnyObject, didEnterRegion region: CLBeaconRegion) {
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notifications.didEnterBeaconRegion, object: nil)
    }
    
    func beaconManager(manager: AnyObject, didExitRegion region: CLBeaconRegion) {
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notifications.didExitBeaconRegion, object: nil)
    }
    
    func beaconManager(manager: AnyObject, didDetermineState state: CLRegionState, forRegion region: CLBeaconRegion) {
        NSLog("State \(state)")
        var notificationName : String
        switch state {
        case .Inside:
            notificationName = Constants.Notifications.insideBeaconRegion
            break
            
        case .Outside:
            notificationName = Constants.Notifications.outsideBeaconRegion
            break
            
        case .Unknown:
            notificationName = Constants.Notifications.unknownBeaconRegion
            break
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(notificationName, object: nil)
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        // Setup app appearance
        setupAppAppearance()
        
        // Register Parse classes
        self.registerParseSubclasses()
        
        // Parse init
        Parse.setApplicationId(Constants.Parse.applicationId, clientKey: Constants.Parse.clientKey)
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        
        // Estimote Beacon Manager
        self.setupEstimote()
        
        if Util.loggedIn() {
            self.showHomeViewController()
        } else {
            self.showLoginViewController()
        }
        
        return ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return ApplicationDelegate.shared.application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

