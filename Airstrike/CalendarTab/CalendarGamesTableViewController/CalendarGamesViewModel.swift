//
//  CalendarGamesViewModel.swift
//  Airstrike
//
//  Created by Bret Smith on 12/23/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

class CalendarGamesViewModel: NSObject {
    var games: [Game]?
    var hasGamesScheduled = false
    var selectedGame: Game?
    
    func reuseIdentifier() -> String {
        var identifier = ""
        if hasGamesScheduled {
            identifier = "calendarGameCell"
        } else {
            identifier = "nothingScheduledCell"
        }
        return identifier
    }
    
    func sections() -> Int {
        return 1
    }
    
    func rows(for section: Int) -> Int {
        var count = 1
        if let games = games {
            if hasGamesScheduled {
                count = games.count
            }
        }
        return count
    }
    
    func gameInfo(for indexPath: IndexPath) -> [String:String] {
        var gameInfo = [String:String]()
        if let game = games?[indexPath.item] {
            if let teamOneName = try? DAOTeam().getTeam(teamGuid: game.team1Id)?.name, let teamTwoName = try? DAOTeam().getTeam(teamGuid: game.team2Id)?.name  {
                gameInfo[GameInfo.teamOneName.rawValue] = teamOneName
                gameInfo[GameInfo.teamTwoName.rawValue] = teamTwoName
            } else {
                gameInfo[GameInfo.teamOneName.rawValue] = "Team One"
                gameInfo[GameInfo.teamTwoName.rawValue] = "Team Two"
            }
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .short
            gameInfo[GameInfo.time.rawValue] = dateFormatter.string(from: game.dateTime)
            gameInfo[GameInfo.location.rawValue] = game.location
        }
        return gameInfo
    }
    
    func gameSelected(at indexPath: IndexPath) {
        selectedGame = games?[indexPath.item]
    }
    
}
