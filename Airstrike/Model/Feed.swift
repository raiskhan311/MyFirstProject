//
//  Feed.swift
//  Airstrike
//
//  Created by Bret Smith on 1/25/17.
//  Copyright © 2017 Airstrike. All rights reserved.
//

import Foundation

class Feed: NSObject {
    
    let id: String
    
    let creationDate: Date
    
    let title: String
    
    let mediaType: MediaType
    
    let mediaId: String
    
    let leagueId: String
    
    init(id: String, creationDate: Date, title: String, mediaType: MediaType, mediaId: String, leagueId: String) {
        self.id = id
        self.creationDate = creationDate
        self.title = title
        self.mediaType = mediaType
        self.mediaId = mediaId
        self.leagueId = leagueId
    }
    
}
