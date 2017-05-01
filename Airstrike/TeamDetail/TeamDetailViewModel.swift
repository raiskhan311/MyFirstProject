//
//  TeamDetailViewModel.swift
//  Airstrike
//
//  Created by Jeffrey K Lewis on 12/22/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

class TeamDetailViewModel: NSObject {
    
    fileprivate var team: Team?

    fileprivate enum segmentSection: Int {
        case schedule, stats, media, roster
    }
    
    func initialize(team: Team?) {
        self.team = team
    }
    
}

// MARK: Getters

extension TeamDetailViewModel {
    
    func getTeamColor() -> UIColor {
        return team?.color ?? .black
    }
    
    func getTeamName() -> String {
        return team?.name ?? ""
    }
    
    func getWinLoss() -> String {
        let winlossString = winLossString()
        return winlossString
    }
    
    private func winLossString() -> String {
        var winlossString = "0-0"
        if let t = team {
            winlossString = String(t.currentSeasonWins) + "-" + String(t.currentSeasonLosses)
        }
        return winlossString
    }
    
    func getViewControllerForIndex(index: Int) -> UIViewController? {
        var newViewController: UIViewController?
        
        switch index {
        case segmentSection.schedule.rawValue:
            let scoreStoryboard = UIStoryboard(name: "ScoresSection", bundle: nil)
            guard let scoreTableViewController = scoreStoryboard.instantiateInitialViewController() as? ScoresTableViewController else { break }
            scoreTableViewController.viewModel.configureTeam(team: team)
            newViewController = scoreTableViewController
        case segmentSection.roster.rawValue:
            let rosterStoryboard = UIStoryboard(name: "RosterSection", bundle: nil)
            guard let rosterTableViewController = rosterStoryboard.instantiateInitialViewController() as? RosterTableViewController
                else { break }
            rosterTableViewController.team = team
            newViewController = rosterTableViewController
        
        case segmentSection.media.rawValue:
            let mediaStoryboard = UIStoryboard(name: "Media", bundle: nil)
            guard let mediaCollectionViewController = mediaStoryboard.instantiateInitialViewController() as? MediaCollectionViewController else { break }
            mediaCollectionViewController.viewModel.initialize(player: .none, game: .none, team: team, season: .none, league: .none)
            newViewController = mediaCollectionViewController
        case segmentSection.stats.rawValue:
            let statsStoryboard = UIStoryboard(name: "Stats", bundle: nil)
            guard let statsTableViewController = statsStoryboard.instantiateInitialViewController() as? StatsTableViewController
                else { break }
            if let t = team {
                statsTableViewController.viewModel.initialize(player: .none, teams: [t], games: .none)
            }
            newViewController = statsTableViewController
        
        default:
            break
        }
        return newViewController
    }
}
