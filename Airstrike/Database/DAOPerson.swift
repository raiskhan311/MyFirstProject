//
//  DAOPerson.swift
//  Airstrike
//
//  Created by Jeffrey K Lewis on 12/14/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import Foundation
import SQLite

class DAOPerson: NSObject {
    fileprivate static let personTableName = "person"
    
    fileprivate let personTable = Table(personTableName)
    
    fileprivate let personId = Expression<Int64>("id")
    
    fileprivate let personGuid = Expression<String>("guid")
    
    fileprivate let firstName = Expression<String>("first_name")
    
    fileprivate let lastName = Expression<String>("last_name")
        
    fileprivate let profileImagePath = Expression<String?>("profile_image_path")
    
    fileprivate let profileDescription = Expression<String?>("profile_description")
    
    func create() throws {
        guard let _ = try? DatabaseManager.sharedInstance.db.run( personTable.create(ifNotExists: true) { table in
            
            table.column(personId, primaryKey: true)
            table.column(personGuid, unique: true)
            table.column(firstName)
            table.column(lastName)
            table.column(profileImagePath)
            table.column(profileDescription)
            
        }) else { throw DatabaseError.failureToCreateTable }
    }
    
    func insert(persons: [Person]) throws {
        try DAOPlayer().insert(persons: persons)
        try insertPersons(persons)
    }
    
    fileprivate func insertPersons(_ persons: [Person]) throws {
        guard let personTable = try? DatabaseManager.sharedInstance.db.prepare("INSERT INTO person (guid, first_name, last_name, profile_image_path, profile_description) VALUES (?,?,?,?,?)") else { throw DatabaseError.failureToInsertIntoTable }
        try DatabaseManager.sharedInstance.db.transaction(.deferred) { () -> Void in
            for p in persons {
                try personTable.run(p.id, p.firstName, p.lastName, p.profileImagePath, p.profileDescription)
            }
        }
    }
    
    func update(_ person: Person) throws {
        let personToUpdate = personTable.filter(personGuid == person.id)
        if let players = person.players {
            for player in players {
                try? DAOPlayer().update(player)
            }
        }

        guard let _ = try? DatabaseManager.sharedInstance.db.run( personToUpdate.update(
            personGuid <- person.id,
            firstName <- person.firstName,
            lastName <- person.lastName,
            profileImagePath <- person.profileImagePath,
            profileDescription <- person.profileDescription
        )) else { throw DatabaseError.failureToUpdateInTable }
    }
    
    func getPerson(personId: String?) throws -> Person? {
        var person: Person?
        if let pId = personId {
            let query = personTable.filter(personGuid == pId)
            guard let dbPerson = try? DatabaseManager.sharedInstance.db.pluck(query) else { throw DatabaseError.failureToGetFromTable }
            if let dbp = dbPerson {
                guard let players = try? DAOPlayer().getPlayers(personGuid: dbp.get(personGuid)) else { throw DatabaseError.failureToGetFromTable }
                person = Person(
                    id: dbp.get(personGuid),
                    firstName: dbp.get(firstName),
                    lastName: dbp.get(lastName),
                    profileImagePath: dbp.get(profileImagePath),
                    profileDescription: dbp.get(profileDescription),
                    players: players)
            }
        }
        return person
    }
    
    func getAllPersons() throws -> [Person]? {
        var persons = [Person]()
        let query = personTable
        guard let dbPersons = try? DatabaseManager.sharedInstance.db.prepare(query) else { throw DatabaseError.failureToGetFromTable }
        for dbPerson in dbPersons {
            guard let players = try? DAOPlayer().getPlayers(personGuid: dbPerson.get(personGuid)) else { continue }
            let newPerson = Person(
                id: dbPerson.get(personGuid),
                firstName: dbPerson.get(firstName),
                lastName: dbPerson.get(lastName),
                profileImagePath: dbPerson.get(profileImagePath),
                profileDescription: dbPerson.get(profileDescription),
                players: players)
            persons.append(newPerson)
        }
        return persons.count > 0 ? persons : .none
    }
    
    func deletePerson(_ guid: String) throws {
        let query = personTable.filter(personGuid == guid)
        guard let _ = try? DatabaseManager.sharedInstance.db.run(query.delete()) else { throw DatabaseError.failureToDeleteFromTable }
    }
    
    func drop() throws {
        guard let _ = try? DatabaseManager.sharedInstance.db.run(personTable.drop(ifExists: true)) else { throw DatabaseError.failureToDropTable }
    }
}
