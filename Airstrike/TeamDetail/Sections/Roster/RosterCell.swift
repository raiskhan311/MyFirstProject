//
//  RosterCell.swift
//  Airstrike
//
//  Created by Brian Nielson on 12/23/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

class RosterCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var playerNumberAndNameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        roundTeamColorTagView()
    }

    fileprivate func roundTeamColorTagView() {
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
    }
    
}
