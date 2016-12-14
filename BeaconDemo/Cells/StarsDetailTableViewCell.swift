//
//  StarsDetailTableViewCell.swift
//  BeaconDemo
//
//  Created by Hugo Rodriguez on 12/11/16.
//  Copyright © 2016 Clinpays. All rights reserved.
//

import UIKit

class StarsDetailTableViewCell: UITableViewCell {
    @IBOutlet weak private var businessNameLabel: UILabel!
    @IBOutlet weak private var starsAmountLabel: UILabel!
    
    private var stars : BDStars?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(withStars stars : BDStars) {
        self.stars = stars
        self.businessNameLabel.text = "Comercio \(stars.businessId)"
        self.starsAmountLabel.text = String(stars.amount)
    }
    
}
