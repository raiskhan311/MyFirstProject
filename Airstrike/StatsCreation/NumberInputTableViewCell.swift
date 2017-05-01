//
//  NumberInputTableViewCell.swift
//  Airstrike
//
//  Created by Bret Smith on 1/2/17.
//  Copyright © 2017 Airstrike. All rights reserved.
//

import UIKit

typealias StatValueAdded = (Double) -> ()

class NumberInputTableViewCell: UITableViewCell {
    @IBOutlet weak var textInput: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    var delegate: StatValueAdded?

    override func awakeFromNib() {
        super.awakeFromNib()
        submitButton.isHidden = true
    }

    @IBAction func textInputDidChange(_ sender: UITextField) {
        submitButton.isHidden = false
    }
    
    @IBAction func submitButtonPressed(_ sender: UIButton) {
        if let text = textInput.text, let numberVal = Double(text), let d = delegate {
            d(numberVal)
        }
    }
}
