//
//  LeagueSelectorViewModel.swift
//  Airstrike
//
//  Created by Jeffrey K Lewis on 2/16/17.
//  Copyright © 2017 Airstrike. All rights reserved.
//

import Foundation

class LeagueSelectorViewModel {
    
    var userLeagues: [League]?
    var currentLeague: League?
    var allLeaguesMinusUsers: [League]?
    
    init() {
        var allLeagues: [League]?
        currentLeague = ServiceConnector.sharedInstance.getDisplayLeague()
        if let allL = try? DAOLeague().getAllLeagues() {
            allLeagues = allL
        }
        if let u = try? DAOUser().getUser() {
            let cLeagues = u?.coordinatorLeagueIds?.flatMap({ try? DAOLeague().getLeague(leagueGuid: $0) }).flatMap { $0 }
            let pLeagues = u?.playerLeagueIds?.flatMap({ try? DAOLeague().getLeague(leagueGuid: $0) }).flatMap { $0 }
            if var c = cLeagues {
                if let p = pLeagues {
                    for l in p {
                        if !c.contains(where: { $0.id == l.id }) {
                            c.append(l)
                        }
                    }
                }
                userLeagues = c
            } else {
                userLeagues = pLeagues
            }
        }
        if var a = allLeagues, let u = userLeagues {
            for i in u {
                guard let index = a.index(where: { $0.id == i.id }) else { continue }
                _ = a.remove(at: index)
            }
            allLeaguesMinusUsers = a
        } else if let a = allLeagues {
            allLeaguesMinusUsers = a
        }
    }
    
}

// MARK: Getters

extension LeagueSelectorViewModel {
    
    func getSectionCount() -> Int {
        return 2
    }
    
    func getCellCount(for section: Int) -> Int {
        var count = 0
        if section == 0 {
            count = userLeagues?.count ?? 0
        } else if let a = allLeaguesMinusUsers, section == 1 {
            count = a.count
        }
        return count
    }
    
    func isCellSelected(_ indexPath: IndexPath) -> Bool {
        if getLeagueId(forCellAt: indexPath) == currentLeague?.id {
            return true
        }
        return false
    }
    
    func getTitle(forCellAt indexPath: IndexPath) -> String {
        var title = ""
        if indexPath.section == 0, let u = userLeagues, u.count > indexPath.item {
            title = u[indexPath.item].name
        } else if let a = allLeaguesMinusUsers, a.count > indexPath.item && indexPath.section == 1 {
            title = a[indexPath.item].name
        }
        return title
    }
    
    func getLeagueId(forCellAt indexPath: IndexPath) -> String? {
        var id: String?
        if indexPath.section == 0, let u = userLeagues, u.count > indexPath.item {
            id = u[indexPath.item].id
        } else if let a = allLeaguesMinusUsers, a.count > indexPath.item && indexPath.section == 1 {
            id = a[indexPath.item].id
        }
        return id
    }
    
    func getHeaderText(section: Int) -> String {
        var text = ""
        if section == 0 {
            text = "Your Leagues"
        } else if section == 1 {
            text = "Other Leagues"
        }
        return text
    }
    
}
