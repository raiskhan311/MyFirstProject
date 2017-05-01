//
//  GenericTableViewCell.swift
//  Airstrike
//
//  Created by Brian Nielson on 12/19/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

class GenericTableViewCell: UITableViewCell {
    
    @IBOutlet weak var disclosureImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setData(_ title: String) {
        titleLabel.text = title
        configureColors()
    }
    
    private func configureColors() {
        titleLabel.textColor = Colors.darkTextColor
    }
    
}
