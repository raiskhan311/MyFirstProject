//
//  Team.swift
//  Airstrike
//
//  Created by Jeffrey K Lewis on 12/1/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

class Team: NSObject {

    let id: String
    
    let name: String
    
    let color: UIColor
    
    let pastGames: [Game]?
    
    let currentGame: Game?
    
    let futureGames: [Game]?
    
    let currentSeasonWins: Int
    
    let currentSeasonLosses: Int
    
    let leagueGuid: String
    
    let managerGuid: String
    
    let persons: [Person]?
    
    init(id: String, name: String, color: UIColor, pastGames: [Game]?, currentGame: Game?, futureGames: [Game]?, currentSeasonWins: Int, currentSeasonLosses: Int, leagueGuid: String, managerGuid: String, persons: [Person]?) {
        self.id = id
        self.name = name
        self.color = color
        self.pastGames = pastGames
        self.currentGame = currentGame
        self.futureGames = futureGames
        self.currentSeasonWins = currentSeasonWins
        self.currentSeasonLosses = currentSeasonLosses
        self.leagueGuid = leagueGuid
        self.managerGuid = managerGuid
        self.persons = persons
    }
    
}
