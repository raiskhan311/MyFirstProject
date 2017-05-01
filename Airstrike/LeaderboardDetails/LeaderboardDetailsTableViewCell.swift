//
//  LeaderboardDetailsTableViewCell.swift
//  Airstrike
//
//  Created by Bret Smith on 12/28/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

class LeaderboardDetailsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var playerProfileImageView: UIImageView!
    @IBOutlet weak var playerNameLabel: UILabel!
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var statNumberLabel: UILabel!
    @IBOutlet weak var rankingLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setData(playerLeaderboardInfo: [String:String]) {
        var playerString: String = ""
        if let playerName = playerLeaderboardInfo[LeaderboardInfo.playerName.rawValue] {
            playerString += playerName
        }
        playerNameLabel.text = playerString
        rankingLabel.text = playerLeaderboardInfo[LeaderboardInfo.ranking.rawValue]
        teamNameLabel.text = playerLeaderboardInfo[LeaderboardInfo.teamName.rawValue]
        statNumberLabel.text = playerLeaderboardInfo[LeaderboardInfo.statValue.rawValue]
        configureProfileImage(imagePath: playerLeaderboardInfo[LeaderboardInfo.imagePath.rawValue])
    }
    
    private func configureProfileImage(imagePath: String?) {
        if let imagePathURL = imagePath {
            playerProfileImageView.cache_imageForURL(imagePathURL)
            playerProfileImageView.layer.cornerRadius = playerProfileImageView.frame.width / 2
            playerProfileImageView.clipsToBounds = true
        } else {
            playerProfileImageView.image = #imageLiteral(resourceName: "tempProfilePic")
            playerProfileImageView.layer.cornerRadius = playerProfileImageView.frame.width / 2
            playerProfileImageView.clipsToBounds = true
        }
    }
}
