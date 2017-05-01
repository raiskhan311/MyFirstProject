//
//  Person.swift
//  Airstrike
//
//  Created by Jeffrey K Lewis on 12/1/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

class Person: NSObject {

    let id: String
    
    let firstName: String
    
    let lastName: String
    
    let profileImagePath: String?
    
    let profileDescription: String?
    
    let players: [Player]?
    
    init(id: String, firstName: String, lastName: String, profileImagePath: String?, profileDescription: String?, players: [Player]?) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.profileImagePath = profileImagePath
        self.profileDescription = profileDescription
        self.players = players
    }
    
    func fullName() -> String {
        return firstName + " " + lastName
    }
}
