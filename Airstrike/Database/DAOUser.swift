//
//  DAOUser.swift
//  Airstrike
//
//  Created by Jeffrey K Lewis on 12/14/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import Foundation
import SQLite

class DAOUser: NSObject {

    fileprivate static let userTableName = "user"
    
    fileprivate let userTable = Table(userTableName)
    
    fileprivate let userId = Expression<Int64>("id")
    
    fileprivate let userGuid = Expression<String>("guid")
    
    fileprivate let role = Expression<String>("user_role")
    
    fileprivate let personGuid = Expression<String?>("person_guid")
    
    func create() throws {
        guard let _ = try? DatabaseManager.sharedInstance.db.run(userTable.create(ifNotExists: true) { table in
            
            table.column(userId, primaryKey: true)
            table.column(userGuid, unique: true)
            table.column(role)
            table.column(personGuid)
            
        }) else { throw DatabaseError.failureToCreateTable }
        self.createMapping()
    }
    
    func insertUser(userId: String, userRole: Role, personGuid: String?, coordinatorLeagueIds: [String]?, playerLeagueIds: [String]?) throws {
        guard let _ = try? DatabaseManager.sharedInstance.db.run( userTable.insert(
            userGuid <- userId,
            role <- userRole.rawValue,
            self.personGuid <- personGuid
        )) else { throw DatabaseError.failureToInsertIntoTable }
        self.insertMappings(userId: userId, coordinatorLeagueIds: coordinatorLeagueIds, playerLeagueIds: playerLeagueIds)
    }
    
    func update(userId: String, userRole: Role, personGuid: String?, coordinatorLeagueIds: [String]?, playerLeagueIds: [String]?) throws {
        let userToUpdate = userTable.filter(userGuid == userId)
        guard let _ = try? DatabaseManager.sharedInstance.db.run( userToUpdate.update(
            userGuid <- userId,
            role <- userRole.rawValue,
            self.personGuid <- personGuid
        )) else { throw DatabaseError.failureToUpdateInTable }
        self.deleteMappings(userId: userId)
        self.insertMappings(userId: userId, coordinatorLeagueIds: coordinatorLeagueIds, playerLeagueIds: playerLeagueIds)
    }
    
    func getUser() throws -> User? {
        let query = userTable
        guard let dbUserOpt = try? DatabaseManager.sharedInstance.db.pluck(query), let dbUser = dbUserOpt else { throw DatabaseError.failureToGetFromTable }
        guard let personOpt = try? DAOPerson().getPerson(personId: dbUser.get(personGuid)) else { return .none }
        guard let role = Role(rawValue: dbUser.get(role)) else { throw DatabaseError.failureToGetFromTable }
        
        let newUser = User(
            id: dbUser.get(userGuid),
            role: role,
            person: personOpt,
            coordinatorLeagueIds: self.getAllLeagueIds(for: dbUser.get(userGuid))?.coordinator,
            playerLeagueIds: self.getAllLeagueIds(for: dbUser.get(userGuid))?.player
        )
        
        return newUser
    }
    
    func getPersonForUser() throws -> Person? {
        let query = userTable
        guard let dbUserOpt = try? DatabaseManager.sharedInstance.db.pluck(query), let dbUser = dbUserOpt else { throw DatabaseError.failureToGetFromTable }
        guard let personOpt = try? DAOPerson().getPerson(personId: dbUser.get(personGuid)), let person = personOpt else { return .none }
        guard let role = Role(rawValue: dbUser.get(role)) else { throw DatabaseError.failureToGetFromTable }

        let newUser = User(
            id: dbUser.get(userGuid),
            role: role,
            person: person,
            coordinatorLeagueIds: self.getAllLeagueIds(for: dbUser.get(userGuid))?.coordinator,
            playerLeagueIds: self.getAllLeagueIds(for: dbUser.get(userGuid))?.player
        )
        
        return newUser.person
    }
    
