//
//  CachedMedia.swift
//  Airstrike
//
//  Created by Jeffrey K Lewis on 1/9/17.
//  Copyright © 2017 Airstrike. All rights reserved.
//

import Foundation

class CachedMedia: NSObject {
    
    let id: String
    
    let duration: String
    
    let date: Date
    
    let statIds: [String]?
    
    init(id: String, duration: String, date: Date, statIds: [String]?) {
        self.id = id
        self.duration = duration
        self.date = date
        self.statIds = statIds
    }
    
    func getFilePath() -> String {
        let newDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("CachedMedia", isDirectory: true)
        let mediaFileURL = newDirectory.appendingPathComponent(id).appendingPathExtension("mp4")

        return mediaFileURL.path
    }
    
    func removeFromCachedMediaDirectory() {
        let newDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("CachedMedia", isDirectory: true)
        let mediaFilePath = newDirectory.appendingPathComponent(id).appendingPathExtension("mp4").path
        if FileManager.default.fileExists(atPath: mediaFilePath) {
            try? FileManager.default.removeItem(atPath: mediaFilePath)
        }
    }
    
}
