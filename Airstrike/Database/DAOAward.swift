//
//  DAOAward.swift
//  Airstrike
//
//  Created by Bret Smith on 12/16/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit
import SQLite

class DAOAward: NSObject {
    fileprivate static let awardTableName = "award"
    
    fileprivate let awardTable = Table(awardTableName)
    
    fileprivate let awardId = Expression<Int64>("id")
    
    fileprivate let awardGuid = Expression<String>("guid")
    
    fileprivate let dateReceived = Expression<String>("creation_date")
    
    fileprivate let recipientId = Expression<String>("recipient_guid")
    
    fileprivate let title = Expression<String>("title")
    
    func create() throws {
        guard let _ = try? DatabaseManager.sharedInstance.db.run( awardTable.create(ifNotExists: true) { table in
            
            table.column(awardId, primaryKey: true)
            table.column(awardGuid, unique: true)
            table.column(recipientId)
            table.column(dateReceived)
            table.column(title)
            
        }) else { throw DatabaseError.failureToCreateTable }
    }
    
    func insert(_ recipientGuid: String, award: Award) throws {
        guard let _ = try? DatabaseManager.sharedInstance.db.run( awardTable.insert(
            awardGuid <- award.id,
            recipientId <- recipientGuid,
            dateReceived <- award.date.iso8601,
            title <- award.title
        )) else { throw DatabaseError.failureToInsertIntoTable }
        
    }
    
    func insertPlayerAwards(persons: [Person]) throws {
        guard let awardTable = try? DatabaseManager.sharedInstance.db.prepare("INSERT INTO award (guid, creation_date, recipient_guid, title) VALUES (?,?,?,?)") else { throw DatabaseError.failureToInsertIntoTable }
        try DatabaseManager.sharedInstance.db.transaction(.deferred) { () -> Void in
            for person in persons {
                if let players = person.players {
                    for player in players {
                        if let awards = player.awards {
                            for a in awards {
                                try awardTable.run(a.id, a.date.iso8601, player.id, a.title)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func update(_ recipientGuid: String, award: Award) throws {
        let awardToUpdate = awardTable.filter(awardGuid == award.id)
        
        guard let _ = try? DatabaseManager.sharedInstance.db.run( awardToUpdate.update(
            awardGuid <- award.id,
            recipientId <- recipientGuid,
            dateReceived <- award.date.iso8601,
            title <- award.title
        )) else { throw DatabaseError.failureToUpdateInTable }
    }
    
    func getAllAwards(_ recipientGuid: String) throws -> [Award]? {
        var awards = [Award]()
        let query = awardTable.filter(recipientId == recipientGuid)
        guard let dbAwards = try? DatabaseManager.sharedInstance.db.prepare(query) else {
            throw DatabaseError.failureToGetFromTable }
        for dbAward in dbAwards {
            guard let date = dbAward.get(dateReceived).dateFromISO8601 else { throw DatabaseError.failureToGetFromTable }
            let newAward = Award(
                id: dbAward.get(awardGuid),
                title: dbAward.get(title),
                date: date)
            awards.append(newAward)
        }
        return awards.count > 0 ? awards : .none
    }
    
    func deleteAward(_ guid: String) throws {
        let query = awardTable.filter(awardGuid == guid)
        guard let _ = try? DatabaseManager.sharedInstance.db.run(query.delete()) else { throw DatabaseError.failureToDeleteFromTable }
    }
    
    func drop() throws {
        guard let _ = try? DatabaseManager.sharedInstance.db.run(awardTable.drop(ifExists: true)) else { throw DatabaseError.failureToDropTable }
    }

}
