//
//  DAOStat.swift
//  Airstrike
//
//  Created by Jeffrey K Lewis on 12/14/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import Foundation
import SQLite

class DAOStat: NSObject {

    fileprivate static let statTableName = "stat"
    
    fileprivate let statTable = Table(statTableName)
    
    fileprivate let statId = Expression<Int64>("id")
    
    fileprivate let statGuid = Expression<String>("guid")
    
    fileprivate let statType = Expression<String>("stat_type")
    
    fileprivate let value = Expression<Double>("value")
    
    fileprivate let playerGuid = Expression<String>("player_guid")
    
    fileprivate let teamGuid = Expression<String>("team_guid")

    fileprivate let gameGuid = Expression<String>("game_guid")

    fileprivate let seasonGuid = Expression<String>("season_guid")
    
    fileprivate let leagueGuid = Expression<String>("league_guid")
    
    fileprivate let mediaGuid = Expression<String?>("media_guid")

    fileprivate let timeOfGame = Expression<String>("time_of_game")
    
    fileprivate let position = Expression<String>("position")
    
    fileprivate let successfullyUploaded = Expression<Int>("uploaded")
    
    func create() throws {
        guard let _ = try? DatabaseManager.sharedInstance.db.run(statTable.create(ifNotExists: true) { table in
            
            table.column(statId, primaryKey: true)
            table.column(statGuid, unique: true)
            table.column(statType)
            table.column(value)
            table.column(playerGuid)
            table.column(teamGuid)
            table.column(gameGuid)
            table.column(seasonGuid)
            table.column(leagueGuid)
            table.column(mediaGuid)
            table.column(timeOfGame)
            table.column(position)
            table.column(successfullyUploaded)
            
        }) else { throw DatabaseError.failureToCreateTable }
    }
        
    func insertStats(stats: [Stat]) throws {
        guard let statsTable = try? DatabaseManager.sharedInstance.db.prepare("INSERT INTO stat (guid, stat_type, value, player_guid, team_guid, game_guid, season_guid, league_guid, media_guid, time_of_game, position, uploaded) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)") else { throw DatabaseError.failureToInsertIntoTable }
        var mappings = [(mediaGuid: String, idType: IdType, typeGuid: String)]()
        try DatabaseManager.sharedInstance.db.transaction(.deferred) { () -> Void in
            for s in stats {
                if let m = s.mediaId {
                    mappings.append((mediaGuid: m, idType: .game, typeGuid: s.gameId))
                    mappings.append((mediaGuid: m, idType: .season, typeGuid: s.seasonId))
                    mappings.append((mediaGuid: m, idType: .league, typeGuid: s.leagueId))
                    mappings.append((mediaGuid: m, idType: .team, typeGuid: s.teamId))
                    mappings.append((mediaGuid: m, idType: .player, typeGuid: s.playerId))
                }
                _ = try? statsTable.run(s.id, s.type.rawValue, s.value, s.playerId, s.teamId, s.gameId, s.seasonId, s.leagueId, s.mediaId, s.timeOfGame.rawValue, s.position.rawValue, 1)
            }
        }
        try? DAOMediaMapping().insert(mappings: mappings)
    }
    
    func insertStat(stat: Stat, uploadSuccess: Bool) throws {
        var uploadSuccessInt = 0
        if uploadSuccess {
          uploadSuccessInt = 1
        }
        guard let statsTable = try? DatabaseManager.sharedInstance.db.prepare("INSERT INTO stat (guid, stat_type, value, player_guid, team_guid, game_guid, season_guid, league_guid, media_guid, time_of_game, position, uploaded) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)") else { throw DatabaseError.failureToInsertIntoTable }
        var mappings = [(mediaGuid: String, idType: IdType, typeGuid: String)]()
        try DatabaseManager.sharedInstance.db.transaction(.deferred) { () -> Void in
            if let m = stat.mediaId {
                mappings.append((mediaGuid: m, idType: .game, typeGuid: stat.gameId))
                mappings.append((mediaGuid: m, idType: .season, typeGuid: stat.seasonId))
                mappings.append((mediaGuid: m, idType: .league, typeGuid: stat.leagueId))
                mappings.append((mediaGuid: m, idType: .team, typeGuid: stat.teamId))
                mappings.append((mediaGuid: m, idType: .player, typeGuid: stat.playerId))
            }
            _ = try? statsTable.run(stat.id, stat.type.rawValue, stat.value, stat.playerId, stat.teamId, stat.gameId, stat.seasonId, stat.leagueId, stat.mediaId, stat.timeOfGame.rawValue, stat.position.rawValue, uploadSuccessInt)
        }
        try? DAOMediaMapping().insert(mappings: mappings)
    }
    
    func updateUploadStatus(statId: String) throws {
        let statToUpdate = statTable.filter(statGuid == statId)
        guard let _ = try? DatabaseManager.sharedInstance.db.run( statToUpdate.update(
            successfullyUploaded <- 1
        )) else { throw DatabaseError.failureToUpdateInTable }
    }
    
    func update(stat: Stat) throws {
        let statToUpdate = statTable.filter(statGuid == stat.id)
        
        guard let _ = try? DatabaseManager.sharedInstance.db.run( statToUpdate.update(
            statGuid <- stat.id,
            statType <- stat.type.rawValue,
            value <- stat.value,
            playerGuid <- stat.playerId,
            teamGuid <- stat.teamId,
            gameGuid <- stat.gameId,
            seasonGuid <- stat.seasonId,
            leagueGuid <- stat.leagueId,
            mediaGuid <- stat.mediaId,
            timeOfGame <- stat.timeOfGame.rawValue,
            position <- stat.position.rawValue
        )) else { throw DatabaseError.failureToUpdateInTable }
    }
    
