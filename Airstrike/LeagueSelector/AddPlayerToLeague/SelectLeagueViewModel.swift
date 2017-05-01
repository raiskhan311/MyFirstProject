//
//  SelectLeagueViewModel.swift
//  Airstrike
//
//  Created by Bret Smith on 2/17/17.
//  Copyright © 2017 Airstrike. All rights reserved.
//

import UIKit

class SelectLeagueViewModel: NSObject {
    var leagues: [League]?
    var selectedLeagueId: String?
    
    func initialize() {
        guard let leagues = try? DAOLeague().getAllLeagues(), let user = try? DAOUser().getUser() else { return }
        if let person = user?.person, let players = person.players {
            self.leagues = leagues?.filter { league in
                var isAlreadyAPlayer = false
                players.forEach { player in
                    if league.id == player.leagueId {
                        isAlreadyAPlayer = true
                    }
                }
                return !isAlreadyAPlayer
            }
            
        }
    }
    
    func sections() -> Int {
        return 1
    }
    
    func rows() -> Int {
        return leagues?.count ?? 0
    }
    
    func reuseIdentifier() -> String {
        return "genericCell"
    }

    func cellHeight() -> CGFloat {
        return 60
    }
    
    func headerReuseIdentifier() -> String {
        return "genericHeaderCell"
    }
    
    func headerText() -> String {
        return "Select the league you would like to join as a player."
    }
    
    func nameOfLeague(at indexPath: IndexPath) -> String {
        return leagues?[indexPath.item].name ?? ""
    }
    
    func rowSelected(at indexPath: IndexPath) {
        selectedLeagueId = leagues?[indexPath.item].id
    }
    
}
