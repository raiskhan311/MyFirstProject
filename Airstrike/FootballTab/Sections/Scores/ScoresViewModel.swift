//
//  ScoresViewModel.swift
//  Airstrike
//
//  Created by Bret Smith on 12/7/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

class ScoresViewModel: NSObject {
    var season: Season?
    private(set) var numberOfSections = 0
    private var pastGameDates: [Date]?
    private var pastGames: [Game]?
    private var gamesInProgress = false
    private let dateFormatter = DateFormatter()
    var selectedGame: Game?
    
    func initializeSeason() {
        season = ServiceConnector.sharedInstance.getDisplayLeague()?.currentSeason
        configureSeason()
    }
    
    
    private func configureSeason() {
        if let s = season {
            self.season = s
            var games = s.regularSeasonGames ?? [Game]()
            s.postSeasonGames?.forEach { games.append($0) }
            configurePastGameDates(games: games)
        }
    }
    
    func configureTeam(team: Team?) {
        guard let gamesOpt = try? DAOGame().getGames(teamGuid: team?.id) else { return }
        if let games = gamesOpt {
            configurePastGameDates(games: games)
        }
    }
    
    
    func sections() -> Int {
        var sections = pastGameDates?.count ?? 1
        if let gamesInProgressCount = pastGames?.filter({ $0.gameStatus != .final }).count {
            if sections > 0 && gamesInProgressCount > 0 {
                gamesInProgress = true
                sections += 1
            }
        }
        return sections
    }
    
    func rows(for section: Int) -> Int {
        var rows = 0
        if gamesInProgress {
            if section == 0 {
                rows = pastGames?.filter { $0.gameStatus != .final }.count ?? 0
            } else if section > 0 {
                rows = pastGames?.filter { $0.date == pastGameDates?[section - 1] && $0.gameStatus == .final }.count ?? 0
            }
        } else {
            if let pastGameCount = pastGames?.filter ({ $0.date == pastGameDates?[section] && $0.gameStatus == .final }).count, pastGameCount > 0 {
                rows = pastGameCount
            } else {
                rows = 1
            }
        }
        return rows
    }
    
    func gameData(for indexPath: IndexPath) -> [String:String] {
        var section = indexPath.section
        var gameInformation = [String:String]()
        if gamesInProgress && indexPath.section == 0 {
            if let games = pastGames?.filter({ $0.gameStatus != .final }) {
                gameInformation = gameDataDictionary(games: games, indexPath: indexPath)
            }
        } else {
            if gamesInProgress && indexPath.section > 0 { section -= 1 }
            let date = pastGameDates?[section]
            if let games = pastGames?.filter({ $0.date == date && $0.gameStatus == .final}) {
                gameInformation = gameDataDictionary(games: games, indexPath: indexPath)
            }
        }
        return gameInformation
    }
    
    func isRowGameCell() -> Bool {
        var isGameCell = false
        if let pg = pastGames, pg.count > 0 {
            isGameCell = true
        }
        return isGameCell
    }
    
    func gameSelected(at indexPath:IndexPath) {
        var games: [Game]?
        var section = indexPath.section
        if gamesInProgress && indexPath.section > 0 {
            section -= 1
        }
            
        if gamesInProgress && indexPath.section == 0 {
            games = pastGames?.filter { $0.gameStatus != .final }
        } else {
            let date = pastGameDates?[section]
            games = pastGames?.filter { $0.date == date && $0.gameStatus == .final }
        }
        selectedGame = games?[indexPath.item]
    }
    
    func headerText (for section: Int) -> String {
        var headerText = ""
        dateFormatter.dateFormat = "EEEE, MMM. d"
        if gamesInProgress {
            if section == 0 {
                headerText = "In Progress"
            } else {
                if let pastDate = pastGameDates?[section - 1] {
                    headerText = dateFormatter.string(from: pastDate)
                }
            }
        } else {
            if let pastDate = pastGameDates?[section] {
                headerText = dateFormatter.string(from: pastDate)
            }
        }
        return headerText
    }
    
    func cellReuseIdentifier() -> String {
        if let pg = pastGames, pg.count > 0 {
            return "gameProgress"
        } else {
            return "noPastGames"
        }
    }
    
    func headerReuseIdentifier() -> String {
        return "scoreHeader"
    }
    
    func headerHeight() -> CGFloat {
        return 40
    }
    
    func cellHeight() -> CGFloat {
        return 70
    }
    
    private func configurePastGameDates(games: [Game]) {
        var setOfDates: Set<Date> = Set()
        pastGames = games.filter { $0.gameStatus != .notStarted }
        pastGames?.forEach {
            if $0.gameStatus == .final {
                setOfDates.insert($0.date)
            }
        }
        pastGameDates = Array(setOfDates).sorted(by: >).count > 0 ? Array(setOfDates).sorted(by: >) : .none
    }
    
    private func gameDataDictionary(games: [Game], indexPath: IndexPath) -> [String:String] {
        var gameInformation = [String:String]()
        if let teamOneName = try? DAOTeam().getTeam(teamGuid: games[indexPath.item].team1Id)?.name {
            gameInformation[GameInfo.teamOneName.rawValue] = teamOneName
        }
        if let teamTwoName = try? DAOTeam().getTeam(teamGuid: games[indexPath.item].team2Id)?.name {
            gameInformation[GameInfo.teamTwoName.rawValue] = teamTwoName
        }
        gameInformation[GameInfo.teamOnePoints.rawValue] = teamPointsString(teamPoints: games[indexPath.item].pointsTeam1)
        gameInformation[GameInfo.teamTwoPoints.rawValue] = teamPointsString(teamPoints: games[indexPath.item].pointsTeam2)
        gameInformation[GameInfo.gameStatus.rawValue] = games[indexPath.item].gameStatus.rawValue
        return gameInformation
    
    
    }
    
    private func teamPointsString(teamPoints: Int?) -> String {
        var teamPointsString = "0"
        if let tPoints = teamPoints {
            teamPointsString = String(tPoints)
        }
        return teamPointsString
    }
}
