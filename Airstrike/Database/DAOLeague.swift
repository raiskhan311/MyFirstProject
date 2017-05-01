//
//  DAOLeague.swift
//  Airstrike
//
//  Created by Jeffrey K Lewis on 12/14/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import Foundation
import SQLite

class DAOLeague: NSObject {
    fileprivate static let leagueTableName = "league"
    
    fileprivate let leagueTable = Table(leagueTableName)
    
    fileprivate let leagueId = Expression<Int64>("id")
    
    fileprivate let leagueGuid = Expression<String>("guid")
    
    fileprivate let leagueName = Expression<String>("name")
    
    func create() throws {
        guard let _ = try? DatabaseManager.sharedInstance.db.run( leagueTable.create(ifNotExists: true) { table in
            
            table.column(leagueId, primaryKey: true)
            table.column(leagueGuid, unique: true)
            table.column(leagueName)
            
        }) else { throw DatabaseError.failureToCreateTable }
    }
    
    func insert(league: League) throws {
        try league.pastSeasons?.forEach {pastSeason in
            guard let _ = try? DAOSeason().insert(leagueGuid: league.id, season: pastSeason) else { throw DatabaseError.failureToInsertIntoTable }
        }
        if let cSeason = league.currentSeason {
            guard let _ = try? DAOSeason().insert(leagueGuid: league.id, season: cSeason) else { throw DatabaseError.failureToInsertIntoTable }
        }
        try league.futureSeasons?.forEach {futureSeason in
            guard let _ = try? DAOSeason().insert(leagueGuid: league.id, season: futureSeason) else { throw DatabaseError.failureToInsertIntoTable }
        }
        
        try league.teams?.forEach {
            try DAOTeam().insert(team: $0)
        }
        
        try insertLeague(league)
    }
    
    fileprivate func insertLeague(_ league: League) throws {
        guard let _ = try? DatabaseManager.sharedInstance.db.run( leagueTable.insert(
            leagueGuid <- league.id,
            leagueName <- league.name
        )) else { throw DatabaseError.failureToInsertIntoTable }
    }
    
    func update(_ league: League) throws {
        let leagueToUpdate = leagueTable.filter(leagueGuid == league.id)
        
        guard let _ = try? DatabaseManager.sharedInstance.db.run( leagueToUpdate.update(
            leagueGuid <- league.id,
            leagueName <- league.name
        )) else { throw DatabaseError.failureToUpdateInTable }
    }
    
    func getLeague( leagueGuid: String?) throws -> League? {
        var league: League?
        guard let lg = leagueGuid else { return league }
        let query = leagueTable.filter(self.leagueGuid == lg)
        guard let dbLeagueOpt = try? DatabaseManager.sharedInstance.db.pluck(query), let dbLeague = dbLeagueOpt else { throw DatabaseError.failureToGetFromTable }
        if let guid = leagueGuid {
            guard let seasons = try? DAOSeason().getAllSeasons(leagueGuid: guid) else { throw DatabaseError.failureToGetFromTable }
            guard let teams = try? DAOTeam().getTeams(leagueGuid: guid) else { throw DatabaseError.failureToGetFromTable }
            let newLeague = League(
                id: guid,
                name: dbLeague.get(leagueName),
                pastSeasons: getSeasonsOfType(status: .past, seasons: seasons),
                currentSeason: getSeasonsOfType(status: .current, seasons: seasons)?.first,
                futureSeasons: getSeasonsOfType(status: .future, seasons: seasons),
                teams: teams)
            league = newLeague
        }
        return league
    }
    
    func getAllLeagues() throws -> [League]? {
        var leagues = [League]()
        let query = leagueTable
        guard let dbLeagues = try? DatabaseManager.sharedInstance.db.prepare(query) else { throw DatabaseError.failureToGetFromTable }
        for dbLeague in dbLeagues {
            guard let seasons = try? DAOSeason().getAllSeasons(leagueGuid: dbLeague.get(leagueGuid)) else { continue }
            guard let teams = try? DAOTeam().getTeams(leagueGuid: dbLeague.get(leagueGuid)) else { continue }
            let newLeague = League(
                id: dbLeague.get(leagueGuid),
                name: dbLeague.get(leagueName),
                pastSeasons: getSeasonsOfType(status: .past, seasons: seasons),
                currentSeason: getSeasonsOfType(status: .current, seasons: seasons)?.first,
                futureSeasons: getSeasonsOfType(status: .future, seasons: seasons),
                teams: teams)
            leagues.append(newLeague)
        }
        return leagues.count > 0 ? leagues : .none
    }
    
    func deleteDocument(_ guid: String) throws {
        let query = leagueTable.filter(leagueGuid == guid)
        guard let _ = try? DatabaseManager.sharedInstance.db.run(query.delete()) else { throw DatabaseError.failureToDeleteFromTable }
    }
    
    func drop() throws {
        guard let _ = try? DatabaseManager.sharedInstance.db.run(leagueTable.drop(ifExists: true)) else { throw DatabaseError.failureToDropTable }
    }
    
    private func getSeasonsOfType(status: SeasonStatus, seasons:[Season]?) -> [Season]? {
        var seasonsOfType: [Season]?
        if let s = seasons {
            switch status {
            case .past:
                seasonsOfType = s.filter {
                    if let postSeasonEnd = $0.postSeasonEndDate {
                        if postSeasonEnd < Date() {
                            return true
                        }
                    } else {
                        if $0.endDate < Date() {
                            return true
                        }
                    }
                    return false
                }
            case .current:
                seasonsOfType = s.filter {
                    if let postSeasonEnd = $0.postSeasonEndDate {
                        if $0.startDate < Date() && postSeasonEnd > Date() {
                            return true
                        }
                    } else {
                        if $0.startDate < Date() && $0.endDate > Date() {
                            return true
                        }
                    }
                    return false
                }
            case .future:
                seasonsOfType = s.filter { $0.startDate > Date() }
            }
        }
        return seasonsOfType
    }

}
