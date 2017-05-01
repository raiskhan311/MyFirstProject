//
//  LeaderboardsViewModel.swift
//  Airstrike
//
//  Created by Brian Nielson on 12/19/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

fileprivate enum LeaderboardTitles: String {
    case touchdownCaught = "Receiving Touchdowns"
    case touchdownThrown = "Touchdowns Thrown"
    case interceptionCaught = "Interceptions"
    case interceptionThrown = "Interceptions Thrown"
    case passCompletion = "Pass Completions"
    case passReception = "Pass Receptions"
    case pick6 = "Pick-6"
    case knockdown = "Knockdowns"
    case sack = "Sacks"
    
    static let allValues = [touchdownCaught, touchdownThrown, interceptionCaught, interceptionThrown, passCompletion, passReception, pick6, knockdown, sack]
    static let mapping: [LeaderboardTitles:StatType?] = [touchdownCaught:.touchdown, touchdownThrown: .touchdown, interceptionCaught:.interception, interceptionThrown: .interception, passCompletion:.passCompletion, passReception:.passReception, pick6: .pick6, knockdown:.knockdown, sack:.sack]
    static let position: [LeaderboardTitles: Position] = [touchdownCaught: .wideReceiver, touchdownThrown: .quarterBack, interceptionCaught: .defensiveBack, interceptionThrown: .quarterBack, passCompletion: .quarterBack, passReception: .wideReceiver, pick6: .defensiveBack, .knockdown: .defensiveBack, sack: .quarterBack]
}

class LeaderboardsViewModel {
    
    var league: League?
    private(set) var statType: StatType?
    private(set) var position: Position?
    private(set) var title = ""
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        return LeaderboardTitles.allValues.count
    }
    
    func identifier() -> String {
        return "genericCell"
    }
    
    func textLabelForRow(indexPath: IndexPath) -> String {
        return LeaderboardTitles.allValues[indexPath.item].rawValue
    }
    
    func cellHeight() -> CGFloat {
        return 60
    }
    
    func leagueId() -> String {
        var leagueId = ""
        if let l = league {
            leagueId = l.id
        }
        return leagueId
    }
    
    func statType(for indexPath: IndexPath) {
        var statType: StatType?
        let leaderboardTitleType = LeaderboardTitles.allValues[indexPath.item]
        self.position = LeaderboardTitles.position[leaderboardTitleType]
        if let dictionaryValue = LeaderboardTitles.mapping[leaderboardTitleType] {
            statType = dictionaryValue
        }
        self.statType = statType
        title = leaderboardTitleType.rawValue
    }
    
}
