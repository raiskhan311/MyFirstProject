//
//  TeamsTableViewCell.swift
//  Airstrike
//
//  Created by Brian Nielson on 12/19/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

class TeamsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var teamColorTagView: UIView!
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var winLossLabel: UILabel!
    @IBOutlet weak var disclosureImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupColors()
        roundTeamColorTagView()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        let color = teamColorTagView.backgroundColor
        super.setSelected(selected, animated: animated)
        
        if(selected) {
            teamColorTagView.backgroundColor = color
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let color = teamColorTagView.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        
        if(highlighted) {
            teamColorTagView.backgroundColor = color
        }
    }
    
    fileprivate func roundTeamColorTagView() {
        teamColorTagView.layer.cornerRadius = teamColorTagView.frame.width / 2
        teamColorTagView.clipsToBounds = true
    }
    
    func setupColors() {
        teamNameLabel.textColor = Colors.darkTextColor
        teamColorTagView.backgroundColor = Colors.errorColor
    }
    
}
