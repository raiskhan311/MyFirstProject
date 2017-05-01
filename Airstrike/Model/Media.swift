//
//  Media.swift
//  Airstrike
//
//  Created by Bret Smith on 1/25/17.
//  Copyright © 2017 Airstrike. All rights reserved.
//

import UIKit

class Media: NSObject {
    
    let id: String
    
    let type: MediaType
    
    let mediaToken: String
    
    let creationDate: Date
    
    init(id: String, type: MediaType, mediaToken: String, creationDate: Date) {
        self.id = id
        self.type = type
        self.mediaToken = mediaToken
        self.creationDate = creationDate
    }
}
