//
//  DAOSeason.swift
//  Airstrike
//
//  Created by Jeffrey K Lewis on 12/14/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import Foundation
import SQLite

class DAOSeason: NSObject {
    
    fileprivate static let seasonTableName = "season"
    
    fileprivate let seasonTable = Table(seasonTableName)
    
    fileprivate let seasonId = Expression<Int64>("id")
    
    fileprivate let seasonGuid = Expression<String>("guid")
    
    fileprivate let seasonName = Expression<String>("name")
    
    fileprivate let leagueGuid = Expression<String>("league_guid")
    
    fileprivate let startDate = Expression<Date>("start_date")
    
    fileprivate let endDate = Expression<Date>("end_date")
    
    fileprivate let postSeasonStartDate = Expression<Date?>("post_season_start_date")
    
    fileprivate let postSeasonEndDate = Expression<Date?>("post_season_end_date")
    
    // Mapping Table Values
    
    fileprivate static let seasonTeamTableName = "season_team_mapping"
    
    fileprivate let seasonTeamMappingTable = Table(seasonTeamTableName)
    
    fileprivate let teamGuid = Expression<String>("team_guid")

    fileprivate let seasonMappingGuid = Expression<String>("season_guid")

    
    
    func create() throws {
        guard let _ = try? DatabaseManager.sharedInstance.db.run( seasonTable.create(ifNotExists: true) { table in
            
            table.column(seasonId, primaryKey: true)
            table.column(seasonGuid, unique: true)
            table.column(seasonName)
            table.column(leagueGuid)
            table.column(startDate)
            table.column(endDate)
            table.column(postSeasonStartDate)
            table.column(postSeasonEndDate)

            try? createMappingTable()
        }) else { throw DatabaseError.failureToCreateTable }
    }
    
    private func createMappingTable() throws {
        guard let _ = try? DatabaseManager.sharedInstance.db.run( seasonTeamMappingTable.create(ifNotExists: true) { table in
            
            table.column(teamGuid)
            table.column(seasonMappingGuid)
    
    }) else { throw DatabaseError.failureToCreateTable }
    }
    
    func insert(leagueGuid: String, season: Season) throws {
        try? season.teams?.forEach {
            try insertMapping(teamGuid: $0.id, seasonGuid: season.id)
        }
        try? season.regularSeasonGames?.forEach {
            try DAOGame().insertGame(leagueGuid: leagueGuid, seasonGuid: season.id, game: $0)
        }
        try? season.postSeasonGames?.forEach {
            try DAOGame().insertGame(leagueGuid: leagueGuid, seasonGuid: season.id, game: $0)
        }
    
        try insertSeason(leagueGuid: leagueGuid, season: season)
    }
    
    fileprivate func insertSeason(leagueGuid: String, season: Season) throws {
        guard let _ = try? DatabaseManager.sharedInstance.db.run( seasonTable.insert(
            seasonGuid <- season.id,
            self.leagueGuid <- leagueGuid,
            seasonName <- season.name,
            startDate <- season.startDate,
            endDate <- season.endDate,
            postSeasonStartDate <- season.postSeasonStartDate,
            postSeasonEndDate <- season.postSeasonEndDate
        )) else { throw DatabaseError.failureToInsertIntoTable }
    }
    
    private func insertMapping(teamGuid: String, seasonGuid: String) throws {
        guard let _ = try? DatabaseManager.sharedInstance.db.run(seasonTeamMappingTable.insert(
            self.seasonMappingGuid <- seasonGuid,
            self.teamGuid <- teamGuid
        )) else { throw DatabaseError.failureToInsertIntoTable }
    }
    
    func update(leagueGuid: String, season: Season) throws {
        let seasonToUpdate = seasonTable.filter(seasonGuid == season.id)
        
        guard let _ = try? DatabaseManager.sharedInstance.db.run( seasonToUpdate.update(
            seasonGuid <- season.id,
            self.leagueGuid <- leagueGuid,
            seasonName <- season.name,
            startDate <- season.startDate,
            endDate <- season.endDate,
            postSeasonStartDate <- season.postSeasonStartDate,
            postSeasonEndDate <- season.postSeasonEndDate
            
        )) else { throw DatabaseError.failureToUpdateInTable }
    }
    
