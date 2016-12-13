//
//  Constants.swift
//  BeaconDemo
//
//  Created by Hugo Rodriguez on 12/11/16.
//  Copyright © 2016 Clinpays. All rights reserved.
//

import Foundation
import UIKit

class Constants {
    struct Parse {
        static let applicationId = "AZWRjVO7wxFs7ZgKJ6KFaUgoSlu1X14JGPyWtXNd"
        static let clientKey = "bDe8ZpC8q5RAFycT76tehHUFDaKt2I89jXTRYcB7"
    }
    
    struct Colors {
        static let green = UIColor(red: 15/255, green: 142/255, blue: 75/255, alpha: 1)
        static let white = UIColor.whiteColor()
        static let lightGray = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        static let gray = UIColor.grayColor()
        static let blue = UIColor(red: 60/255, green: 145/255, blue: 230/255, alpha: 1)
        static let textDark = UIColor(red: 52/255, green: 46/255, blue: 55/255, alpha: 1)
    }
    
    struct CellIdentifiers {
        static let tableViewCell = "kTableViewCellIdentifier"
        static let starsDetailTableViewCell = "kStarsDetailTableViewCellIdentifier"
    }
    
    struct Messages {
        static let defaultError = "Ocurrió un error ineseperado. Intenta nuevamente."
        static let noStarsError = "Todavía no has ganado estrellas :( Acercate a un beacon para comenzar a ganar!"
    }
    
    struct Notifications {
        static let didEnterBeaconRegion = "kdidEnterBeaconRegion"
    }
}
