//
//  ServiceConnector.swift
//  Airstrike
//
//  Created by Brian Nielson on 12/12/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit
import Stripe

class ServiceConnector: NSObject {
    
    class var sharedInstance: ServiceConnector {
        struct Singleton {
            static let instance = ServiceConnector()
        }
        return Singleton.instance
    }
    
}

// MARK: League

extension ServiceConnector {
    
    func getDisplayLeague() -> League? {
        var retLeague: League?
        
        if let currentDisplayLeague = UserDefaults.standard.object(forKey: "DISPLAY_LEAGUE") as? String, let league = try? DAOLeague().getLeague(leagueGuid: currentDisplayLeague) {
            retLeague = league
        } else if let userOpt = try? DAOUser().getUser(), let user = userOpt, let id = user.coordinatorLeagueIds?.first ?? user.playerLeagueIds?.first , let league = try? DAOLeague().getLeague(leagueGuid: id) {
            updateDisplayLeague(leagueId: id)
            retLeague = league
        } else if let allLeagues = try? DAOLeague().getAllLeagues() {
            retLeague = allLeagues?.first
        }
        return retLeague
    }
    
    func updateDisplayLeague(leagueId: String) {
        UserDefaults.standard.set(leagueId, forKey: "DISPLAY_LEAGUE")
        self.postNotification(notificationType: ServiceNotificationType.displayLeagueChanged, userInfo: .none)
    }
    
}

// MARK: Stats Cache

extension ServiceConnector {
    func uploadCachedStats() {
        if let cachedStats = try? DAOStat().getAllCachedStats() {
            cachedStats?.forEach { stat in
                if let json = stat.toJson() {
                    ServiceConnector.sharedInstance.createEvent(type: .stat, leagueId: stat.leagueId, jsonString: json, complete: { (success) in
                        if success {
                            try? DAOStat().updateUploadStatus(statId: stat.id)
                        }
                    })
                }
            }
        }
    }
}

// MARK: User

extension ServiceConnector {
    
    func isUserLoggedIn() -> Bool {
        var isLoggedIn = false
        if let user = try? DAOUser().getUser(), let _ = user {
            isLoggedIn = true
        }
        return isLoggedIn
    }
    
    func deleteKeychainData() {
        KeychainHelper.delete(Constants.userIdKey)
        KeychainHelper.delete(Constants.authTokenKey)
        KeychainHelper.delete(Constants.emailKey)
        KeychainHelper.delete(Constants.passwordKey)
    }
    
    func isLoggedIn() -> Bool {
        return KeychainHelper.get(Constants.userIdKey) != .none &&
            KeychainHelper.get(Constants.authTokenKey) != .none &&
            KeychainHelper.get(Constants.emailKey) != .none &&
            KeychainHelper.get(Constants.passwordKey) != .none
    }
    
    func logout() {
        DatabaseManager.sharedInstance.logout()
        deleteKeychainData()
        let sb = UIStoryboard(name: "OnboardingScreen", bundle: .none)
        LoginHelperFunctions.changeRootViewController(toRootOf: sb)
        UserDefaults.standard.removeObject(forKey: "DISPLAY_LEAGUE")
    }
    
