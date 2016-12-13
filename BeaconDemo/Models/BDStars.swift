//
//  BDStars.swift
//  BeaconDemo
//
//  Created by Hugo Rodriguez on 12/12/16.
//  Copyright © 2016 Clinpays. All rights reserved.
//

import UIKit
import Parse

class BDStars: PFObject, PFSubclassing {

    @NSManaged var amount : Float
    @NSManaged var user : PFUser
    @NSManaged var business : BDBusiness
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "Stars"
    }
    
}
