//
//  Stat.swift
//  Airstrike
//
//  Created by Jeffrey K Lewis on 12/1/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

class Stat: NSObject {

    let id: String
    
    let type: StatType
    
    let value: Double
    
    let timeOfGame: GameStatus
    
    let playerId: String
    
    let teamId: String
    
    let gameId: String
    
    let seasonId: String
    
    let leagueId: String
    
    let mediaId: String?
    
    let position: Position
    
    init(id: String, type: StatType, value: Double, timeOfGame: GameStatus, playerId: String, teamId: String, gameId: String, seasonId: String, leagueId: String, mediaId: String?, position: Position) {
        self.id = id
        self.type = type
        self.value = value
        self.timeOfGame = timeOfGame
        self.playerId = playerId
        self.teamId = teamId
        self.gameId = gameId
        self.seasonId = seasonId
        self.leagueId = leagueId
        self.mediaId = mediaId
        self.position = position
    }
    
    func toJson() -> String? {
        var dictionary = [String : Any]()
        dictionary["id"] = self.id
        dictionary["type"] = self.type.rawValue
        dictionary["value"] = self.value
        dictionary["timeOfGame"] = self.timeOfGame.rawValue
        dictionary["playerId"] = self.playerId
        dictionary["teamId"] = self.teamId
        dictionary["gameId"] = self.gameId
        dictionary["seasonId"] = self.seasonId
        dictionary["leagueId"] = self.leagueId
        dictionary["mediaId"] = self.mediaId
        dictionary["position"] = self.position.rawValue
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: []) else { return .none }
        return String(data: jsonData, encoding: String.Encoding.utf8)
    }

}