    func signup(email: String, password: String, firstName: String, lastName: String, description: String?, playerNumber: String?, leagueId: String?, complete: @escaping (_ success: Bool) -> ()) {
        var body = "{\"email\": \"\(email)\", \"password\": \"\(password)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\", \"profileImage\": null"
        if let d = description, let numberString = playerNumber, let number = Int(numberString), let lId = leagueId {
            body.append(",\"leagueId\": \"\(lId)\",\"profileDescription\": \"\(fixString(d))\",\"number\": \"\(number)\"")
        }
        body.append("}")
        
        HttpUtils.makeUnsignedRequest(url: Constants.signUpURL, body: body) { (json) in
            if  let j = json,
                let r = j["response"] as? [String:Any],
                let userId = r["user_id"] as? String,
                let token = r["token"] as? String,
                let u = userId.data(using: .utf8),
                let t = token.data(using: .utf8),
                let e = email.data(using: .utf8),
                let p = password.data(using: .utf8),
                let s = j["status"] as? String,
                s == "success" {
                
                KeychainHelper.set(u, forKey: Constants.userIdKey)
                KeychainHelper.set(t, forKey: Constants.authTokenKey)
                KeychainHelper.set(e, forKey: Constants.emailKey)
                KeychainHelper.set(p, forKey: Constants.passwordKey)
                DatabaseManager.sharedInstance.createTables()
                self.parseAllData(response: r)
                complete(true)
            } else {
                print(json?["message"] as? String ?? "No message to display.")
                complete(false)
            }
            
        }
    }
    
    func login(email: String, password: String, complete: @escaping (_ success: Bool) -> ()) {
        let body = "{\"email\": \"\(email)\", \"password\": \"\(password)\"}"
        HttpUtils.makeUnsignedRequest(url: Constants.loginURL, body: body) { (json) in
            if  let j = json,
                let r = j["response"] as? [String:Any],
                let userId = r["user_id"] as? String,
                let token = r["token"] as? String,
                let u = userId.data(using: .utf8),
                let t = token.data(using: .utf8),
                let e = email.data(using: .utf8),
                let p = password.data(using: .utf8),
                let s = j["status"] as? String,
                s == "success" {
                
                KeychainHelper.set(u, forKey: Constants.userIdKey)
                KeychainHelper.set(t, forKey: Constants.authTokenKey)
                KeychainHelper.set(e, forKey: Constants.emailKey)
                KeychainHelper.set(p, forKey: Constants.passwordKey)
                DatabaseManager.sharedInstance.createTables()
                self.parseAllData(response: r)
                complete(true)
            } else {
                complete(false)
            }
        }
    }
    
    func getAllEvents() {
        HttpUtils.makeSignedPagedRequest(url: Constants.getAllEvents) { (events) in
            guard let e = events else { return }
            self.parseEvents(events: e)
        }
    }
    
    func getAllGames() {
        HttpUtils.makeSignedPagedRequest(url: Constants.getAllGames) { (games) in
            guard let g = games else { return }
            self.parseGames(gamesJSON: g)
            self.postNotification(notificationType: ServiceNotificationType.allDataRefreshed, userInfo: .none)
        }
    }
    
    func getAllFeed() {
        HttpUtils.makeSignedPagedRequest(url: Constants.getAllGames) { (feeds) in
            guard let f = feeds else { return }
            self.parseFeeds(feedsJSON: f)
        }
    }
    
    func getAllMedia() {
        HttpUtils.makeSignedPagedRequest(url: Constants.getAllMedia) { (media) in
            guard let m = media else { return }
            self.parseMedia(mediaJSON: m)
        }
    }
    
    func getAllPlayer() {
        HttpUtils.makeSignedPagedRequest(url: Constants.getAllPlayer) { (players) in
            guard let p = players else { return }
            self.parsePlayers(playersJSON: p)
        }
    }
    
    func getAllPersons() {
        HttpUtils.makeSignedPagedRequest(url: Constants.getAllPerson) { (persons) in
            guard let p = persons else { return }
            self.parsePersons(personsJSON: p)
        }
    }
    
    func getAllTeams() {
        HttpUtils.makeSignedPagedRequest(url: Constants.getAllTeam) { (teams) in
            guard let t = teams else { return }
            self.parseTeams(teamsJSON: t)
        }
    }
    
    func getAllAwards() {
        HttpUtils.makeSignedPagedRequest(url: Constants.getAllAward) { (awards) in
            guard let a = awards else { return }
            self.parseAwards(awardsJSON: a)
        }
    }
    
    func getAllSeasons() {
        HttpUtils.makeSignedPagedRequest(url: Constants.getAllSeason) { (seasons) in
            guard let s = seasons else { return }
            self.parseSeasons(seasonsJSON: s)
        }
    }
    
