//
//  AddPlayerTableViewCell.swift
//  Airstrike
//
//  Created by Bret Smith on 1/23/17.
//  Copyright © 2017 Airstrike. All rights reserved.
//

import UIKit

class AddPlayerTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(playerData: [String:String]) {
        profileImageView.cache_imageForURL(playerData["profileImagePath"])
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true

        nameLabel.text = playerData["name"]
    }

}
