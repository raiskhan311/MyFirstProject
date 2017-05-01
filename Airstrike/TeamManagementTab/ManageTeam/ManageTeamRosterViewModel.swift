//
//  ManageTeamRosterViewModel.swift
//  Airstrike
//
//  Created by Bret Smith on 1/20/17.
//  Copyright © 2017 Airstrike. All rights reserved.
//

import UIKit

class ManageTeamRosterViewModel: NSObject {
    var team: Team?
    
    func configureTeam(team: Team?) {
        self.team = team
    }
}

// MARK: TableView Information

extension ManageTeamRosterViewModel {
    func sections() -> Int {
        return 1
    }
    
    func rows() -> Int {
        return team?.persons?.count ?? 0
    }
    
    func reuseIdentifier() -> String {
        return "playerCell"
    }
    
    func deleteItem(at indexPath: IndexPath) {
        if let player = team?.persons?[indexPath.item].players?.filter({$0.leagueId == ServiceConnector.sharedInstance.getDisplayLeague()?.id}).first {
            try? DAOPlayer().update(Player(id: player.id, leagueId: player.leagueId, teamId: .none, personId: player.personId, number: player.number, awards: player.awards))
            guard let newTeam = try? DAOTeam().getTeam(teamGuid: team?.id) else { return }
            team = newTeam
            ServiceConnector.sharedInstance.removePlayerFromTeam(playerId: player.id)
        }
    }
    
    func data(for indexPath: IndexPath) -> [String:String] {
        var playerData = [String:String]()
        playerData["name"] = team?.persons?[indexPath.item].fullName()
        playerData["profileImagePath"] = team?.persons?[indexPath.item].profileImagePath
        return playerData
    }
    
    func cellHeight() -> CGFloat {
        return 60
    }
}