    func getAllLeagues() {
        HttpUtils.makeSignedPagedRequest(url: Constants.getAllLeague) { (leagues) in
            guard let l = leagues else { return }
            self.parseLeagues(leaguesJSON: l)
        }
    }
    
    func refreshData() {
        HttpUtils.makeSignedRequest(url: Constants.refreshData, body: .none) { (json) in
            if  let j = json,
                let r = j["response"] as? [String:Any],
                let s = j["status"] as? String,
                s == "success" {
                DatabaseManager.sharedInstance.reset()
                self.parseAllData(response: r)
                self.postNotification(notificationType: ServiceNotificationType.allDataRefreshed, userInfo: .none)
            } else {
                self.postNotification(notificationType: ServiceNotificationType.allDataRefreshedFailed, userInfo: .none)
            }
        }
    }
    
    func getLeagues (complete: @escaping (_ success: Bool, _ leagues: [League]?) -> ()) {
        HttpUtils.makeSignedPagedRequest(url: Constants.getAllLeague) { (leagues) in
            if let l = leagues {
                var allLeagues = [League]()
                for json in l {
                    if let id = json["_id"] as? String,
                        let name = json["name"] as? String
                    {
                        allLeagues.append(League(id: id, name: name, pastSeasons: .none, currentSeason: .none, futureSeasons: .none, teams: .none))
                    }
                }
                complete(true, allLeagues)
            } else {
                complete(false, .none)
            }
        }
    }
    
