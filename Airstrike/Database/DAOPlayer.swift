//
//  DAOPlayer.swift
//  Airstrike
//
//  Created by Jeffrey K Lewis on 12/14/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import Foundation
import SQLite	

class DAOPlayer: NSObject {
    fileprivate static let playerTableName = "player"
    
    fileprivate let playerTable = Table(playerTableName)
    
    fileprivate let playerId = Expression<Int64>("id")
    
    fileprivate let playerGuid = Expression<String>("guid")
    
    fileprivate let leagueGuid = Expression<String>("league_guid")
    
    fileprivate let teamGuid = Expression<String?>("team_guid")
    
    fileprivate let personGuid = Expression<String>("person_guid")
    
    fileprivate let number = Expression<Int>("number")
    
    func create() throws {
        guard let _ = try? DatabaseManager.sharedInstance.db.run( playerTable.create(ifNotExists: true) { table in
            
            table.column(playerId, primaryKey: true)
            table.column(playerGuid, unique: true)
            table.column(leagueGuid)
            table.column(teamGuid)
            table.column(personGuid)
            table.column(number)
            
        }) else { throw DatabaseError.failureToCreateTable }
    }
    
    func insert(persons: [Person]) throws {
        try? DAOAward().insertPlayerAwards(persons: persons)
        try insertPlayers(persons: persons)
    }
    
    func insertPlayer(player: Player?) throws {
        guard let personTable = try? DatabaseManager.sharedInstance.db.prepare("INSERT INTO player (guid, league_guid, team_guid, person_guid, number) VALUES (?,?,?,?,?)") else { throw DatabaseError.failureToInsertIntoTable }
        try DatabaseManager.sharedInstance.db.transaction(.deferred) { () -> Void in
            if let p = player {
                try personTable.run(p.id, p.leagueId, p.teamId, p.personId, p.number)
            }
        }
    }
    
    fileprivate func insertPlayers(persons: [Person]) throws {
        guard let personTable = try? DatabaseManager.sharedInstance.db.prepare("INSERT INTO player (guid, league_guid, team_guid, person_guid, number) VALUES (?,?,?,?,?)") else { throw DatabaseError.failureToInsertIntoTable }
        try DatabaseManager.sharedInstance.db.transaction(.deferred) { () -> Void in
            for person in persons {
                person.players?.forEach {
                    _ = try? personTable.run($0.id, $0.leagueId, $0.teamId, $0.personId, $0.number)
                }
            }
        }
    }
    
    func update(_ player: Player) throws {
        let playerToUpdate = playerTable.filter(playerGuid == player.id)
        player.awards?.forEach {
            try? DAOAward().update(player.id, award: $0)
        }

        guard let _ = try? DatabaseManager.sharedInstance.db.run( playerToUpdate.update(
            playerGuid <- player.id,
            leagueGuid <- player.leagueId,
            teamGuid <- player.teamId,
            number <- player.number,
            personGuid <- player.personId
        )) else { throw DatabaseError.failureToUpdateInTable }
    }
    
    func getPlayers(personGuid: String?) throws -> [Player]? {
        var players = [Player]()
        if let pGuid = personGuid {
            let query = playerTable.filter(self.personGuid == pGuid)
            guard let dbPlayers = try? DatabaseManager.sharedInstance.db.prepare(query) else { throw DatabaseError.failureToGetFromTable }
            
            for dbp in dbPlayers {
                guard let awards = try? DAOAward().getAllAwards(dbp.get(self.playerGuid)) else { throw DatabaseError.failureToGetFromTable }
                
                players.append(Player(
                    id: dbp.get(playerGuid),
                    leagueId: dbp.get(leagueGuid),
                    teamId: dbp.get(teamGuid),
                    personId: dbp.get(self.personGuid),
                    number: dbp.get(number),
                    awards: awards))
            }
        }
        return players.count > 0 ? players : .none
    }
    
    func getPlayersForTeam(teamGuid: String) throws -> [Player] {
        var players = [Player]()
        let query = playerTable.filter(self.teamGuid == teamGuid)
        guard let dbPlayers = try? DatabaseManager.sharedInstance.db.prepare(query) else { throw DatabaseError.failureToGetFromTable }
        for dbPlayer in dbPlayers {
            guard let awards = try? DAOAward().getAllAwards(dbPlayer.get(playerGuid)) else { continue }
            
            let newPlayer = Player(
                id: dbPlayer.get(playerGuid),
                leagueId: dbPlayer.get(leagueGuid),
                teamId: dbPlayer.get(self.teamGuid),
                personId: dbPlayer.get(personGuid),
                number: dbPlayer.get(number),
                awards: awards)
            players.append(newPlayer)
        }
        return players
    }
    
    func getPlayersForLeague(leagueGuid: String) throws -> [Player] {
        var players = [Player]()
        let query = playerTable.filter(self.leagueGuid == leagueGuid)
        guard let dbPlayers = try? DatabaseManager.sharedInstance.db.prepare(query) else { throw DatabaseError.failureToGetFromTable }
        for dbPlayer in dbPlayers {
            guard let awards = try? DAOAward().getAllAwards(dbPlayer.get(playerGuid)) else { continue }
            
            let newPlayer = Player(
                id: dbPlayer.get(playerGuid),
                leagueId: dbPlayer.get(self.leagueGuid),
                teamId: dbPlayer.get(teamGuid),
                personId: dbPlayer.get(personGuid),
                number: dbPlayer.get(number),
                awards: awards)
            players.append(newPlayer)
        }
        return players
    }
    
    func getAllPlayers() throws -> [Player] {
        var players = [Player]()
        let query = playerTable
        guard let dbPlayers = try? DatabaseManager.sharedInstance.db.prepare(query) else { throw DatabaseError.failureToGetFromTable }
        for dbPlayer in dbPlayers {
            guard let awards = try? DAOAward().getAllAwards(dbPlayer.get(playerGuid)) else { continue }

            let newPlayer = Player(
                id: dbPlayer.get(playerGuid),
                leagueId: dbPlayer.get(leagueGuid),
                teamId: dbPlayer.get(teamGuid),
                personId: dbPlayer.get(personGuid),
                number: dbPlayer.get(number),
                awards: awards)
            players.append(newPlayer)
        }
        return players
    }
    
    func deletePlayer(_ guid: String) throws {
        let query = playerTable.filter(playerGuid == guid)
        guard let _ = try? DatabaseManager.sharedInstance.db.run(query.delete()) else { throw DatabaseError.failureToDeleteFromTable }
    }
    
    func drop() throws {
        guard let _ = try? DatabaseManager.sharedInstance.db.run(playerTable.drop(ifExists: true)) else { throw DatabaseError.failureToDropTable }
    }
}