    func getAllCachedStats() throws -> [Stat]? {
        var stats = [Stat]()
        let query = statTable.filter(self.successfullyUploaded == 0)
        guard let dbStats = try? DatabaseManager.sharedInstance.db.prepare(query) else {
            throw DatabaseError.failureToGetFromTable }
        for dbStat in dbStats {
            guard let type = StatType(rawValue: dbStat.get(self.statType)) else { continue }
            guard let gameStatus = GameStatus(rawValue: dbStat.get(timeOfGame)) else { continue }
            guard let position = Position(rawValue: dbStat.get(position)) else { continue }
            let newStat = Stat(
                id: dbStat.get(statGuid),
                type: type,
                value: dbStat.get(value),
                timeOfGame: gameStatus,
                playerId: dbStat.get(self.playerGuid),
                teamId: dbStat.get(teamGuid),
                gameId: dbStat.get(gameGuid),
                seasonId: dbStat.get(seasonGuid),
                leagueId: dbStat.get(leagueGuid),
                mediaId: dbStat.get(mediaGuid),
                position: position
            )
            stats.append(newStat)
        }
        return stats.count > 0 ? stats : .none
    }

    
    func getAllStatsOfTypeForTeam(statType: StatType, teamId: String) throws -> [Stat]? {
        var stats = [Stat]()
        let query = statTable.filter(self.statType == statType.rawValue && self.teamGuid == teamId)
        guard let dbStats = try? DatabaseManager.sharedInstance.db.prepare(query) else {
            throw DatabaseError.failureToGetFromTable }
        for dbStat in dbStats {
            guard let type = StatType(rawValue: dbStat.get(self.statType)) else { continue }
            guard let gameStatus = GameStatus(rawValue: dbStat.get(timeOfGame)) else { continue }
            guard let position = Position(rawValue: dbStat.get(position)) else { continue }
            let newStat = Stat(
                id: dbStat.get(statGuid),
                type: type,
                value: dbStat.get(value),
                timeOfGame: gameStatus,
                playerId: dbStat.get(self.playerGuid),
                teamId: dbStat.get(teamGuid),
                gameId: dbStat.get(gameGuid),
                seasonId: dbStat.get(seasonGuid),
                leagueId: dbStat.get(leagueGuid),
                mediaId: dbStat.get(mediaGuid),
                position: position
            )
            stats.append(newStat)
        }
        return stats.count > 0 ? stats : .none
    }
    
    func getAllStatsOfTypeForLeague(statType: StatType, leagueId: String) throws -> [Stat]? {
        var stats = [Stat]()
        let query = statTable.filter(self.statType == statType.rawValue && self.leagueGuid == leagueId)
        guard let dbStats = try? DatabaseManager.sharedInstance.db.prepare(query) else {
            throw DatabaseError.failureToGetFromTable }
        for dbStat in dbStats {
            guard let type = StatType(rawValue: dbStat.get(self.statType)) else { continue }
            guard let gameStatus = GameStatus(rawValue: dbStat.get(timeOfGame)) else { continue }
            guard let position = Position(rawValue: dbStat.get(position)) else { continue }
            let newStat = Stat(
                id: dbStat.get(statGuid),
                type: type,
                value: dbStat.get(value),
                timeOfGame: gameStatus,
                playerId: dbStat.get(self.playerGuid),
                teamId: dbStat.get(teamGuid),
                gameId: dbStat.get(gameGuid),
                seasonId: dbStat.get(seasonGuid),
                leagueId: dbStat.get(leagueGuid),
                mediaId: dbStat.get(mediaGuid),
                position: position
            )
            stats.append(newStat)
        }
        return stats.count > 0 ? stats : .none
    }

    func getAllStats() throws -> [Stat]? {
        var stats = [Stat]()
        let query = statTable
        guard let dbStats = try? DatabaseManager.sharedInstance.db.prepare(query) else {
            throw DatabaseError.failureToGetFromTable }
        for dbStat in dbStats {
            guard let type = StatType(rawValue: dbStat.get(statType)) else { continue }
            guard let gameStatus = GameStatus(rawValue: dbStat.get(timeOfGame)) else { continue }
            guard let position = Position(rawValue: dbStat.get(position)) else { continue }
            let newStat = Stat(
                id: dbStat.get(statGuid),
                type: type,
                value: dbStat.get(value),
                timeOfGame: gameStatus,
                playerId: dbStat.get(self.playerGuid),
                teamId: dbStat.get(teamGuid),
                gameId: dbStat.get(gameGuid),
                seasonId: dbStat.get(seasonGuid),
                leagueId: dbStat.get(leagueGuid),
                mediaId: dbStat.get(mediaGuid),
                position: position
                )
            stats.append(newStat)
        }
        return stats.count > 0 ? stats : .none
    }
    
    func deleteStat(_ guid: String) throws {
        let query = statTable.filter(statGuid == guid)
        guard let _ = try? DatabaseManager.sharedInstance.db.run(query.delete()) else { throw DatabaseError.failureToDeleteFromTable }
    }
    
    func drop() throws {
        guard let _ = try? DatabaseManager.sharedInstance.db.run(statTable.drop(ifExists: true)) else { throw DatabaseError.failureToDropTable }
    }
    
}


