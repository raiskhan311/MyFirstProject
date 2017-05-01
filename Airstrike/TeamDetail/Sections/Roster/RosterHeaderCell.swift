//
//  RosterHeaderCell.swift
//  Airstrike
//
//  Created by Brian Nielson on 12/23/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

class RosterHeaderCell: UITableViewCell {

    @IBOutlet weak var currentRosterLabel: UILabel!
    @IBOutlet weak var filterIconButton: UIImageView!
    
    override func awakeFromNib() {
        filterIconButton.isHidden = true
    }
    
    func setLabel(header: String) {
        currentRosterLabel.text = header
    }

}
