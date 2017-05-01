//
//  User.swift
//  Airstrike
//
//  Created by Jeffrey K Lewis on 12/1/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

class User: NSObject {

    let id: String
    
    let role: Role
    
    let person: Person?
    
    let coordinatorLeagueIds: [String]?
    
    let playerLeagueIds: [String]?
    
    init(id: String, role: Role, person: Person?, coordinatorLeagueIds: [String]?, playerLeagueIds: [String]?) {
        self.id = id
        self.role = role
        self.person = person
        self.coordinatorLeagueIds = coordinatorLeagueIds
        self.playerLeagueIds = playerLeagueIds
    }
}
