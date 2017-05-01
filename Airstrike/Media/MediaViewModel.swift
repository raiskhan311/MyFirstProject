//
//  MediaViewModel.swift
//  Airstrike
//
//  Created by Bret Smith on 1/6/17.
//  Copyright © 2017 Airstrike. All rights reserved.
//

import UIKit

class MediaViewModel: NSObject {
    var media: [Media]?
    
    func initialize(player: Player?, game: Game?, team: Team?, season: Season?, league: League?) {
        var idType: IdType?
        var typeGuid: String?
        if let p = player {
            idType = IdType.player
            typeGuid = p.id
        } else if let g = game {
            idType = IdType.game
            typeGuid = g.id
        } else if let t = team {
            idType = IdType.team
            typeGuid = t.id
        } else if let s = season {
            idType = IdType.season
            typeGuid = s.id
        } else if let l = league {
            idType = IdType.league
            typeGuid = l.id
        }
        
        if let type = idType, let guid = typeGuid {
            guard let newMedia = try? DAOMedia().getMedia(of: (type, guid)) else { return }
            media = newMedia
        }
    }
    
    
    func sections() -> Int {
        return 1
    }
    
    func items() -> Int {
        return media?.count ?? 0
        //Number of video clips relevant to the initialized person/team/league/season/game
    }
    
    func reuseIdentifier() -> String {
        return "mediaCollectionViewCell"
    }
    
    func videoToken(for indexPath: IndexPath) -> String? {
        return media?[indexPath.item].mediaToken
    }
}