    func getSeason(seasonGuid: String) throws -> Season? {
        var season: Season?
        let query = seasonTable.filter(seasonGuid == self.seasonGuid)
        guard let dbSeasonOpt = try? DatabaseManager.sharedInstance.db.pluck(query) else { throw DatabaseError.failureToGetFromTable }
        if let dbSeason = dbSeasonOpt {
            guard let teamsOpt = try? DAOTeam().getTeams(leagueGuid: dbSeason.get(leagueGuid)) else { throw DatabaseError.failureToGetFromTable }
            guard let games = try? DAOGame().getSeasonGames(seasonGuid: seasonGuid) else { throw DatabaseError.failureToGetFromTable }
            season = Season(
                id: dbSeason.get(self.seasonGuid),
                name: dbSeason.get(seasonName),
                startDate: dbSeason.get(startDate),
                endDate: dbSeason.get(endDate),
                postSeasonStartDate: dbSeason.get(postSeasonStartDate),
                postSeasonEndDate: dbSeason.get(postSeasonEndDate),
                teams: teamsOpt,
                regularSeasonGames: getGamesForSeason(seasonType: "regular", games: games, regularSeasonEndDate: dbSeason.get(endDate)),
                postSeasonGames: getGamesForSeason(seasonType: "postSeason", games: games, regularSeasonEndDate: dbSeason.get(endDate)))
        }
        return season
    }
    
    
    func getAllSeasons(leagueGuid: String) throws -> [Season]? {
        var seasons = [Season]()
        let query = seasonTable.filter(leagueGuid == self.leagueGuid)
        guard let dbSeasons = try? DatabaseManager.sharedInstance.db.prepare(query) else { throw DatabaseError.failureToGetFromTable }
        for dbSeason in dbSeasons {
            guard let teamsOpt = try? DAOTeam().getTeams(leagueGuid: leagueGuid) else { throw DatabaseError.failureToGetFromTable }

            guard let games = try? DAOGame().getSeasonGames(seasonGuid: dbSeason.get(seasonGuid)) else { throw DatabaseError.failureToGetFromTable }
            let newSeason = Season(
                id: dbSeason.get(seasonGuid),
                name: dbSeason.get(seasonName),
                startDate: dbSeason.get(startDate),
                endDate: dbSeason.get(endDate),
                postSeasonStartDate: dbSeason.get(postSeasonStartDate),
                postSeasonEndDate: dbSeason.get(postSeasonEndDate),
                teams: teamsOpt,
                regularSeasonGames: getGamesForSeason(seasonType: "regular", games: games, regularSeasonEndDate: dbSeason.get(endDate)),
                postSeasonGames: getGamesForSeason(seasonType: "postSeason", games: games, regularSeasonEndDate: dbSeason.get(endDate)))
            seasons.append(newSeason)
        }
        return seasons.count > 0 ? seasons : .none
    }
    
    func getAllSeasons(teamGuid: String?) throws -> [Season] {
        var seasons = [Season]()
        if let teamId = teamGuid {
            let mappingQuery = seasonTeamMappingTable.filter(teamId == self.teamGuid)
            guard let dbMappings = try? DatabaseManager.sharedInstance.db.prepare(mappingQuery) else { throw DatabaseError.failureToGetFromTable }
            for dbMapping in dbMappings {
                guard let seasonOpt = try? self.getSeason(seasonGuid: dbMapping.get(seasonMappingGuid)) else { throw DatabaseError.failureToGetFromTable }
                if let season = seasonOpt {
                    seasons.append(season)
                }
            }
        }
        return seasons
    }
    
    func deleteSeason(_ guid: String) throws {
        let query = seasonTable.filter(seasonGuid == guid)
        guard let _ = try? DatabaseManager.sharedInstance.db.run(query.delete()) else { throw DatabaseError.failureToDeleteFromTable }
        try deleteMappingsForSeason(guid: guid)
    }
    
    private func deleteMappingsForSeason(guid: String) throws {
        let query = seasonTeamMappingTable.filter(seasonMappingGuid == guid)
        guard let _ = try? DatabaseManager.sharedInstance.db.run(query.delete()) else { throw DatabaseError.failureToDeleteFromTable }
    }
    
    func drop() throws {
        try? dropMappingTable()
        guard let _ = try? DatabaseManager.sharedInstance.db.run(seasonTable.drop(ifExists: true)) else { throw DatabaseError.failureToDropTable }
    }
    
    private func dropMappingTable() throws {
        guard let _ = try? DatabaseManager.sharedInstance.db.run(seasonTeamMappingTable.drop(ifExists: true)) else { throw DatabaseError.failureToDropTable }
    }
    
    func getGamesForSeason(seasonType: String, games: [Game]?, regularSeasonEndDate: Date) -> [Game]? {
        var gamesForType: [Game]?
        if let gs = games {
            switch seasonType {
            case "regular":
                gamesForType = gs.filter { $0.dateTime <= regularSeasonEndDate }
            case "postSeason":
                gamesForType = gs.filter { $0.dateTime > regularSeasonEndDate }
            default:break
            }
        }
        return gamesForType
    }
    
}
