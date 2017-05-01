//
//  DAOCachedMedia.swift
//  Airstrike
//
//  Created by Jeffrey K Lewis on 1/9/17.
//  Copyright © 2017 Airstrike. All rights reserved.
//

import Foundation
import SQLite

class DAOCachedMedia: NSObject {
    
    private static let tableName = "cached_media"
    
    private let table = Table(tableName)
    
    private let id = Expression<Int>("id")
    
    private let guid = Expression<String>("guid")
    
    private let duration = Expression<String>("duration")
    
    private let date = Expression<Date>("date")
    
    func create() throws {
        guard let _ = try? DatabaseManager.sharedInstance.db.run( table.create(ifNotExists: true) { table in
            
            table.column(id, primaryKey: true)
            table.column(guid, unique: true)
            table.column(duration)
            table.column(date)
            
        }) else { throw DatabaseError.failureToCreateTable }
    }
    
    func insert(_ media: CachedMedia) throws {
        guard let _ = try? DatabaseManager.sharedInstance.db.run( table.insert(
            guid <- media.id,
            duration <- media.duration,
            date <- media.date
        )) else { throw DatabaseError.failureToInsertIntoTable }
    }
    
    func getAll() throws -> [CachedMedia]? {
        var cachedMedia = [CachedMedia]()
        let query = table
        guard let dbMedia = try? DatabaseManager.sharedInstance.db.prepare(query) else { throw DatabaseError.failureToGetFromTable }
        for dbm in dbMedia {
            let newMedia = CachedMedia(id: dbm.get(guid), duration: dbm.get(duration), date: dbm.get(date), statIds: .none)
            cachedMedia.append(newMedia)
        }
        return cachedMedia.count > 0 ? cachedMedia : .none
    }
    
    func delete(_ guid: String?) throws {
        if let cachedMediaGuid = guid {
            let query = table.filter(self.guid == cachedMediaGuid)
            guard let _ = try? DatabaseManager.sharedInstance.db.run(query.delete()) else { throw DatabaseError.failureToDeleteFromTable }
        }
    }
    
    func drop() throws {
        guard let _ = try? DatabaseManager.sharedInstance.db.run(table.drop(ifExists: true)) else { throw DatabaseError.failureToDropTable }
    }

}
