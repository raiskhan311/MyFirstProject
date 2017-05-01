//
//  PositionEnum.swift
//  Airstrike
//
//  Created by Jeffrey K Lewis on 12/23/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import Foundation

enum Position: String {
    case quarterBack = "QB", wideReceiver = "WR", defensiveBack = "DB"
}

class PositionHelperFunctions: NSObject {
    
    static func getAllPositions() -> [Position] {
        return [.quarterBack, .wideReceiver, .defensiveBack]
    }
    
}
