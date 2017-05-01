//
//  ChooseLeagueViewModel.swift
//  Airstrike
//
//  Created by Bret Smith on 1/20/17.
//  Copyright © 2017 Airstrike. All rights reserved.
//

import UIKit

class ChooseLeagueViewModel: NSObject {
    var leagues: [League]?
    var selectedLeagueId = "No League Id"
    
    func initialize() {
        guard let userOpt = try? DAOUser().getUser(), let user = userOpt else { return }
        let cLeagues = user.coordinatorLeagueIds?.flatMap({ try? DAOLeague().getLeague(leagueGuid: $0) }).flatMap { $0 }
        let pLeagues = user.playerLeagueIds?.flatMap({ try? DAOLeague().getLeague(leagueGuid: $0) }).flatMap { $0 }
        if var c = cLeagues {
            if let p = pLeagues {
                c.append(contentsOf: p)
            }
            leagues = c
        } else {
            leagues = pLeagues
        }
    }
}

// MARK: TableView Information

extension ChooseLeagueViewModel {
    func sections() -> Int {
        return 1
    }
    
    func rows() -> Int {
        return leagues?.count ?? 0
    }
    
    func reuseIdentifier() -> String {
        return "genericCell"
    }
    
    func data(for indexPath: IndexPath) -> String {
        return leagues?[indexPath.item].name ?? "No League Name"
    }
    
    func cellHeight() -> CGFloat {
        return 60
    }
    
    func rowSelected(at indexPath: IndexPath) {
        selectedLeagueId = leagues?[indexPath.item].id ?? "No League Id"
    }
    
    func headerReuseIdentifier() -> String {
        return "genericHeaderCell"
    }
    
    func headerText() -> String {
        return "Select the league you will be playing in."
    }
    
    func heightForHeader() -> CGFloat {
        return 60
    }
}

