//
//  GameProgressTableViewCell.swift
//  Airstrike
//
//  Created by Bret Smith on 12/7/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

class GameProgressTableViewCell: UITableViewCell {

    @IBOutlet weak var team1Label: UILabel!
    @IBOutlet weak var team2Label: UILabel!
    @IBOutlet weak var team1ScoreLabel: UILabel!
    @IBOutlet weak var team2ScoreLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    var gameStatus = GameStatus.final

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCell(gameInfo: [String:String]) {
        team1Label.text = gameInfo[GameInfo.teamOneName.rawValue]
        team2Label.text = gameInfo[GameInfo.teamTwoName.rawValue]
        team1ScoreLabel.text = gameInfo[GameInfo.teamOnePoints.rawValue]
        team2ScoreLabel.text = gameInfo[GameInfo.teamTwoPoints.rawValue]
        if let status = gameInfo[GameInfo.gameStatus.rawValue], let gameStatus = GameStatus(rawValue: status) {
            timeLabel.text = gameStatusString(gameStatus: gameStatus)
            self.gameStatus = gameStatus
        }
        
        styleLabels()
    }
    
    private func styleLabels() {
        if let team1PointsString = team1ScoreLabel.text,
            let team1Points = Int(team1PointsString),
            let team2PointsString = team2ScoreLabel.text,
            let team2Points = Int(team2PointsString) {
            if gameStatus == .final {
                if team1Points > team2Points {
                    emphasizeTeamOne()
                } else if team2Points > team1Points {
                    emphasizeTeamTwo()
                }
            } else {
                defaultState()
            }
        }
    }
    
    private func emphasizeTeamOne () {
        team2Label.textColor = Colors.mediumTextColor
        team2ScoreLabel.textColor = Colors.mediumTextColor
        
        team1Label.textColor = Colors.darkTextColor
        team1ScoreLabel.textColor = Colors.darkTextColor
    }
    
    private func emphasizeTeamTwo () {
        team1Label.textColor = Colors.mediumTextColor
        team1ScoreLabel.textColor = Colors.mediumTextColor
        
        team2Label.textColor = Colors.darkTextColor
        team2ScoreLabel.textColor = Colors.darkTextColor
    }
    
    private func defaultState() {
        team1Label.textColor = Colors.darkTextColor
        team1ScoreLabel.textColor = Colors.darkTextColor
        
        team2Label.textColor = Colors.darkTextColor
        team2ScoreLabel.textColor = Colors.darkTextColor
    }
    
    private func gameStatusString(gameStatus: GameStatus) -> String {
        var gameStatusString = "Not Started"
        switch gameStatus {
        case .final:
            gameStatusString = "Final"
        case .firstHalf:
            gameStatusString = "1st Half"
        case .halfTime:
            gameStatusString = "Half Time"
        case .secondHalf:
            gameStatusString = "2nd Half"
        default:
            gameStatusString = "Not Started"
        }
        return gameStatusString
    }


}
