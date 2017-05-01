//
//  AddPlayerViewModel.swift
//  Airstrike
//
//  Created by Bret Smith on 1/23/17.
//  Copyright © 2017 Airstrike. All rights reserved.
//

import UIKit
protocol SearchFinished {
    func searchFinished()
}

class AddPlayerViewModel: NSObject {
    var persons: [Person]?
    var personsToDisplay: [Person]?
    var leagueId = "No League Id"
    var delegate: SearchFinished?
    
    func initialize() {
        guard let allPersons = try? DAOPerson().getAllPersons() else { return }
        let personsInLeagueWithNoTeam = allPersons?.filter {
            var isUnaffiliatedInLeague = false
            $0.players?.forEach { player in
                if player.leagueId == leagueId && player.teamId == .none {
                    isUnaffiliatedInLeague = true
                }
            }
            return isUnaffiliatedInLeague
        }

        self.persons = personsInLeagueWithNoTeam
        self.personsToDisplay = self.persons
    }
    
    func configureLeague(leagueId: String) {
        self.leagueId = leagueId
        initialize()
    }
    
    func searchTextDidChange(searchValue: String?) {
        if let value = searchValue {
            personsToDisplay = persons?.filter {
                $0.fullName().lowercased().contains(value.lowercased())
            }
            
            if value == "" {
                personsToDisplay = persons
            }
        }
        
        if let d = delegate {
            d.searchFinished()
        }
    }
    
    func sections() -> Int {
        return 1
    }
    
    func rows() -> Int {
        return personsToDisplay?.count ?? 0
    }
    
    func cellHeight() -> CGFloat {
        return 80
    }
    
    func reuseIdentifier() -> String {
        return "playerCell"
    }
    
    func person(at indexPath: IndexPath?) -> Person? {
        if let iPath = indexPath {
            return personsToDisplay?[iPath.item]
        }
        return .none
    }
    
    func data(for indexPath: IndexPath) -> [String:String] {
        var playerData = [String:String]()
        playerData["name"] = personsToDisplay?[indexPath.item].fullName()
        playerData["profileImagePath"] = personsToDisplay?[indexPath.item].profileImagePath
        return playerData
    }
}
