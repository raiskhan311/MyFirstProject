//
//  DAOFeed.swift
//  Airstrike
//
//  Created by Bret Smith on 1/25/17.
//  Copyright © 2017 Airstrike. All rights reserved.
//

import SQLite

class DAOFeed: NSObject {
    
    private static let tableName = "feed"
    
    private let table = Table(tableName)
    
    private let id = Expression<Int>("id")
    
    private let guid = Expression<String>("guid")
    
    private let type = Expression<String>("type")
    
    private let mediaToken = Expression<String>("mediaToken")
    
    private let title = Expression<String>("title")
    
    private let creationDate = Expression<Date>("creation_date")
    
    private let leagueId = Expression<String>("leagueId")
    
    func create() throws {
        guard let _ = try? DatabaseManager.sharedInstance.db.run( table.create(ifNotExists: true) { table in
            
            table.column(id, primaryKey: true)
            table.column(guid, unique: true)
            table.column(type)
            table.column(mediaToken)
            table.column(title)
            table.column(creationDate)
            table.column(leagueId)
            
        }) else { throw DatabaseError.failureToCreateTable }
    }
    
    func insert(_ feed: Feed) throws {
        guard let _ = try? DatabaseManager.sharedInstance.db.run( table.insert(
            guid <- feed.id,
            type <- feed.mediaType.rawValue,
            mediaToken <- feed.mediaId,
            title <- feed.title,
            creationDate <- feed.creationDate,
            leagueId <- feed.leagueId
        )) else { throw DatabaseError.failureToInsertIntoTable }
    }
    
    func update(_ feed: Feed) throws {
        let feedToUpdate = table.filter(guid == feed.id)
        
        guard let _ = try? DatabaseManager.sharedInstance.db.run( feedToUpdate.update(
            guid <- feed.id,
            type <- feed.mediaType.rawValue,
            mediaToken <- feed.mediaId,
            title <- feed.title,
            creationDate <- feed.creationDate,
            leagueId <- feed.leagueId
            
        )) else { throw DatabaseError.failureToUpdateInTable }
    }
    
    func getAll() throws -> [Feed]? {
        var feed = [Feed]()
        let query = table
        guard let dbFeed = try? DatabaseManager.sharedInstance.db.prepare(query) else { throw DatabaseError.failureToGetFromTable }
        for dbf in dbFeed {
            guard let type = MediaType(rawValue: dbf.get(type)) else { continue }
            let newFeed = Feed(id: dbf.get(guid), creationDate: dbf.get(creationDate), title: dbf.get(title), mediaType: type, mediaId: dbf.get(mediaToken), leagueId: dbf.get(leagueId))
            feed.append(newFeed)
        }
        return feed.count > 0 ? feed : .none
    }
    
    func getAllWithLeagueId(_ leagueId: String) throws -> [Feed]? {
        var feed = [Feed]()
        let query = table.filter(self.leagueId == leagueId)
        guard let dbFeed = try? DatabaseManager.sharedInstance.db.prepare(query) else { throw DatabaseError.failureToGetFromTable }
        for dbf in dbFeed {
            guard let type = MediaType(rawValue: dbf.get(type)) else { continue }
            let newFeed = Feed(id: dbf.get(guid), creationDate: dbf.get(creationDate), title: dbf.get(title), mediaType: type, mediaId: dbf.get(mediaToken), leagueId: dbf.get(self.leagueId))
            feed.append(newFeed)
        }
        return feed.count > 0 ? feed : .none
    }
    
    func delete(_ guid: String?) throws {
        if let feedGuid = guid {
            let query = table.filter(self.guid == feedGuid)
            guard let _ = try? DatabaseManager.sharedInstance.db.run(query.delete()) else { throw DatabaseError.failureToDeleteFromTable }
        }
    }
    
    func drop() throws {
        guard let _ = try? DatabaseManager.sharedInstance.db.run(table.drop(ifExists: true)) else { throw DatabaseError.failureToDropTable }
    }
    
}
