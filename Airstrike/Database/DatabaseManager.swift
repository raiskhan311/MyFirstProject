//
//  DatabaseManager.swift
//  Airstrike
//
//  Created by Jeffrey K Lewis on 12/1/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit
import SQLite

class DatabaseManager: NSObject {
    
    class var sharedInstance: DatabaseManager {
        struct Singleton {
            static let instance = DatabaseManager()
        }
        return Singleton.instance
    }
    
    var db: Connection
    
    private override init() {
        let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        print("DatabaseDirectory: " + String(dir))
        db = try! Connection("\(dir)/appDB.sqlite3")
    }
    
    func createTables() {
        do {
            try DAOAward().create()
            try DAOCachedMedia().create()
            try DAOFeed().create()
            try DAOGame().create()
            try DAOLeague().create()
            try DAOMedia().create()
            try DAOMediaMapping().create()
            try DAOPerson().create()
            try DAOPlayer().create()
            try DAOSeason().create()
            try DAOStat().create()
            try DAOTeam().create()
            try DAOUser().create()
            try DAOVersion().create()
        } catch {
            print("Table Creation Failed")
        }
    }
    
    func reset() {
        do {
            try DAOAward().drop()
            try DAOFeed().drop()
            try DAOGame().drop()
            try DAOLeague().drop()
            try DAOMedia().create()
            try DAOMediaMapping().create()
            try DAOPerson().drop()
            try DAOPlayer().drop()
            try DAOSeason().drop()
            try DAOStat().drop()
            try DAOTeam().drop()
            try DAOUser().drop()
            try DAOVersion().drop()
        } catch {
            // Handle error of drop table failure
        }
        createTables()
    }
    
    func logout() {
        do {
            try DAOAward().drop()
            try DAOCachedMedia().drop()
            try DAOFeed().drop()
            try DAOGame().drop()
            try DAOLeague().drop()      
            try DAOMedia().create()
            try DAOMediaMapping().create()
            try DAOPerson().drop()
            try DAOPlayer().drop()
            try DAOSeason().drop()
            try DAOStat().drop()
            try DAOTeam().drop()
            try DAOUser().drop()
            try DAOVersion().drop()
            deleteCachedMedia()
        } catch {
            // Handle error of drop table failure
        }
    }
    
    func deleteCachedMedia() {
        
        let fileManager = FileManager.default
        do {
            let newDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("CachedMedia", isDirectory: true)
            let filePaths = try fileManager.contentsOfDirectory(atPath: newDirectory.path)
            for filePath in filePaths {
                let filePathToDelete = newDirectory.appendingPathComponent(filePath)
                try fileManager.removeItem(atPath: filePathToDelete.path)
            }
        } catch let error as NSError {
            print("Could not clear temp folder: \(error.debugDescription)")
        }
    }
    

}
