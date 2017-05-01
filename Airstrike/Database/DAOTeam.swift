//
//  DAOTeam.swift
//  Airstrike
//
//  Created by Jeffrey K Lewis on 12/14/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit
import SQLite

class DAOTeam: NSObject {
    fileprivate static let teamTableName = "team"
    
    fileprivate let teamTable = Table(teamTableName)
    
    fileprivate let teamId = Expression<Int64>("id")
    
    fileprivate let teamGuid = Expression<String>("team_guid")
    
    fileprivate let managerGuid = Expression<String>("manager_guid")
    
    fileprivate let leagueGuid = Expression<String>("league_guid")
    
    fileprivate let name = Expression<String>("name")
    
    fileprivate let r = Expression<Double>("r_value")
    
    fileprivate let g = Expression<Double>("g_value")
    
    fileprivate let b = Expression<Double>("b_value")
    
    fileprivate let a = Expression<Double>("a_value")
    
    fileprivate let currentSeasonWins = Expression<Int>("current_season_wins")
    
    fileprivate let currentSeasonLosses = Expression<Int>("current_season_losses")
    
    func create() throws {
        guard let _ = try? DatabaseManager.sharedInstance.db.run( teamTable.create(ifNotExists: true) { table in
            
            table.column(teamId, primaryKey: true)
            table.column(teamGuid, unique: true)
            table.column(managerGuid)
            table.column(leagueGuid)
            table.column(name)
            table.column(r)
            table.column(g)
            table.column(b)
            table.column(a)
            table.column(currentSeasonWins)
            table.column(currentSeasonLosses)
            
        }) else { throw DatabaseError.failureToCreateTable }
    }
    
    func insert(team: Team) throws {
        if let persons = team.persons {
            try? DAOPerson().insert(persons: persons)
        }
        try? insertTeam(team: team)
    }
    
    fileprivate func insertTeam(team: Team) throws {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        team.color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        guard let _ = try? DatabaseManager.sharedInstance.db.run( teamTable.insert(
            teamGuid <- team.id,
            self.leagueGuid <- team.leagueGuid,
            name <- team.name,
            r <- Double(red),
            g <- Double(green),
            b <- Double(blue),
            a <- Double(alpha),
            currentSeasonWins <- team.currentSeasonWins,
            currentSeasonLosses <- team.currentSeasonLosses,
            managerGuid <- team.managerGuid
        )) else { throw DatabaseError.failureToInsertIntoTable }
    }
    
    func update(team: Team) throws {
        let teamToUpdate = teamTable.filter(teamGuid == team.id)
        team.persons?.forEach {
            try? DAOPerson().update($0)
        }
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        team.color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        guard let _ = try? DatabaseManager.sharedInstance.db.run( teamToUpdate.update(
            teamGuid <- team.id,
            self.leagueGuid <- team.leagueGuid,
            name <- team.name,
            r <- Double(red),
            g <- Double(green),
            b <- Double(blue),
            a <- Double(alpha),
            currentSeasonWins <- team.currentSeasonWins,
            currentSeasonLosses <- team.currentSeasonLosses,
            managerGuid <- team.managerGuid
        )) else { throw DatabaseError.failureToUpdateInTable }
    }
    
    func updateTeamRecords(team1Id: String, team2Id: String, winningTeamId: String) {
        if let team1Opt = try? getTeam(teamGuid: team1Id), let t1 = team1Opt {
            var currentWins = t1.currentSeasonWins
            var currentLosses = t1.currentSeasonLosses
            if winningTeamId == team1Id {
                currentWins += 1
            } else {
                currentLosses += 1
            }
            try? update(team: Team(id: t1.id, name: t1.name, color: t1.color, pastGames: t1.pastGames, currentGame: t1.currentGame, futureGames: t1.futureGames, currentSeasonWins: currentWins, currentSeasonLosses: currentLosses, leagueGuid: t1.leagueGuid, managerGuid: t1.managerGuid, persons: t1.persons))
        }
        if let team2Opt = try? getTeam(teamGuid: team2Id), let t2 = team2Opt {
            var currentWins = t2.currentSeasonWins
            var currentLosses = t2.currentSeasonLosses
            if winningTeamId == team1Id {
                currentWins += 1
            } else {
                currentLosses += 1
            }
            try? update(team: Team(id: t2.id, name: t2.name, color: t2.color, pastGames: t2.pastGames, currentGame: t2.currentGame, futureGames: t2.futureGames, currentSeasonWins: currentWins, currentSeasonLosses: currentLosses, leagueGuid: t2.leagueGuid, managerGuid: t2.managerGuid, persons: t2.persons))
        }
    }
    
