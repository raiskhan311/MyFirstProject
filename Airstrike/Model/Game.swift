//
//  Game.swift
//  Airstrike
//
//  Created by Jeffrey K Lewis on 12/1/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

class Game: NSObject {

    let id: String
    
    let team1Id: String
    
    let team2Id: String
    
    let dateTime: Date
    
    let date: Date
    
    let location: String
    
    let pointsTeam1: Int
    
    let pointsTeam2: Int
    
    let gameStatus: GameStatus
    
    let winningTeamId: String?
    
    init(id: String, team1Id: String, team2Id: String, dateTime: Date, date: Date, location: String, pointsTeam1: Int, pointsTeam2: Int, gameStatus: GameStatus, winningTeamId: String?) {
        self.id = id
        self.team1Id = team1Id
        self.team2Id = team2Id
        self.dateTime = dateTime
        self.date = date
        self.location = location
        self.pointsTeam1 = pointsTeam1
        self.pointsTeam2 = pointsTeam2
        self.gameStatus = gameStatus
        self.winningTeamId = winningTeamId
    }

}
