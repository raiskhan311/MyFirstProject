//
//  FootballViewModel.swift
//  Airstrike
//
//  Created by Jeffrey K Lewis on 12/2/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

class FootballViewModel: NSObject {
    
    private enum segmentSection: Int {
        case feed, scores, leaderboards, teams
    }
    
    func getViewControllerForIndex(index: Int) -> UIViewController? {
        var newViewController: UIViewController?
        
        
        switch index {
        case segmentSection.feed.rawValue:
            let feedStoryboard = UIStoryboard(name: "FeedSection", bundle: nil)
            guard let feedCollectionViewController = feedStoryboard.instantiateInitialViewController() as? FeedCollectionViewController else { break }
            newViewController = feedCollectionViewController
        case segmentSection.scores.rawValue:
            let scoreStoryboard = UIStoryboard(name: "ScoresSection", bundle: nil)
            guard let scoreTableViewController = scoreStoryboard.instantiateInitialViewController() as? ScoresTableViewController else { break }
            scoreTableViewController.viewModel.initializeSeason()
            newViewController = scoreTableViewController
        case segmentSection.leaderboards.rawValue:
            let leaderboardsStoryboard = UIStoryboard(name: "LeaderboardsSection", bundle: nil)
            guard let leaderboardsTableViewController = leaderboardsStoryboard.instantiateInitialViewController() as? LeaderboardsTableViewController else { break }
            leaderboardsTableViewController.viewModel.league = ServiceConnector.sharedInstance.getDisplayLeague()
            newViewController = leaderboardsTableViewController
        case segmentSection.teams.rawValue:
            let teamsStoryboard = UIStoryboard(name: "TeamsSection", bundle: nil)
            guard let teamsTableViewController = teamsStoryboard.instantiateInitialViewController() as? TeamsTableViewController else { break }
            teamsTableViewController.league = ServiceConnector.sharedInstance.getDisplayLeague()
            newViewController = teamsTableViewController
        default:
            break
        }
        return newViewController
    }
    
    func shouldShowSignUpButton() -> Bool {
        guard let u = try? DAOUser().getUser() else { return true }
        return u == .none
    }
    
}