    func createEvent(type: EventType, leagueId: String, jsonString: String, complete: @escaping (_ success: Bool) -> ()) {
        let body = "{\"type\": \"\(type.rawValue)\", \"leagueId\": \"\(leagueId)\", \"jsonString\": \"\(jsonString.replacingOccurrences(of: "\"", with: "\\\""))\"}"
        HttpUtils.makeSignedRequest(url: Constants.createEvent, body: body) { (json) in
            if  let j = json,
                let s = j["status"] as? String,
                let _ = j["response"]?["version"] as? Int,
                s == "success" {
                complete(true)
            } else if let j = json,
                let code = j["statusCode"] as? Int,
                let message = j["message"] as? String {
                complete(false)
                print("Return Code: " + String(code))
                print("Message: " + message)
            } else {
                complete(false)
            }
        }
    }
    
    func addTeam(name: String, color: String, managerId: String, leagueId: String, playerId: String) {
        let body = "{\"name\": \"\(name)\", \"leagueId\": \"\(leagueId)\", \"color\": \"\(color)\", \"managerId\": \"\(managerId)\", \"playerId\": \"\(playerId)\"}"
        HttpUtils.makeSignedRequest(url: Constants.addTeam, body: body) { (json) in
            if let j = json,
            let response = j["response"] as? [String:Any] {
                if let team = response["team"] as? [String:Any] {
                    self.parseTeams(teamsJSON: [team])
                }
                if let player = response["player"] as? [String:Any] {
                    self.updatePlayer(playerJson: player)
                }
            }
            if let j = json, let message = j["message"] as? String {
                print(message)
            }

            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "teamAdded"), object: .none)
        }
    }
    
    func addPlayerToTeam(teamId: String, playerId: String) {
        let body = "{\"teamId\": \"\(teamId)\", \"playerId\": \"\(playerId)\"}"
        HttpUtils.makeSignedRequest(url: Constants.addPlayerToTeam, body: body) { (json) in
            if let j = json,
                let response = j["response"] as? [String:Any],
                let player = response["player"] as? [String:Any] {
                self.updatePlayer(playerJson: player)
            }
        }
    }
    
    func addPlayerToLeague(leagueId: String, personId: String, playerNumber: Int, complete: @escaping (_ success: Bool, _ id: String) -> ()) {
        let body = "{\"leagueId\": \"\(leagueId)\", \"personId\": \"\(personId)\", \"number\": \(playerNumber)}"
        HttpUtils.makeSignedRequest(url: Constants.addPlayerToLeague, body: body) { (json) in
            if let j = json,
                let response = j["response"] as? [String:Any],
                let playerId = response["playerId"] as? String,
                let user = try? DAOUser().getUser(), let u = user,
                let person = u.person {

                var arr = [leagueId]
                if let pli = u.playerLeagueIds {
                    arr.append(contentsOf: pli)
                }
                try? DAOUser().update(userId: u.id, userRole: u.role, personGuid: person.id, coordinatorLeagueIds: u.coordinatorLeagueIds, playerLeagueIds: arr)
                let newPlayer = Player(id: playerId, leagueId: leagueId, teamId: .none, personId: person.id, number: 1, awards: .none)
                try? DAOPlayer().insertPlayer(player: newPlayer)
                var newPlayers = [newPlayer]
                if let otherPlayers = person.players {
                    newPlayers.append(contentsOf: otherPlayers)
                }
                let newPerson = Person(id: person.id, firstName: person.firstName, lastName: person.lastName, profileImagePath: person.profileImagePath, profileDescription: person.profileDescription, players: newPlayers)
                try? DAOPerson().update(newPerson)
                ServiceConnector.sharedInstance.updateDisplayLeague(leagueId: leagueId)
                complete(true, playerId)
            } else {
                complete(false, "")
            }
        }
    }
    
    func addMedia(mediaToken: String, creationDate: Date, leagueId: String, mappingId: String, complete: @escaping (_ success: Bool, _ id: String) -> ()) {
        let body = "{\"mediaToken\":\"\(mediaToken)\", \"recordedDate\":\"\(creationDate.iso8601)\", \"leagueId\":\"\(leagueId)\", \"mappingId\":\"\(mappingId)\"}"
        HttpUtils.makeSignedRequest(url: Constants.addMedia, body: body) { (json) in
            if let j = json,
                let r = j["response"] as? [String:Any],
                let mediaId = r["mediaId"] as? String {
                complete(true, mediaId)
            } else {
                complete(false, "")
            }
        }
        
        
    }
    
    func removePlayerFromTeam(playerId: String) {
        let body = "{\"playerId\": \"\(playerId)\"}"
        HttpUtils.makeSignedRequest(url: Constants.removePlayerFromTeam, body: body) { (json) in
            if let j = json,
                let response = j["response"] as? [String:Any],
                let player = response["player"] as? [String:Any] {
                self.updatePlayer(playerJson: player)
            }
        }
    }
    
    func uploadImage(image: UIImage, person: Person?) {
        if let p = person {
            let filename = "profile_" + p.id
            HttpUtils.postImage(url: Constants.uploadPhoto, filename: filename, image: image) { (imagePath) in
                if let iP = imagePath {
                    self.updateProfileImagePath(imagePath: iP, person: p)
                }
            }
        }
    }
    
    private func updateProfileImagePath(imagePath: String, person: Person) {
        let body = "{\"imagePath\": \"\("http:" + imagePath)\", \"personId\": \"\(person.id)\"}"
        HttpUtils.makeSignedRequest(url: Constants.updateProfileImagePath, body: body) { (json) in
            if let j = json,
                let response = j["response"] as? [String:Any],
                let personDict = response["person"] as? [String:Any] {
                self.updatePerson(personJson: personDict, players: person.players)
            }
        }
    }
    
    func updateProfile(firstName: String?, lastName: String?, profileDescription: String?, number: Int?, personId: String, playerId: String?, complete: @escaping (_ success: Bool) -> ()) {
        
        var body = "{"
        if let fName = firstName, let lName = lastName {
            body.append("\"firstName\": \"\(fName)\", \"lastName\": \"\(lName)\",")
        }
        if let num = number, let pId = playerId {
            body.append("\"number\": \(num),\"playerId\": \"\(pId)\",")
        }
        if let pDesc = profileDescription {
            body.append("\"profileDescription\": \"\(pDesc)\",")
        }
        body.append("\"personId\": \"\(personId)\"")
        body.append("}")
        HttpUtils.makeSignedRequest(url: Constants.updateProfile, body: body) { (json) in
            if let j = json,
            let _ = j["response"] as? [String:Any] {
                complete(true)
            } else {
                complete(false)
            }
        }
    }
    
    func updateTeamRecords(team1Id: String, team2Id: String, winningTeamId: String, complete: @escaping (_ success: Bool) -> ()) {
        let body = "{\"team1Id\": \"\(team1Id)\",\"team2Id\": \"\(team2Id)\",\"winningTeamId\": \"\(winningTeamId)\"}"
        HttpUtils.makeSignedRequest(url: Constants.updateTeamRecords, body: body) { (json) in
            if  let j = json,
                let s = j["status"] as? String,
                s == "success" {
                complete(true)
            } else {
                complete(false)
            }
        }
    }
}

