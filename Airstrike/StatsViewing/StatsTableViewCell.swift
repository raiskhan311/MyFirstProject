//
//  ProfileStatsTableViewCell.swift
//  Airstrike
//
//  Created by Jeffrey K Lewis on 12/7/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

class StatsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var statTypeLabel: UILabel!
    @IBOutlet weak var statValueLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)
        
    }
    
    func setText(statType: String, value: String) {
        statTypeLabel.text = statType
        statValueLabel.text = value
    }

}
