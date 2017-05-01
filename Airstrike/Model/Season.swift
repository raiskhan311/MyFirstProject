//
//  Season.swift
//  Airstrike
//
//  Created by Jeffrey K Lewis on 12/1/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

class Season: NSObject {
    
    let id: String
    
    let name: String
    
    let startDate: Date
    
    let endDate: Date
    
    let postSeasonStartDate: Date?
    
    let postSeasonEndDate: Date?
    
    let teams: [Team]?
    
    let regularSeasonGames: [Game]?
    
    let postSeasonGames: [Game]?
    
    init(id: String, name: String, startDate: Date, endDate: Date, postSeasonStartDate: Date?, postSeasonEndDate: Date?, teams: [Team]?, regularSeasonGames: [Game]?, postSeasonGames: [Game]?) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.postSeasonStartDate = postSeasonStartDate
        self.postSeasonEndDate = postSeasonEndDate
        self.teams = teams
        self.regularSeasonGames = regularSeasonGames
        self.postSeasonGames = postSeasonGames
    }
    
}