    func getTeam(teamGuid: String?) throws -> Team? {
        var team: Team?
        if let tGuid = teamGuid {
            let query = teamTable.filter(self.teamGuid == tGuid)
            guard let dbTeam = try? DatabaseManager.sharedInstance.db.pluck(query) else { throw DatabaseError.failureToGetFromTable }
            guard let persons = try? DAOPerson().getAllPersons() else { throw DatabaseError.failureToGetFromTable }
            if let dbt = dbTeam {
                guard let games = try? DAOGame().getGames(teamGuid: dbt.get(self.teamGuid)) else { throw DatabaseError.failureToGetFromTable }
                let teamPersons = persons?.filter {
                    var hasPlayerOnTeam = false
                    $0.players?.forEach { player in
                        if player.teamId == dbt.get(self.teamGuid) {
                            hasPlayerOnTeam = true
                        }
                    }
                    return hasPlayerOnTeam
                }
                let newTeam = Team(
                    id: dbt.get(self.teamGuid),
                    name: dbt.get(name),
                    color: UIColor(red: CGFloat(dbt.get(r)), green: CGFloat(dbt.get(g)), blue: CGFloat(dbt.get(b)), alpha: CGFloat(dbt.get(a))),
                    pastGames: gamesForState(gameStatus: .final, games: games),
                    currentGame: gamesForState(gameStatus: .firstHalf, games: games)?.first,
                    futureGames: gamesForState(gameStatus: .notStarted, games: games),
                    currentSeasonWins: currentSeasonWins(games: gamesForState(gameStatus: .final, games: games), teamId: dbt.get(self.teamGuid)),
                    currentSeasonLosses: currentSeasonLosses(games: gamesForState(gameStatus: .final, games: games), teamId: dbt.get(self.teamGuid)),
                    leagueGuid: dbt.get(leagueGuid),
                    managerGuid: dbt.get(managerGuid),
                    persons: teamPersons)
                team = newTeam
            }
        }
        return team
    }
    
    func getTeams(managerGuid: String?) throws -> [Team]? {
        var teams = [Team]()
        if let mGuid = managerGuid {
            let query = teamTable.filter(self.managerGuid == mGuid)
            guard let dbTeams = try? DatabaseManager.sharedInstance.db.prepare(query) else { throw DatabaseError.failureToGetFromTable }
            guard let persons = try? DAOPerson().getAllPersons() else { throw DatabaseError.failureToGetFromTable }
            for dbTeam in dbTeams {
                guard let games = try? DAOGame().getGames(teamGuid: dbTeam.get(self.teamGuid)) else { throw DatabaseError.failureToGetFromTable }
                let teamPersons = persons?.filter {
                    var hasPlayerOnTeam = false
                    $0.players?.forEach { player in
                        if player.teamId == dbTeam.get(teamGuid) {
                            hasPlayerOnTeam = true
                        }
                    }
                    return hasPlayerOnTeam
                }
                let newTeam = Team(
                    id: dbTeam.get(self.teamGuid),
                    name: dbTeam.get(name),
                    color: UIColor(red: CGFloat(dbTeam.get(r)), green: CGFloat(dbTeam.get(g)), blue: CGFloat(dbTeam.get(b)), alpha: CGFloat(dbTeam.get(a))),
                    pastGames: gamesForState(gameStatus: .final, games: games),
                    currentGame: gamesForState(gameStatus: .firstHalf, games: games)?.first,
                    futureGames: gamesForState(gameStatus: .notStarted, games: games),
                    currentSeasonWins: currentSeasonWins(games: gamesForState(gameStatus: .final, games: games), teamId: dbTeam.get(teamGuid)),
                    currentSeasonLosses: currentSeasonLosses(games: gamesForState(gameStatus: .final, games: games), teamId: dbTeam.get(teamGuid)),
                    leagueGuid: dbTeam.get(leagueGuid),
                    managerGuid: dbTeam.get(self.managerGuid),
                    persons: teamPersons)
                teams.append(newTeam)
            }
        }
        return teams
    }
    
