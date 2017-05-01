//
//  DAOGame.swift
//  Airstrike
//
//  Created by Jeffrey K Lewis on 12/14/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import Foundation
import SQLite

class DAOGame: NSObject {

    fileprivate static let gameTableName = "game"
    
    fileprivate let gameTable = Table(gameTableName)
    
    fileprivate let gameId = Expression<Int64>("id")
    
    fileprivate let gameGuid = Expression<String>("guid")
    
    fileprivate let teamOneGuid = Expression<String>("team_one_guid")
    
    fileprivate let teamTwoGuid = Expression<String>("team_two_guid")
    
    fileprivate let leagueGuid = Expression<String>("league_guid")
    
    fileprivate let seasonGuid = Expression<String>("season_guid")
    
    fileprivate let date = Expression<Date>("date_with_time")
    
    fileprivate let location = Expression<String>("location")
    
    fileprivate let teamOnePoints = Expression<Int>("team_one_points")
    
    fileprivate let teamTwoPoints = Expression<Int>("team_two_points")

    fileprivate let gameStatus = Expression<String>("game_status")
    
    func create() throws {
        guard let _ = try? DatabaseManager.sharedInstance.db.run( gameTable.create(ifNotExists: true) { table in
            
            table.column(gameId, primaryKey: true)
            table.column(gameGuid, unique: true)
            table.column(teamOneGuid)
            table.column(teamTwoGuid)
            table.column(leagueGuid)
            table.column(seasonGuid)
            table.column(date)
            table.column(location)
            table.column(teamOnePoints)
            table.column(teamTwoPoints)
            table.column(gameStatus)
            
        }) else { throw DatabaseError.failureToCreateTable }
    }
    
    func insertGame(leagueGuid: String, seasonGuid: String, game: Game) throws {
        guard let _ = try? DatabaseManager.sharedInstance.db.run( gameTable.insert(
            gameGuid <- game.id,
            teamOneGuid <- game.team1Id,
            teamTwoGuid <- game.team2Id,
            self.leagueGuid <- leagueGuid,
            self.seasonGuid <- seasonGuid,
            date <- game.dateTime,
            location <- game.location,
            teamOnePoints <- game.pointsTeam1,
            teamTwoPoints <- game.pointsTeam2,
            gameStatus <- game.gameStatus.rawValue
        )) else { throw DatabaseError.failureToInsertIntoTable }
        
//        guard let gameInsertions = try? DatabaseManager.sharedInstance.db.prepare("INSERT INTO game (guid, team_one_guid, team_two_guid, league_guid, season_guid, date_with_time, location, team_one_points, team_two_points, game_status) VALUES (?,?,?,?,?,?,?,?,?,?)") else { throw DatabaseError.failureToInsertIntoTable }
//        try DatabaseManager.sharedInstance.db.transaction(.deferred) { () -> Void in
//            for index in 0..<games.count {
//                try gameInsertions.run(
//                    games[index].id,
//                    games[index].team1Id,
//                    games[index].team2Id,
//                    leagueGuid,
//                    seasonGuid,
//                    games[index].dateTime,
//                    games[index].location,
//                    games[index].pointsTeam1,
//                    games[index].pointsTeam2,
//                    games[index].gameStatus.rawValue)
//            }
//        }

    }
    
    func update(leagueGuid: String, seasonGuid: String, game: Game) throws {
        let gameToUpdate = gameTable.filter(gameGuid == game.id)
        
        guard let _ = try? DatabaseManager.sharedInstance.db.run( gameToUpdate.update(
            gameGuid <- game.id,
            teamOneGuid <- game.team1Id,
            teamTwoGuid <- game.team2Id,
            self.leagueGuid <- leagueGuid,
            self.seasonGuid <- seasonGuid,
            date <- game.dateTime,
            location <- game.location,
            teamOnePoints <- game.pointsTeam1,
            teamTwoPoints <- game.pointsTeam2,
            gameStatus <- game.gameStatus.rawValue
        )) else { throw DatabaseError.failureToUpdateInTable }
    }
    
