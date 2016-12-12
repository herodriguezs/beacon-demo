//
//  BDBusiness.swift
//  BeaconDemo
//
//  Created by Hugo Rodriguez on 12/11/16.
//  Copyright © 2016 Clinpays. All rights reserved.
//

import UIKit
import Parse

class BDBusiness: PFObject, PFSubclassing {
    
    @NSManaged var name: String
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "Business"
    }
}
