//
//  Util.swift
//  BeaconDemo
//
//  Created by Hugo Rodriguez on 12/12/16.
//  Copyright © 2016 Clinpays. All rights reserved.
//

import Foundation
import UIKit
import Parse
import ParseFacebookUtilsV4
import FacebookCore

class Util {
    static let sharedInstance = Util()
    private init() {}
    
    // show alert message.
    class func showAlert(withMessage message: String, inViewController viewController: UIViewController) {
        let alertController = UIAlertController.init(title: NSBundle.mainBundle().infoDictionary!["CFBundleName"] as? String
, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction.init(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        alertController.addAction(okAction)
        viewController.presentViewController(alertController, animated: true, completion: nil)
    }
    
    class func notLoggedIn() -> Bool {
        let user = PFUser.currentUser()
        // here I assume that a user must be linked to Facebook
        return user == nil || !PFFacebookUtils.isLinkedWithUser(user!)
    }
    class func loggedIn() -> Bool {
        return !notLoggedIn()
    }
    
}