// MARK: Payment

extension ServiceConnector {
    
    func submitPaymentTokenToBackend(_ token: STPToken, amount: Int, leagueId: String, userId: String, complete: @escaping (_ success: Bool, _ errorMessage: String?) -> ()) {
        let body = "{\"amount\": \(amount), \"token\": \"\(String(describing: token))\", \"leagueId\": \"\(leagueId)\", \"userId\": \"\(userId)\"}"
        HttpUtils.makeUnsignedRequest(url: Constants.stripeURL, body: body) { (json) in
            complete(json?["success"] as? Bool ?? false, json?["message"] as? String)
        }
    }
    
}

// MARK: Game

extension ServiceConnector {
    
    func updateGameStatus(gameId: String, status: GameStatus, complete: @escaping (_ success: Bool) -> ()) {
        let body = "{\"gameId\": \"\(gameId)\", \"status\": \"\(status.rawValue)\"}"
        HttpUtils.makeSignedRequest(url: Constants.updateGameStatus, body: body) { (json) in
            if let success = json?["status"] as? String, success == "success" {
                DAOGame().updateGameStatus(gameId: gameId, status: status)
                complete(true)
            } else {
                complete(false)
            }
        }
    }
    
    func updateGameScore(gameId: String, teamOneScore: Int, teamTwoScore: Int, complete: @escaping (_ success: Bool) -> ()) {
        let body = "{\"gameId\": \"\(gameId)\", \"teamOneScore\": \(teamOneScore), \"teamTwoScore\": \(teamTwoScore)}"
        HttpUtils.makeSignedRequest(url: Constants.updateGameScore, body: body) { (json) in
            if let success = json?["status"] as? String, success == "success" {
                DAOGame().updateGameScore(gameId: gameId, teamOneScore: teamOneScore, teamTwoScore: teamTwoScore)
                complete(true)
            } else {
                complete(false)
            }
        }
    }

    
}

// MARK: Helper Functions

extension ServiceConnector {
    
    fileprivate func updatePerson(personJson: [String:Any], players: [Player]?) {
        if let id = personJson["_id"] as? String,
            let firstName = personJson["firstName"] as? String,
            let lastName = personJson["lastName"] as? String {
            try? DAOPerson().update(Person(id: id, firstName: firstName, lastName: lastName, profileImagePath: personJson["profileImagePath"] as? String, profileDescription: personJson["profileDescription"] as? String, players: players))
        }
    }
    
    fileprivate func updatePlayer(playerJson: [String:Any]) {
        if let id = playerJson["_id"] as? String,
            let leagueId = playerJson["league"] as? String,
            let personId = playerJson["person"] as? String,
            let number = playerJson["number"] as? Int {
            try? DAOPlayer().update(Player(id: id, leagueId: leagueId, teamId: playerJson["team"] as? String, personId: personId, number: number, awards: .none))
        }
    }
    
