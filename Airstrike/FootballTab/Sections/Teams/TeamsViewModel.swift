//
//  TeamsViewModel.swift
//  Airstrike
//
//  Created by Brian Nielson on 12/19/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

class TeamsViewModel {
    var teams: [Team]?
    

    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        return teams?.count ?? 0
    }
    
    func textLabelForRow(indexPath: IndexPath) -> String {
        return teams?[indexPath.item].name ?? ""
    }
    
    func textNumbersForWinLoss(indexPath: IndexPath) -> String {
        return winLossString(team: teams?[indexPath.item])
    }
    
    func teamColor(indexPath: IndexPath) -> UIColor {
        return teams?[indexPath.item].color ?? .white
    }
    
    func cellHeight() -> CGFloat {
        return 60
    }
    
    func getTeamForCell(at indexPath: IndexPath) -> Team? {
        guard let ts = teams, ts.count > indexPath.item else { return .none }
        return ts[indexPath.item]
    }
    
    private func winLossString(team: Team?) -> String {
        var winlossString = "0-0"
        if let t = team {
            winlossString = String(t.currentSeasonWins) + "-" + String(t.currentSeasonLosses)
        }
        return winlossString
    }
    
}
