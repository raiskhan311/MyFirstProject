//
//  DAOMedia.swift
//  Airstrike
//
//  Created by Bret Smith on 1/25/17.
//  Copyright © 2017 Airstrike. All rights reserved.
//

import SQLite

class DAOMedia: NSObject {
    
    private static let tableName = "media"
    
    private let mediaTable = Table(tableName)
    
    private let id = Expression<Int>("id")
    
    private let guid = Expression<String>("guid")
    
    private let mediaType = Expression<String>("type")
    
    private let mediaToken = Expression<String>("mediaToken")
    
    private let creationDate = Expression<Date>("creation_date")
    
    private let mappingId = Expression<String>("mapping_id")
        
    
    func create() throws {
        guard let _ = try? DatabaseManager.sharedInstance.db.run( mediaTable.create(ifNotExists: true) { table in
            
            table.column(id, primaryKey: true)
            table.column(guid, unique: true)
            table.column(mediaType)
            table.column(mediaToken)
            table.column(creationDate)
            table.column(mappingId)
            
        }) else { throw DatabaseError.failureToCreateTable }
    }
    
    func insert(_ media: Media, mappingId: String) throws {
        guard let _ = try? DatabaseManager.sharedInstance.db.run( mediaTable.insert(
            guid <- media.id,
            mediaType <- media.type.rawValue,
            mediaToken <- media.mediaToken,
            creationDate <- media.creationDate,
            self.mappingId <- mappingId
        )) else { throw DatabaseError.failureToInsertIntoTable }
    }
    
    func update(_ media: Media, mappingId: String) throws {
        let mediaToUpdate = mediaTable.filter(guid == media.id)
        
        guard let _ = try? DatabaseManager.sharedInstance.db.run( mediaToUpdate.update(
            guid <- media.id,
            mediaType <- media.type.rawValue,
            mediaToken <- media.mediaToken,
            creationDate <- media.creationDate,
            self.mappingId <- mappingId
            
        )) else { throw DatabaseError.failureToUpdateInTable }
    }
    
    func getAll() throws -> [Media]? {
        var media = [Media]()
        let query = mediaTable
        guard let dbMedia = try? DatabaseManager.sharedInstance.db.prepare(query) else { throw DatabaseError.failureToGetFromTable }
        for dbm in dbMedia {
            guard let type = MediaType(rawValue: dbm.get(mediaType)) else { throw DatabaseError.failureToGetFromTable }
            let newMedia = Media(id: dbm.get(guid), type: type, mediaToken: dbm.get(mediaToken), creationDate: dbm.get(creationDate))
            media.append(newMedia)
        }
        return media.count > 0 ? media : .none
    }
    
    func getMedia(of type: (IdType, String)) throws -> [Media]? {
        var media = [Media]()
        let mappingTable = Table("media_type_id_mapping")
        let mediaGuid = Expression<String>("media_guid")
        let typeGuid = Expression<String>("type_guid")
        let idType = Expression<String>("type")

        let query = mediaTable
            .join(mappingTable, on: mediaGuid == mediaTable[mappingId])
            .select(mediaTable[guid], mediaTable[self.mediaType], mediaTable[mediaToken], mediaTable[creationDate])
            .filter(mappingTable[idType] == type.0.rawValue && type.1 == typeGuid)
        guard let dbMedia = try? DatabaseManager.sharedInstance.db.prepare(query) else { throw DatabaseError.failureToGetFromTable }
        for dbm in dbMedia {
            guard let type = MediaType(rawValue: dbm.get(mediaType)) else { continue }
            let newMedia = Media(id: dbm.get(guid), type: type, mediaToken: dbm.get(mediaToken), creationDate: dbm.get(creationDate))
            if !media.contains(where: { $0.mediaToken == newMedia.mediaToken }) {
                media.append(newMedia)
            }
        }
        return media.count > 0 ? media : .none
    }
    
    func delete(_ guid: String?) throws {
        if let mediaGuid = guid {
            let query = mediaTable.filter(self.guid == mediaGuid)
            guard let _ = try? DatabaseManager.sharedInstance.db.run(query.delete()) else { throw DatabaseError.failureToDeleteFromTable }
        }
    }
    
    func drop() throws {
        guard let _ = try? DatabaseManager.sharedInstance.db.run(mediaTable.drop(ifExists: true)) else { throw DatabaseError.failureToDropTable }
    }
    
}