    fileprivate func parseAllData(response: [String:Any]) {
        
        let dispatchGroup = DispatchGroup()
        
        do {
            dispatchGroup.enter()
            HttpUtils.makeSignedPagedRequest(url: Constants.getAllEvents) { (events) in
                if let e = events {
                    self.parseEvents(events: e)
                }
                dispatchGroup.leave()
            }
        }
        
        do {
            dispatchGroup.enter()
            HttpUtils.makeSignedPagedRequest(url: Constants.getAllGames) { (games) in
                if let g = games {
                    self.parseGames(gamesJSON: g)
                }
                dispatchGroup.leave()
            }
        }
        
        do {
            dispatchGroup.enter()
            HttpUtils.makeSignedPagedRequest(url: Constants.getAllGames) { (feeds) in
                if let f = feeds {
                    self.parseFeeds(feedsJSON: f)
                }
                dispatchGroup.leave()
            }
        }
        
        do {
            dispatchGroup.enter()
            HttpUtils.makeSignedPagedRequest(url: Constants.getAllMedia) { (media) in
                if let m = media {
                    self.parseMedia(mediaJSON: m)
                }
                dispatchGroup.leave()
            }
        }
        
        do {
            dispatchGroup.enter()
            HttpUtils.makeSignedPagedRequest(url: Constants.getAllPlayer) { (players) in
                if let p = players {
                    self.parsePlayers(playersJSON: p)
                }
                dispatchGroup.leave()
            }
        }
        
        do {
            dispatchGroup.enter()
            HttpUtils.makeSignedPagedRequest(url: Constants.getAllPerson) { (persons) in
                if let p = persons {
                    self.parsePersons(personsJSON: p)
                }
                dispatchGroup.leave()
            }
        }
        
        do {
            dispatchGroup.enter()
            HttpUtils.makeSignedPagedRequest(url: Constants.getAllTeam) { (teams) in
                if let t = teams {
                    self.parseTeams(teamsJSON: t)
                }
                dispatchGroup.leave()
            }
        }
        
        do {
            dispatchGroup.enter()
            HttpUtils.makeSignedPagedRequest(url: Constants.getAllAward) { (awards) in
                if let a = awards {
                    self.parseAwards(awardsJSON: a)
                }
                dispatchGroup.leave()
            }
        }
        
        do {
            dispatchGroup.enter()
            HttpUtils.makeSignedPagedRequest(url: Constants.getAllSeason) { (seasons) in
                if let s = seasons {
                    self.parseSeasons(seasonsJSON: s)
                }
                dispatchGroup.leave()
            }
        }
        
        do {
            dispatchGroup.enter()
            HttpUtils.makeSignedPagedRequest(url: Constants.getAllLeague) { (leagues) in
                if let l = leagues {
                    self.parseLeagues(leaguesJSON: l)
                }
                dispatchGroup.leave()
            }
        }
        
        if let user = response["user"] as? [String:Any] {
            parseUser(userJSON: user)
        }
        
        dispatchGroup.wait()
    }
    
    fileprivate func parseEvents(events: [[String: Any]]) {
        var stats = [Stat]()
        for event in events {
            if let jsonString = event["jsonString"] as? String, let data = jsonString.data(using: .utf8) {
                guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else { continue }
                if let stat = parseStats(json: json) {
                    stats.append(stat)
                }
            }
        }
        if stats.count > 0 {
            try? DAOStat().insertStats(stats: stats)
        }
    }
    
    fileprivate func parseStats(json: [String:Any]?) -> Stat? {
        var stat: Stat?
        if let j = json,
            let id = j["id"] as? String,
            let typeString = j["type"] as? String,
            let value = j["value"] as? Double,
            let timeOfGameString = j["timeOfGame"] as? String,
            let playerId = j["playerId"] as? String,
            let teamId = j["teamId"] as? String,
            let gameId = j["gameId"] as? String,
            let seasonId = j["seasonId"] as? String,
            let leagueId = j["leagueId"] as? String,
            let positionString = j["position"] as? String,
            let type = StatType(rawValue: typeString),
            let timeOfGame = GameStatus(rawValue: timeOfGameString),
            let position = Position(rawValue: positionString) {
            stat = Stat(id: id, type: type, value: value, timeOfGame: timeOfGame, playerId: playerId, teamId: teamId, gameId: gameId, seasonId: seasonId, leagueId: leagueId, mediaId: j["mediaId"] as? String, position: position)
        }
        return stat
    }
    
