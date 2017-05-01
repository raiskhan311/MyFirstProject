//
//  AwardsTableViewCell.swift
//  Airstrike
//
//  Created by Brian Nielson on 12/30/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

class AwardsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var awardImageView: NSLayoutConstraint!
    @IBOutlet weak var awardTitleLabel: UILabel!
    @IBOutlet weak var awardDateLabel: UILabel!
       
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setText(awardTitle: String, date: String) {
        awardTitleLabel.text = awardTitle
        awardDateLabel.text = date
    }
    
}
