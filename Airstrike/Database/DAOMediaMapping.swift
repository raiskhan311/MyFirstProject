//
//  DAOMediaMapping.swift
//  Airstrike
//
//  Created by Bret Smith on 1/25/17.
//  Copyright © 2017 Airstrike. All rights reserved.
//

import UIKit

import SQLite

class DAOMediaMapping: NSObject {
    
    private static let mappingTableName = "media_type_id_mapping"
    
    private let mediaMappingTable = Table(mappingTableName)
        
    private let id = Expression<Int>("id")
    
    private let mediaGuid = Expression<String>("media_guid")
    
    private let typeGuid = Expression<String>("type_guid")
    
    private let type = Expression<String>("type")
    
    
    func create() throws {
        guard let _ = try? DatabaseManager.sharedInstance.db.run( mediaMappingTable.create(ifNotExists: true) { table in
            
            table.column(id, primaryKey: true)
            table.column(mediaGuid)
            table.column(typeGuid)
            table.column(type)
            
        }) else { throw DatabaseError.failureToCreateTable }
    }
    
    func insert(mappings:[(mediaGuid: String, idType: IdType, typeGuid: String)]) throws {
        guard let mediaMappings = try? DatabaseManager.sharedInstance.db.prepare("INSERT INTO media_type_id_mapping (media_guid, type, type_guid) VALUES (?,?,?)") else { throw DatabaseError.failureToInsertIntoTable }
        try DatabaseManager.sharedInstance.db.transaction(.deferred) { () -> Void in
            for index in 0..<mappings.count {
                try mediaMappings.run(mappings[index].0, mappings[index].1.rawValue, mappings[index].2)
            }
        }
    }    
    
    func delete(_ guid: String?) throws {
        if let mediaGuid = guid {
            let query = mediaMappingTable.filter(self.mediaGuid == mediaGuid)
            guard let _ = try? DatabaseManager.sharedInstance.db.run(query.delete()) else { throw DatabaseError.failureToDeleteFromTable }
        }
    }
    
    func drop() throws {
        guard let _ = try? DatabaseManager.sharedInstance.db.run(mediaMappingTable.drop(ifExists: true)) else { throw DatabaseError.failureToDropTable }
    }


}
