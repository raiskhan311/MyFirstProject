//
//  ScoreHeaderCell.swift
//  Airstrike
//
//  Created by Bret Smith on 12/7/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

class ScoreHeaderCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    
    func setLabel(header: String) {
        title.text = header
    }

}
