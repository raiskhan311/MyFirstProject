//
//  ProfileStatsTableViewModel.swift
//  Airstrike
//
//  Created by Jeffrey K Lewis on 12/7/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

class StatsTableViewModel: NSObject {
    
    fileprivate(set) var allSeasons: [Season]?
    fileprivate(set) var seasonsToShowStatsFor: [Season]?
    
    fileprivate(set) var positionToShowStatsFor = Position.quarterBack
    
    fileprivate(set) var teamsToShowStatsFor: [Team]?
    fileprivate(set) var allTeams: [Team]?
    
    fileprivate var player: Player?
    fileprivate var games: [Game]?
    
    fileprivate var allStatsToDisplay: [Stat]?
    
    fileprivate let dateFormatter = DateFormatter()
    
    fileprivate var notAPlayer = false
    
    override init() {
        super.init()
        dateFormatter.dateStyle = .short
    }
    
    func reinitializeStats() {
        initialize(player: player, teams: allTeams, games: games, notAPlayer: self.notAPlayer)
    }
    
}

// MARK: Initialization

extension StatsTableViewModel {
    
    func initialize(player: Player?, teams: [Team]?, games: [Game]?, notAPlayer: Bool = false) {
        self.notAPlayer = notAPlayer
        teamsToShowStatsFor = .none
        seasonsToShowStatsFor = .none
        self.player = player
        self.games = games
        self.allTeams = teams
        if let l = teams?.first {
            self.teamsToShowStatsFor = [l]
        } else if let g = games, let game = games?.first, let team1Opt = try? DAOTeam().getTeam(teamGuid: game.team1Id), let team1 = team1Opt, let team2Opt = try? DAOTeam().getTeam(teamGuid: game.team2Id), let team2 = team2Opt, g.count == 1 {
            self.teamsToShowStatsFor = [team1]
            self.allTeams = [team1, team2]
        }
        positionToShowStatsFor = .quarterBack
        self.allSeasons = self.findAllSeasons()
        seasonsToShowStatsFor = allSeasons
        allStatsToDisplay = getStatsFor(player: player, teams: teamsToShowStatsFor, games: games, seasons: seasonsToShowStatsFor, position: positionToShowStatsFor)
    }
    
    fileprivate func getStatsFor(player: Player?, teams: [Team]?, games: [Game]?, seasons: [Season]?, position: Position) -> [Stat]? {
        guard let allStatsOpt = try? DAOStat().getAllStats(), notAPlayer == false else { return .none }
        
        let filteredStats = allStatsOpt?.filter { stat in
            var shouldKeep = false
            if let s = seasons {
                shouldKeep = s.contains { $0.id == stat.seasonId }
            }
            if let g = games, shouldKeep {
                shouldKeep = g.contains { $0.id == stat.gameId }
            }
            if let t = teams, shouldKeep {
                shouldKeep = t.contains { $0.id == stat.teamId }
            }
            if let p = player, shouldKeep {
                shouldKeep = stat.playerId == p.id
            }
            return shouldKeep
        }.filter { $0.position == position }
        
        return filteredStats
    }
    
    private func findAllSeasons() -> [Season]? {
        guard let league = ServiceConnector.sharedInstance.getDisplayLeague(), let allSeasonsOpt = try? DAOSeason().getAllSeasons(leagueGuid: league.id), let allSeasons = allSeasonsOpt else { return .none }
        return allSeasons
    }

    
}

// MARK: Helper Functions

extension StatsTableViewModel {
    
    fileprivate func getStatTypeForCell(at indexPath: IndexPath) -> StatType? {
        let statTypes = StatTypeHelperFunctions.getStatTypesFor(position: positionToShowStatsFor)
        guard statTypes.count > indexPath.item else { return .none }
        
        return statTypes[indexPath.item]
    }
    
}

// MARK: Setters

extension StatsTableViewModel {
    
    func changeDataToDisplay(to seasons: [Season]?, position: Position, teams: [Team]?) {
        positionToShowStatsFor = position
        seasonsToShowStatsFor = seasons
        teamsToShowStatsFor = teams
        allStatsToDisplay = getStatsFor(player: player, teams: teamsToShowStatsFor, games: games, seasons: seasonsToShowStatsFor, position: positionToShowStatsFor)
    }
    
}


// MARK: Getters

extension StatsTableViewModel {
    
    func getHeaderDisplayText() -> String {
        var headerText: String = ""
        if let s = seasonsToShowStatsFor, s.count > 0 {
            let latestSeasonName = s.reduce(s[0], { $0.startDate.timeIntervalSince1970 > $1.startDate.timeIntervalSince1970 ? $0 : $1 }).name
            let earliestSeasonName = s.reduce(s[0], { $0.endDate.timeIntervalSince1970 < $1.endDate.timeIntervalSince1970 ? $0 : $1 }).name
            headerText = earliestSeasonName + " - " + latestSeasonName
            if earliestSeasonName == latestSeasonName {
                headerText = earliestSeasonName
            }
            if seasonsToShowStatsFor?.count == allSeasons?.count {
                headerText = "All Seasons"
            }
        }
        headerText += (" | " + positionToShowStatsFor.rawValue)
        if let t = teamsToShowStatsFor, let team = t.first, t.count == 1 {
            headerText += (" | " + team.name)
        } else if teamsToShowStatsFor?.count ?? 0 > 1 {
            headerText += " | Multiple Teams"
        }
        return headerText
    }
    
    func getCellCount() -> Int {
        return StatTypeHelperFunctions.getStatTypesFor(position: positionToShowStatsFor).count
    }
    
    func getDisplayNameForCell(at indexPath: IndexPath) -> String {
        return getStatTypeForCell(at: indexPath)?.rawValue ?? ""
    }
    
    func getValueForCell(at indexPath: IndexPath) -> String {
        guard let allStats = allStatsToDisplay, let statTypeForCell = getStatTypeForCell(at: indexPath) else { return "" }

        let value = allStats
            .filter { $0.type == statTypeForCell }
            .reduce(0, { $0 + $1.value })
        
        return value.cleanValue
    }
    
}