    fileprivate func parseAwards(awardsJSON: [[String:Any]]) {
        for j in awardsJSON {
            if let id = j["_id"] as? String,
                let title = j["title"] as? String,
                let timeSince1970 = j["date"] as? Double,
                let playerId = j["player"] as? String {
                try? DAOAward().insert(playerId, award: Award(id: id, title: title, date: Date(timeIntervalSince1970: TimeInterval(timeSince1970/1000))))
            }
        }
    }
    
    fileprivate func parseLeagues(leaguesJSON: [[String:Any]]) {
        for json in leaguesJSON {
            if let id = json["_id"] as? String,
                let name = json["name"] as? String
            {
                try? DAOLeague().insert(league: League(id: id, name: name, pastSeasons: .none, currentSeason: .none, futureSeasons: .none, teams: .none))
            }
        }
    }
    
    fileprivate func parseLeagueNames(leaguesJSON: [[String:Any]]) -> [League]? {
        var leagues = [League]()
        for json in leaguesJSON {
            if let id = json["_id"] as? String,
                let name = json["name"] as? String
            {
                leagues.append(League(id: id, name: name, pastSeasons: .none, currentSeason: .none, futureSeasons: .none, teams: .none))
            }
        }
        return leagues.count > 0 ? leagues : .none
    }
    
    fileprivate func parseTeams(teamsJSON: [[String:Any]]) {
        for json in teamsJSON {
            if let id = json["_id"] as? String,
                let name = json["name"] as? String,
                let colorString = json["color"] as? String,
                let currentSeasonLosses = json["currentSeasonLosses"] as? Int,
                let currentSeasonWins = json["currentSeasonWins"] as? Int,
                let leagueId = json["league"] as? String,
                let managerId = json["manager"] as? String
            {
                try? DAOTeam().insert(team: Team(id: id, name: name, color: UIColor.init(hexString: colorString), pastGames: .none, currentGame: .none, futureGames: .none, currentSeasonWins: currentSeasonWins, currentSeasonLosses: currentSeasonLosses, leagueGuid: leagueId, managerGuid: managerId, persons: .none))
            }
        }
    }
    
    fileprivate func parsePlayers(playersJSON: [[String:Any]]) {
        for j in playersJSON {
            if let id = j["_id"] as? String,
                let leagueId = j["league"] as? String,
                let personId = j["person"] as? String,
                let number = j["number"] as? Int {
                    try? DAOPlayer().insertPlayer(player: Player(id: id, leagueId: leagueId, teamId: j["team"] as? String, personId: personId, number: number, awards: .none))
            }
        }
    }
    
    fileprivate func parsePersons(personsJSON: [[String:Any]]) {
        var persons = [Person]()
        for j in personsJSON {
            if let id = j["_id"] as? String,
                let firstName = j["firstName"] as? String,
                let lastName = j["lastName"] as? String {
                persons.append(Person(id: id, firstName: firstName, lastName: lastName, profileImagePath: j["profileImagePath"] as? String, profileDescription: j["profileDescription"] as? String, players: .none))
            }
        }
        try? DAOPerson().insert(persons: persons)
    }
    
