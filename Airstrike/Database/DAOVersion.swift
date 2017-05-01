//
//  DAOVersion.swift
//  Airstrike
//
//  Created by Bret Smith on 2/1/17.
//  Copyright © 2017 Airstrike. All rights reserved.
//

import Foundation
import SQLite
import UIKit

class DAOVersion {
    fileprivate static let versionTableName = "version"
    
    fileprivate let versionTable = Table(versionTableName)
    
    fileprivate let versionId = Expression<Int64>("id")
    
    fileprivate let versionNumber = Expression<Int>("versionNumber")
    
    func create() throws {
        guard let _ = try? DatabaseManager.sharedInstance.db.run( versionTable.create(ifNotExists: true) { table in
            
            table.column(versionId, primaryKey: true)
            table.column(versionNumber)
            
        }) else { throw DatabaseError.failureToCreateTable }
        try? insert()
    }
    
    private func insert() throws {
        guard let _ = try? DatabaseManager.sharedInstance.db.run( versionTable.insert(
            versionNumber <- 0
        )) else { throw DatabaseError.failureToInsertIntoTable }
    }
    
    func update(latestVersion: Int) throws {
        guard let _ = try? DatabaseManager.sharedInstance.db.run( versionTable.update(
            versionNumber <- latestVersion
        )) else { throw DatabaseError.failureToUpdateInTable }
    }
    
    func getVersion() throws -> Int {
        var version = 0
        guard let dbVersion = try? DatabaseManager.sharedInstance.db.pluck(versionTable) else {
            throw DatabaseError.failureToGetFromTable }
        if let number = dbVersion?.get(versionNumber) {
            version = number
        }
        return version
    }
    
    func drop() throws {
        guard let _ = try? DatabaseManager.sharedInstance.db.run(versionTable.drop(ifExists: true)) else { throw DatabaseError.failureToDropTable }
    }
}