    func getTeams(leagueGuid: String?) throws -> [Team]? {
        var teams = [Team]()
        if let sGuid = leagueGuid {
            let query = teamTable.filter(self.leagueGuid == sGuid)
            guard let dbTeams = try? DatabaseManager.sharedInstance.db.prepare(query) else { throw DatabaseError.failureToGetFromTable }
            guard let persons = try? DAOPerson().getAllPersons() else { throw DatabaseError.failureToGetFromTable }
            for dbTeam in dbTeams {
                guard let games = try? DAOGame().getGames(teamGuid: dbTeam.get(self.teamGuid)) else { throw DatabaseError.failureToGetFromTable }
                let teamPersons = persons?.filter {
                    var hasPlayerOnTeam = false
                    $0.players?.forEach { player in
                        if player.teamId == dbTeam.get(teamGuid) {
                            hasPlayerOnTeam = true
                        }
                    }
                    return hasPlayerOnTeam
                }
                let newTeam = Team(
                    id: dbTeam.get(self.teamGuid),
                    name: dbTeam.get(name),
                    color: UIColor(red: CGFloat(dbTeam.get(r)), green: CGFloat(dbTeam.get(g)), blue: CGFloat(dbTeam.get(b)), alpha: CGFloat(dbTeam.get(a))),
                    pastGames: gamesForState(gameStatus: .final, games: games),
                    currentGame: gamesForState(gameStatus: .firstHalf, games: games)?.first,
                    futureGames: gamesForState(gameStatus: .notStarted, games: games),
                    currentSeasonWins: currentSeasonWins(games: gamesForState(gameStatus: .final, games: games), teamId: dbTeam.get(teamGuid)),
                    currentSeasonLosses: currentSeasonLosses(games: gamesForState(gameStatus: .final, games: games), teamId: dbTeam.get(teamGuid)),
                    leagueGuid: dbTeam.get(self.leagueGuid),
                    managerGuid: dbTeam.get(managerGuid),
                    persons: teamPersons)
                teams.append(newTeam)
            }
        }
        return teams
    }
    
    func getAllTeams() throws -> [Team]? {
        var teams = [Team]()
        let query = teamTable
        guard let dbTeams = try? DatabaseManager.sharedInstance.db.prepare(query) else { throw DatabaseError.failureToGetFromTable }
        guard let persons = try? DAOPerson().getAllPersons() else { throw DatabaseError.failureToGetFromTable }
        for dbTeam in dbTeams {
            guard let games = try? DAOGame().getGames(teamGuid: dbTeam.get(teamGuid)) else { throw DatabaseError.failureToGetFromTable }
            let teamPersons = persons?.filter {
                var hasPlayerOnTeam = false
                $0.players?.forEach { player in
                    if player.teamId == dbTeam.get(teamGuid) {
                        hasPlayerOnTeam = true
                    }
                }
                return hasPlayerOnTeam
            }
            let newTeam = Team(
                id: dbTeam.get(teamGuid),
                name: dbTeam.get(name),
                color: UIColor(red: CGFloat(dbTeam.get(r)), green: CGFloat(dbTeam.get(g)), blue: CGFloat(dbTeam.get(b)), alpha: CGFloat(dbTeam.get(a))),
                pastGames: gamesForState(gameStatus: .final, games: games),
                currentGame: gamesForState(gameStatus: .firstHalf, games: games)?.first,
                futureGames: gamesForState(gameStatus: .notStarted, games: games),
                currentSeasonWins: currentSeasonWins(games: gamesForState(gameStatus: .final, games: games), teamId: dbTeam.get(teamGuid)),
                currentSeasonLosses: currentSeasonLosses(games: gamesForState(gameStatus: .final, games: games), teamId: dbTeam.get(teamGuid)),
                leagueGuid: dbTeam.get(leagueGuid),
                managerGuid: dbTeam.get(managerGuid),
                persons: teamPersons)
            teams.append(newTeam)
        }
        return teams.count > 0 ? teams : .none
    }
    
    func deleteGame(_ guid: String) throws {
        let query = teamTable.filter(teamGuid == guid)
        guard let _ = try? DatabaseManager.sharedInstance.db.run(query.delete()) else { throw DatabaseError.failureToDeleteFromTable }
    }
    
    func drop() throws {
        guard let _ = try? DatabaseManager.sharedInstance.db.run(teamTable.drop(ifExists: true)) else { throw DatabaseError.failureToDropTable }
    }
    
    func gamesForState(gameStatus: GameStatus, games: [Game]?) -> [Game]? {
        var gamesForState: [Game]?
        if let gs = games {
            switch gameStatus {
            case .final:
                gamesForState = gs.filter { $0.gameStatus == .final }
            case .notStarted:
                gamesForState = gs.filter { $0.gameStatus == .notStarted }
            default:
                gamesForState = gs.filter { $0.gameStatus != .final && $0.gameStatus != .notStarted }
            }
        }
        return gamesForState
    }
    
    func currentSeasonWins(games: [Game]?, teamId: String) -> Int {
        var count = 0
        if let gameCount = games?.filter({ $0.winningTeamId == teamId }).count {
            count = gameCount
        }
        return count
    }
    
    func currentSeasonLosses(games: [Game]?, teamId: String) -> Int {
        var count = 0
        if let gameCount = games?.filter({ $0.winningTeamId != teamId }).count {
            count = gameCount
        }
        return count
    }
    
}
