//
//  GameDetailViewModel.swift
//  Airstrike
//
//  Created by Bret Smith on 1/4/17.
//  Copyright © 2017 Airstrike. All rights reserved.
//

import UIKit

class GameDetailViewModel: NSObject {
    var game: Game?
    
    fileprivate enum segmentSection: Int {
        case stats, media
    }
        
    func configureGame(newGame: Game?) {
        self.game = newGame
    }
    
    func reloadGame() {
        if let g = game {
            guard let newGame = try? DAOGame().getGame(gameId: g.id) else { return }
            game = newGame
        }
    }
    
    func gameInfo() -> [GameInfo:String] {
        var gameInfo = [GameInfo:String]()
        if let g = game {
            gameInfo[GameInfo.teamOnePoints] = String(g.pointsTeam1)
            gameInfo[GameInfo.teamTwoPoints] = String(g.pointsTeam2)
            gameInfo[GameInfo.location] = g.location
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .long
            gameInfo[GameInfo.gameStatus] = gameStatusString(gameStatus: g.gameStatus)
            gameInfo[GameInfo.time] = dateFormatter.string(from: g.dateTime)
            guard let teamOne = try? DAOTeam().getTeam(teamGuid: g.team1Id) else { return gameInfo }
            gameInfo[GameInfo.teamOneName] = teamOne?.name
            guard let teamTwo = try? DAOTeam().getTeam(teamGuid: g.team2Id) else { return gameInfo }
            gameInfo[GameInfo.teamTwoName] = teamTwo?.name
        }
        return gameInfo
    }
    
    func title() -> String {
        return "Game Details"
    }
    
    
    func getViewControllerForIndex(index: Int) -> UIViewController? {
        var newViewController: UIViewController?
        
        switch index {
        case segmentSection.stats.rawValue:
            let statsStoryboard = UIStoryboard(name: "Stats", bundle: nil)
            guard let statsTableViewController = statsStoryboard.instantiateInitialViewController() as? StatsTableViewController
                else { break }
            if let g = game {
                statsTableViewController.viewModel.initialize(player: .none, teams: .none, games: [g])
            }
            newViewController = statsTableViewController
        case segmentSection.media.rawValue:
            let mediaStoryboard = UIStoryboard(name: "Media", bundle: nil)
            guard let mediaCollectionViewController = mediaStoryboard.instantiateInitialViewController() as? MediaCollectionViewController else { break }
            mediaCollectionViewController.viewModel.initialize(player: .none, game: game, team: .none, season: .none, league: .none)
            newViewController = mediaCollectionViewController
        default:
            break
        }
        return newViewController
    }
    
    private func gameStatusString(gameStatus: GameStatus) -> String {
        var gameStatusString = "Not Started"
        switch gameStatus {
        case .final:
            gameStatusString = "Final"
        case .firstHalf:
            gameStatusString = "1st Half"
        case .halfTime:
            gameStatusString = "Half Time"
        case .secondHalf:
            gameStatusString = "2nd Half"
        default:
            gameStatusString = "Not Started"
        }
        return gameStatusString
    }

}
