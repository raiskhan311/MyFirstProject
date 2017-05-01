//
//  ManagerTeamsViewModel.swift
//  Airstrike
//
//  Created by Bret Smith on 1/19/17.
//  Copyright © 2017 Airstrike. All rights reserved.
//

import UIKit

class ManagerTeamsViewModel: NSObject {
    var teams: [Team]?
    var selectedTeam: Team?
    
    func initialize() {
        guard let managerTeams = try? DAOTeam().getTeams(managerGuid: try DAOUser().getUser()?.id), let league = ServiceConnector.sharedInstance.getDisplayLeague(), let mTeams = managerTeams?.filter({ $0.leagueGuid == league.id }) else { return }
        teams = mTeams
    }
}

// MARK: TableView Information

extension ManagerTeamsViewModel {
    
    func sections() -> Int {
        return 1
    }
    
    func rows() -> Int {
        return teams?.count ?? 0
    }
    
    func reuseIdentifier() -> String {
        return "genericCell"
    }
    
    func teamName(for indexPath: IndexPath) -> String {
        return teams?[indexPath.item].name ?? ""
    }
    
    func cellHeight() -> CGFloat {
        return 60
    }
    
    func rowSelected(at indexPath: IndexPath) {
        self.selectedTeam = teams?[indexPath.item]
    }
    
}
