//
//  League.swift
//  Airstrike
//
//  Created by Jeffrey K Lewis on 12/1/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

class League: NSObject {

    let id: String
    
    let name: String
    
    let pastSeasons: [Season]?
    
    let currentSeason: Season?
    
    let futureSeasons: [Season]?
    
    let teams: [Team]?
    
    init(id: String, name: String, pastSeasons: [Season]?, currentSeason: Season?, futureSeasons: [Season]?, teams: [Team]?) {
        self.id = id
        self.name = name
        self.pastSeasons = pastSeasons
        self.currentSeason = currentSeason
        self.futureSeasons = futureSeasons
        self.teams = teams
    }
    
}
