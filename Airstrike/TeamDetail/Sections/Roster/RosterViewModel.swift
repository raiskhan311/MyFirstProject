//
//  RosterViewModel.swift
//  Airstrike
//
//  Created by Brian Nielson on 12/23/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

class RosterViewModel {
    
    fileprivate var team: Team?
    fileprivate var selectedPerson: Person?
    
    func initialize(team: Team?) {
        self.team = team
    }
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        guard let numberOfPersons = team?.persons?.count else { return 0 }
        return numberOfPersons
    }
    
    func getTeamPersons() -> [Person]? {
        return team?.persons
    }
    
    func getPlayerName(indexPath: IndexPath) -> String? {
        let person = team?.persons?[indexPath.item]
        var fullName = "Unknown"
        if let fname = person?.firstName, let lname = person?.lastName, let number = person?.players?.filter({$0.teamId == team?.id}).first?.number {
            fullName = String(format: "#%d %@ %@", number, fname, lname)
        }
        return fullName
    }
    
    func getPlayerImageURL(indexPath: IndexPath) -> String? {
        let person = team?.persons?[indexPath.item]
        return person?.profileImagePath
    }
    
    func setPerson(for indexPath: IndexPath) {
        selectedPerson = team?.persons?[indexPath.item]
    }
    
    func getPerson() -> Person? {
        return selectedPerson
    }

}
