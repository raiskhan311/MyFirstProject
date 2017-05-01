//
//  Player.swift
//  Airstrike
//
//  Created by Jeffrey K Lewis on 12/1/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

class Player: NSObject {
    
    let id: String
    
    let leagueId: String
    
    let teamId: String?
    
    let personId: String
    
    let number: Int
    
    let awards: [Award]?
    
    init(id: String, leagueId: String, teamId: String?, personId: String, number: Int, awards: [Award]?) {
        self.id = id
        self.leagueId = leagueId
        self.teamId = teamId
        self.personId = personId
        self.number = number
        self.awards = awards
    }

}