    func deleteUser(_ guid: String) throws {
        deleteMappings(userId: guid)
        let query = userTable.filter(userGuid == guid)
        guard let _ = try? DatabaseManager.sharedInstance.db.run(query.delete()) else { throw DatabaseError.failureToDeleteFromTable }
    }
    
    func drop() throws {
        self.dropMapping()
        guard let _ = try? DatabaseManager.sharedInstance.db.run(userTable.drop(ifExists: true)) else { throw DatabaseError.failureToDropTable }
    }
    
    // MARK: LeagueIds Mapping Table
    
    fileprivate static let mappingTableName = "league_user_mapping"
    
    fileprivate let mappingTable = Table(mappingTableName)
    
    fileprivate let userIdMapping = Expression<String>("user_id")
    
    fileprivate let coordinatorLeagueIdMapping = Expression<String?>("coordinator_league_id")
    
    fileprivate let playerLeagueIdMapping = Expression<String?>("player_league_id")
    
    fileprivate func createMapping() {
        guard let _ = try? DatabaseManager.sharedInstance.db.run(mappingTable.create(ifNotExists: true) { table in
            table.column(userIdMapping)
            table.column(coordinatorLeagueIdMapping)
            table.column(playerLeagueIdMapping)
        }) else { return }
    }
    
    fileprivate func insertMappings(userId: String, coordinatorLeagueIds: [String]?, playerLeagueIds: [String]?) {
        if let c = coordinatorLeagueIds {
            for l in c {
                self.insertMapping(userId: userId, coordinatorLeagueId: l, playerLeagueId: .none)
            }
        }
        if let p = playerLeagueIds {
            for l in p {
                self.insertMapping(userId: userId, coordinatorLeagueId: .none, playerLeagueId: l)
            }
        }
    }
    
    fileprivate func insertMapping(userId: String, coordinatorLeagueId: String?, playerLeagueId: String?) {
        guard let _ = try? DatabaseManager.sharedInstance.db.run( mappingTable.insert(
            userIdMapping <- userId,
            coordinatorLeagueIdMapping <- coordinatorLeagueId,
            playerLeagueIdMapping <- playerLeagueId
        )) else { return }
    }
    
    fileprivate func getAllLeagueIds(for userId: String) -> (coordinator: [String]?, player: [String]?)? {
        var allCoordinatorLeagueIds = [String]()
        var allPlayerLeagueIds = [String]()
        
        let query = mappingTable.filter(userId == userIdMapping)
        guard let dbRows = try? DatabaseManager.sharedInstance.db.prepare(query) else { return .none }
        
        for row in dbRows {
            if let c = row.get(coordinatorLeagueIdMapping) {
                allCoordinatorLeagueIds.append(c)
            } else if let p = row.get(playerLeagueIdMapping) {
                allPlayerLeagueIds.append(p)
            }
        }
        if allCoordinatorLeagueIds.count + allPlayerLeagueIds.count == 0 {
            return .none
        } else {
            return (coordinator: allCoordinatorLeagueIds.count > 0 ? allCoordinatorLeagueIds : .none, player: allPlayerLeagueIds.count > 0 ? allPlayerLeagueIds : .none)
        }
    }
    
    fileprivate func deleteMappings(userId: String) {
        let query = mappingTable.filter(userIdMapping == userId)
        guard let _ = try? DatabaseManager.sharedInstance.db.run(query.delete()) else { return }
    }
    
    fileprivate func deleteMapping(userId: String, coordinatorLeagueId: String?, playerLeagueId: String?) {
        var query = mappingTable.filter(userIdMapping == userId)
        if let c = coordinatorLeagueId {
            query = query.filter(coordinatorLeagueIdMapping == c)
        }
        if let p = playerLeagueId {
            query = query.filter(playerLeagueIdMapping == p)
        }
        guard let _ = try? DatabaseManager.sharedInstance.db.run(query.delete()) else { return }
    }
    
    fileprivate func dropMapping() {
        guard let _ = try? DatabaseManager.sharedInstance.db.run(mappingTable.drop(ifExists: true)) else { return }
    }

    
}