    func updateGameStatus(gameId: String, status: GameStatus) {
        let gameToUpdate = gameTable.filter(gameGuid == gameId)
        
        guard let _ = try? DatabaseManager.sharedInstance.db.run( gameToUpdate.update(
            gameStatus <- status.rawValue
        )) else { return }
    }
    
    func updateGameScore(gameId: String, teamOneScore: Int, teamTwoScore: Int) {
        let gameToUpdate = gameTable.filter(gameGuid == gameId)
        
        guard let _ = try? DatabaseManager.sharedInstance.db.run( gameToUpdate.update(
            teamOnePoints <- teamOneScore,
            teamTwoPoints <- teamTwoScore
        )) else { return }
    }
    
    func getGame(gameId: String?) throws -> Game? {
        var game: Game?
        if let gId = gameId {
            let query = gameTable.filter(self.gameGuid == gId)
            guard let dbGameOpt = try? DatabaseManager.sharedInstance.db.pluck(query) else { return .none }
            if let dbGame = dbGameOpt {
                guard let status = GameStatus(rawValue: dbGame.get(gameStatus)) else { return .none }
                game = Game(
                    id: dbGame.get(gameGuid),
                    team1Id: dbGame.get(teamOneGuid),
                    team2Id: dbGame.get(teamTwoGuid),
                    dateTime: dbGame.get(date),
                    date: getDateWithoutTime(date: dbGame.get(date)),
                    location: dbGame.get(location),
                    pointsTeam1: dbGame.get(teamOnePoints),
                    pointsTeam2: dbGame.get(teamTwoPoints),
                    gameStatus: status,
                    winningTeamId: winningTeam(teamOnePoints: dbGame.get(teamOnePoints), teamTwoPoints: dbGame.get(teamTwoPoints), team1Id: dbGame.get(teamOneGuid), team2Id: dbGame.get(teamTwoGuid)))
            }
        }
        return game
    }
    
    func getGames(leagueGuid: String?) throws -> [Game]? {
        var games = [Game]()
        if let lGuid = leagueGuid {
            let query = gameTable.filter(self.leagueGuid == lGuid)
            guard let dbGames = try? DatabaseManager.sharedInstance.db.prepare(query) else { return .none }
            for dbGame in dbGames {
                guard let status = GameStatus(rawValue: dbGame.get(gameStatus)) else { continue }
                let newGame = Game(
                    id: dbGame.get(gameGuid),
                    team1Id: dbGame.get(teamOneGuid),
                    team2Id: dbGame.get(teamTwoGuid),
                    dateTime: dbGame.get(date),
                    date: getDateWithoutTime(date: dbGame.get(date)),
                    location: dbGame.get(location),
                    pointsTeam1: dbGame.get(teamOnePoints),
                    pointsTeam2: dbGame.get(teamTwoPoints),
                    gameStatus: status,
                    winningTeamId: winningTeam(teamOnePoints: dbGame.get(teamOnePoints), teamTwoPoints: dbGame.get(teamTwoPoints), team1Id: dbGame.get(teamOneGuid), team2Id: dbGame.get(teamTwoGuid)))
                games.append(newGame)
            }
        }
        return games.count > 0 ? games : .none
    }

