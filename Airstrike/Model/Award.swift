//
//  Award.swift
//  Airstrike
//
//  Created by Jeffrey K Lewis on 12/1/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

class Award: NSObject {

    let id: String
    
    let title: String
    
    let date: Date
    
    init(id: String, title: String, date: Date) {
        self.id = id
        self.title = title
        self.date = date
    }
}
