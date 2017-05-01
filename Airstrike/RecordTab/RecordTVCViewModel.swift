//
//  RecordTVCViewModel.swift
//  Airstrike
//
//  Created by Bret Smith on 12/29/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

class RecordTVCViewModel: NSObject {
    
    var gamesInProgress: [Game]?
    var league: League?
    var selectedCellData: [String:String]?
    var statInfoForIndexPath: [String:String]?
    
    func initialize() {
        league = .none
        gamesInProgress = .none
        let newLeague = ServiceConnector.sharedInstance.getDisplayLeague()
        if let seasonId = newLeague?.currentSeason?.id {
            guard let newGames = try? DAOGame().getSeasonGames(seasonGuid: seasonId) else { return }
            gamesInProgress = newGames?.filter { $0.date == Calendar(identifier: .gregorian).date(bySettingHour: 0, minute: 0, second: 0, of: Date(), matchingPolicy: Calendar.MatchingPolicy.nextTime, repeatedTimePolicy: Calendar.RepeatedTimePolicy.first, direction: Calendar.SearchDirection.backward) }
            league = newLeague
        }
    }
    
    func configureLeague(league: League?) {
        self.league = league
    }
    
    func cellReuseIdentifier() -> String {
        return "gameProgress"
    }
    
    func sections() -> Int {
        return 1
    }
    
    func rows() -> Int {
        return gamesInProgress?.count ?? 0
    }
    
    func gameData(for indexPath: IndexPath) -> [String:String] {
        var gameInformation = [String:String]()
        if let teams = league?.currentSeason?.teams, let games = gamesInProgress {
            gameInformation = gameDataDictionary(games: games, teams: teams, indexPath: indexPath)
        }
        return gameInformation
    }
    
    func setSelectedCellData(for indexPath: IndexPath) {
        selectedCellData = gameData(for: indexPath)
    }
    
    func cellHeight() -> CGFloat {
        return 70
    }
    
    func infoForStat(indexPath: IndexPath) {
        var statInfo = [String:String]()
        statInfo["leagueId"] = self.league?.id
        statInfo["seasonId"] = self.league?.currentSeason?.id
        statInfo["gameId"] = self.gamesInProgress?[indexPath.item].id
        statInfo["gameStatus"] = self.gamesInProgress?[indexPath.item].gameStatus.rawValue
        
        statInfoForIndexPath = statInfo
    }
    
    private func gameDataDictionary(games: [Game], teams: [Team], indexPath: IndexPath) -> [String:String] {
        var gameInformation = [String:String]()
        gameInformation[GameInfo.teamOneName.rawValue] = teams.filter{ $0.id == games[indexPath.item].team1Id }.first?.name
        gameInformation[GameInfo.teamTwoName.rawValue] = teams.filter{ $0.id == games[indexPath.item].team2Id }.first?.name
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
    
    private func getDateWithoutTime(date: Date) -> Date {
        var date = date
        let cal = Calendar(identifier: .gregorian)
        if let dateWithoutTime = cal.date(bySettingHour: 0, minute: 0, second: 0, of: date, matchingPolicy: Calendar.MatchingPolicy.nextTime, repeatedTimePolicy: Calendar.RepeatedTimePolicy.first, direction: Calendar.SearchDirection.backward) {
            date = dateWithoutTime
        }
        return date
    }
}