    func getSeasonGames(seasonGuid: String) throws -> [Game]? {
        var games = [Game]()
        let query = gameTable.filter(self.seasonGuid == seasonGuid)
        guard let dbGames = try? DatabaseManager.sharedInstance.db.prepare(query) else { return .none }
        for dbGame in dbGames {
            guard let status = GameStatus(rawValue: dbGame.get(gameStatus)) else { continue }
            let newGame = Game(
                id: dbGame.get(gameGuid),
                team1Id: dbGame.get(teamOneGuid),
                team2Id: dbGame.get(teamTwoGuid),
                dateTime: dbGame.get(date),
                date: getDateWithoutTime(date: dbGame.get(date)),
                location: dbGame.get(location),
                pointsTeam1: dbGame.get(teamOnePoints),
                pointsTeam2: dbGame.get(teamTwoPoints),
                gameStatus: status,
                winningTeamId: winningTeam(teamOnePoints: dbGame.get(teamOnePoints), teamTwoPoints: dbGame.get(teamTwoPoints), team1Id: dbGame.get(teamOneGuid), team2Id: dbGame.get(teamTwoGuid)))
            games.append(newGame)
        }
        return games.count > 0 ? games : .none
    }

    
    func getGames(teamGuid: String?) throws -> [Game]? {
        var games = [Game]()
        if let teamId = teamGuid {
            let query = gameTable.filter(teamOneGuid == teamId || teamTwoGuid == teamId)
            guard let dbGames = try? DatabaseManager.sharedInstance.db.prepare(query) else { return .none }
            for dbGame in dbGames {
                guard let status = GameStatus(rawValue: dbGame.get(gameStatus)) else { continue }
                let newGame = Game(
                    id: dbGame.get(gameGuid),
                    team1Id: dbGame.get(teamOneGuid),
                    team2Id: dbGame.get(teamTwoGuid),
                    dateTime: dbGame.get(date),
                    date: getDateWithoutTime(date: dbGame.get(date)),
                    location: dbGame.get(location),
                    pointsTeam1: dbGame.get(teamOnePoints),
                    pointsTeam2: dbGame.get(teamTwoPoints),
                    gameStatus: status,
                    winningTeamId: winningTeam(teamOnePoints: dbGame.get(teamOnePoints), teamTwoPoints: dbGame.get(teamTwoPoints), team1Id: dbGame.get(teamOneGuid), team2Id: dbGame.get(teamTwoGuid)))
                games.append(newGame)
            }
        }
        return games.count > 0 ? games : .none
    }
    
    func getAllGames() throws -> [Game]? {
        var games = [Game]()
        let query = gameTable
        guard let dbGames = try? DatabaseManager.sharedInstance.db.prepare(query) else { throw DatabaseError.failureToGetFromTable }
        for dbGame in dbGames {
            guard let status = GameStatus(rawValue: dbGame.get(gameStatus)) else { continue }
            let newGame = Game(
                id: dbGame.get(gameGuid),
                team1Id: dbGame.get(teamOneGuid),
                team2Id: dbGame.get(teamTwoGuid),
                dateTime: dbGame.get(date),
                date: getDateWithoutTime(date: dbGame.get(date)),
                location: dbGame.get(location),
                pointsTeam1: dbGame.get(teamOnePoints),
                pointsTeam2: dbGame.get(teamTwoPoints),
                gameStatus: status,
                winningTeamId: winningTeam(teamOnePoints: dbGame.get(teamOnePoints), teamTwoPoints: dbGame.get(teamTwoPoints), team1Id: dbGame.get(teamOneGuid), team2Id: dbGame.get(teamTwoGuid)))
            games.append(newGame)
        }
        return games.count > 0 ? games : .none
    }
    
    func deleteGame(_ guid: String) throws {
        let query = gameTable.filter(gameGuid == guid)
        guard let _ = try? DatabaseManager.sharedInstance.db.run(query.delete()) else { throw DatabaseError.failureToDeleteFromTable }
    }
    
    func drop() throws {
        guard let _ = try? DatabaseManager.sharedInstance.db.run(gameTable.drop(ifExists: true)) else { throw DatabaseError.failureToDropTable }
    }
    
    private func getDateWithoutTime(date: Date) -> Date {
        var date = date
        let cal = Calendar(identifier: .gregorian)
        if let dateWithoutTime = cal.date(bySettingHour: 0, minute: 0, second: 0, of: date, matchingPolicy: Calendar.MatchingPolicy.nextTime, repeatedTimePolicy: Calendar.RepeatedTimePolicy.first, direction: Calendar.SearchDirection.backward) {
            date = dateWithoutTime
        }
        return date
    }
    
    private func winningTeam(teamOnePoints: Int?, teamTwoPoints: Int?, team1Id: String, team2Id: String) -> String? {
        var winningTeam: String?
        if let t1p = teamOnePoints, let t2p = teamTwoPoints {
            if t1p > t2p {
                winningTeam = team1Id
            } else if t2p > t1p {
                winningTeam = team2Id
            }
        }
        return winningTeam
    }
    
}
