//
//  StatTypeEnum.swift
//  Airstrike
//
//  Created by Jeffrey K Lewis on 12/1/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import Foundation

enum StatType: String {
    case yards = "Yard"
    case touchdown = "Touchdown"
    case interception = "Interception"
    case attempt = "Attempt"
    case sack = "Sack"
    case passCompletion = "Completion"
    case passReception = "Reception"
    case target = "Target"
    case drop = "Drop"
    case knockdown = "Knockdown"
    case pick6 = "INT-6"
}

class StatTypeHelperFunctions: NSObject {
    
    static func getStatTypesFor(position: Position) -> [StatType] {
        switch position {
        case .quarterBack:
            return getAllQbStatTypes()
        case .wideReceiver:
            return getAllWRStatTypes()
        case .defensiveBack:
            return getAllDBStatTypes()
        }
    }
    
    private static func getAllQbStatTypes() -> [StatType] {
        return [.yards, .touchdown, .interception, .attempt, .passCompletion, .sack]
    }
    
    private static func getAllWRStatTypes() -> [StatType] {
        return [.passReception, .yards, .touchdown, .target, .drop, .interception, .knockdown, .pick6]
    }
    
    private static func getAllDBStatTypes() -> [StatType] {
        return [.passReception, .yards, .touchdown, .target, .drop, .interception, .knockdown, .pick6]
    }
}