    fileprivate func parseSeasons(seasonsJSON: [[String:Any]]) {
        for j in seasonsJSON {
            if let id = j["_id"] as? String,
                let name = j["name"] as? String,
                let startDateSince1970 = j["startDate"] as? Double,
                let endDateSince1970 = j["endDate"] as? Double,
                let leagueGuid = j["league"] as? String {
                let startDate = Date(timeIntervalSince1970: TimeInterval(startDateSince1970/1000))
                let endDate = Date(timeIntervalSince1970: TimeInterval(endDateSince1970/1000))
                try? DAOSeason().insert(leagueGuid: leagueGuid, season: Season(id: id, name: name, startDate: startDate, endDate: endDate, postSeasonStartDate: j["postSeasonStartDate"] as? Date, postSeasonEndDate: j["postSeasonEndDate"] as? Date, teams: .none, regularSeasonGames: .none, postSeasonGames: .none))
            }
        }
    }
    
    fileprivate func parseGames(gamesJSON: [[String:Any]]) {
        for j in gamesJSON {
            if let id = j["_id"] as? String,
                let team1Id = j["team1"] as? String,
                let team2Id = j["team2"] as? String,
                let timeSince1970 = j["date"] as? Double,
                let location = j["location"] as? String,
                let pointsTeam1 = j["pointsTeam1"] as? Int,
                let pointsTeam2 = j["pointsTeam2"] as? Int,
                let gameStatusString = j["status"] as? String,
                let gameStatus = GameStatus(rawValue: gameStatusString),
                let leagueId = j["league"] as? String,
                let seasonId = j["season"] as? String {
                
                try? DAOGame().insertGame(leagueGuid: leagueId, seasonGuid: seasonId, game: Game(id: id, team1Id: team1Id, team2Id: team2Id, dateTime: Date(timeIntervalSince1970: TimeInterval(timeSince1970/1000)), date: Date(timeIntervalSince1970: TimeInterval(timeSince1970/1000)), location: location, pointsTeam1: pointsTeam1, pointsTeam2: pointsTeam2, gameStatus: gameStatus, winningTeamId: .none))
            }
        }
    }
    
    fileprivate func parseMedia(mediaJSON: [[String:Any]]) {
        for j in mediaJSON {
            guard let id = j["_id"] as? String, let typeString = j["Type"] as? String, let type = MediaType(rawValue: typeString), let mediaToken = j["Token"] as? String, let createdNum = j["Created Date"] as? Int, let mappingId = j["mappingId"] as? String else { continue }
            let m = Media(id: id, type: type, mediaToken: mediaToken, creationDate: Date(timeIntervalSince1970: TimeInterval(createdNum/1000)))
            try? DAOMedia().insert(m, mappingId: mappingId)
        }
    }
    
    fileprivate func parseFeeds(feedsJSON: [[String: Any]]) {
        for j in feedsJSON {
            guard let id = j["_id"] as? String, let description = j["Description"] as? String, let mediaId = j["MediaId"] as? String, let createdDateNumber = j["Created Date"] as? Int, let leagueId = j["League"] as? String else { continue }
            let feed = Feed(id: id, creationDate: Date(timeIntervalSince1970: TimeInterval(createdDateNumber/1000)), title: description, mediaType: MediaType.video, mediaId: mediaId, leagueId: leagueId)
            try? DAOFeed().insert(feed)
        }
    }
    
    fileprivate func parseUser(userJSON: [String:Any]) {
        if let id = userJSON["_id"] as? String,
            let roleString = userJSON["role"] as? String,
            let role = Role(rawValue: roleString) {
            try? DAOUser().insertUser(
                userId: id,
                userRole: role,
                personGuid: userJSON["person"] as? String,
                coordinatorLeagueIds: userJSON["coordinatorLeagueIds"] as? [String],
                playerLeagueIds: userJSON["playerLeagueIds"] as? [String]
            )
        }
    }
    
    fileprivate func postNotification (notificationType: Notification.Name, userInfo: [String: Any]?) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: notificationType, object: self, userInfo: userInfo)
        }
    }
    
    fileprivate func fixString(_ string: String) -> String {
        return string.replacingOccurrences(of: "\"", with: "\\\"").replacingOccurrences(of: "\\", with: "\\\\")
    }
    
}
