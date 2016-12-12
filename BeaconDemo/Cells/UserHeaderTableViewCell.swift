//
//  UserHeaderTableViewCell.swift
//  BeaconDemo
//
//  Created by Hugo Rodriguez on 12/11/16.
//  Copyright © 2016 Clinpays. All rights reserved.
//

import UIKit

class UserHeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var profilePictureImageView: UIImageView!
    @IBOutlet weak private var userNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profilePictureImageView.layer.cornerRadius = profilePictureImageView.bounds.size.width / 2
    }
    
}
