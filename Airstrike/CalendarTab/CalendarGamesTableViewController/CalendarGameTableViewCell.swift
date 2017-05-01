//
//  CalendarGameTableViewCell.swift
//  Airstrike
//
//  Created by Bret Smith on 12/23/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

class CalendarGameTableViewCell: UITableViewCell {

    @IBOutlet weak var team1Label: UILabel!
    @IBOutlet weak var team2Label: UILabel!
    @IBOutlet weak var timeLocationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setData(gameInfo: [String:String]) {
        team1Label.text = gameInfo[GameInfo.teamOneName.rawValue]
        team2Label.text = gameInfo[GameInfo.teamTwoName.rawValue]
        var timeLocation = ""
        if let time = gameInfo[GameInfo.time.rawValue] {
            timeLocation += time
        }
        if let location = gameInfo[GameInfo.location.rawValue] {
            if timeLocation != "" {
                timeLocation += " @ "
            }
            timeLocation += location
        }
        timeLocationLabel.text = timeLocation
    }

}
