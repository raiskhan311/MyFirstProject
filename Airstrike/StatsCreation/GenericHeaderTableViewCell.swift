//
//  GenericHeaderTableViewCell.swift
//  Airstrike
//
//  Created by Bret Smith on 12/30/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

class GenericHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var message: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setLabel(header: String) {
        message.text = header
    }

}
