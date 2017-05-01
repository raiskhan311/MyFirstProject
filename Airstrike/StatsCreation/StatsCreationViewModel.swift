//
//  StatsCreationViewModel.swift
//  Airstrike
//
//  Created by Bret Smith on 12/29/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

class StatsCreationViewModel: NSObject {
    
    // MARK: - Stat Creation Information
    var quarterback: Person?
    var wideReceiver: Person?
    var defensiveback: Person?
    var yardsGained: Double?
    var previousQuarterback: Person?
    let gameId: String
    let seasonId: String
    let leagueId: String
    var mediaId: String?
    let gameStatus: GameStatus
    
    init(gameId: String, seasonId: String, leagueId: String, mediaId: String?, gameStatus: GameStatus, previousStatInfo: [Position:Person]?) {
        self.gameId = gameId
        self.seasonId = seasonId
        self.leagueId = leagueId
        self.gameStatus = gameStatus
        self.mediaId = mediaId
        guard let game = try? DAOGame().getGame(gameId: gameId) else { return }
        guard let team1 = try? DAOTeam().getTeam(teamGuid: game?.team1Id) else { return }
        self.team1 = team1
        self.selectedTeam = team1
        guard let team2 = try? DAOTeam().getTeam(teamGuid: game?.team2Id) else { return }
        self.team2 = team2
        self.previousQuarterback = previousStatInfo?[.quarterBack]
    }
    
    
    func yardsGained(yards: Double) {
        self.yardsGained = yards
    }
    
    func createStats() -> [Stat] {
        var stats = [Stat]()
        if let play = playType {
            if let qBack = quarterback?.players?.filter({$0.leagueId == self.leagueId}).first {
                quarterbackStats(for: play, qBack: qBack).forEach { stats.append($0) }
            }
            if let wReceiver = wideReceiver?.players?.filter({$0.leagueId == self.leagueId}).first {
                wideReceiverStats(for: play, wReceiver: wReceiver).forEach { stats.append($0) }
            }
            if let dBack = defensiveback?.players?.filter({$0.leagueId == self.leagueId}).first {
                defensiveBackStats(for: play, dBack: dBack).forEach { stats.append($0) }
            }
        }
        if let mId = mediaId {
            createMediaIdMappings(mediaId: mId)
        }
        return stats
    }
    
    private func createMediaIdMappings(mediaId: String) {
        var mappings = [(mediaGuid: String, idType: IdType, typeGuid: String)]()
        mappings.append((mediaGuid: mediaId, idType: IdType.game, typeGuid: gameId))
        mappings.append((mediaGuid: mediaId, idType: IdType.season, typeGuid: seasonId))
        mappings.append((mediaGuid: mediaId, idType: IdType.league, typeGuid: leagueId))
        
        if let qBack = quarterback, let league = ServiceConnector.sharedInstance.getDisplayLeague(), let player = qBack.players?.filter({ $0.leagueId == league.id }).first {
            mappings.append((mediaGuid: mediaId, idType: IdType.player, typeGuid: player.id))
            if let one = team1, qBack.players?.filter({$0.leagueId == self.leagueId}).first?.teamId == one.id {
                mappings.append((mediaGuid: mediaId, idType: IdType.team, typeGuid: one.id))
            } else if let two = team2, qBack.players?.filter({$0.leagueId == self.leagueId}).first?.teamId == two.id {
                mappings.append((mediaGuid: mediaId, idType: IdType.team, typeGuid: two.id))
            }
        }
        if let wReceiver = wideReceiver, let league = ServiceConnector.sharedInstance.getDisplayLeague(), let player = wReceiver.players?.filter({ $0.leagueId == league.id }).first {
            mappings.append((mediaGuid: mediaId, idType: IdType.player, typeGuid: player.id))
        }
        if let dBack = defensiveback, let league = ServiceConnector.sharedInstance.getDisplayLeague(), let player = dBack.players?.filter({ $0.leagueId == league.id }).first {
            mappings.append((mediaGuid: mediaId, idType: IdType.player, typeGuid: player.id))
            if let one = team1, dBack.players?.filter({$0.leagueId == self.leagueId}).first?.teamId == one.id {
                mappings.append((mediaGuid: mediaId, idType: IdType.team, typeGuid: one.id))
            } else if let two = team2, dBack.players?.filter({$0.leagueId == self.leagueId}).first?.teamId == two.id {
                mappings.append((mediaGuid: mediaId, idType: IdType.team, typeGuid: two.id))
            }
        }
        try? DAOMediaMapping().insert(mappings: mappings)
    }
    
    private func quarterbackStats(for play: PlayType, qBack: Player) -> [Stat] {
        var stats = [Stat]()
        if play == .passCompleted || play == .touchdown {
            stats.append(createStat(statType: .passCompletion, value: 1, playerId: qBack.id, teamId: qBack.teamId ?? "", position: .quarterBack))
            stats.append(createStat(statType: .yards, value: yardsGained ?? 0, playerId: qBack.id, teamId: qBack.teamId ?? "", position: .quarterBack))
            if play == .touchdown {
                stats.append(createStat(statType: .touchdown, value: 1, playerId: qBack.id, teamId: qBack.teamId ?? "", position: .quarterBack))
            }
        } else if play == .interception || play == .pickSix {
            stats.append(createStat(statType: .interception, value: 1, playerId: qBack.id, teamId: qBack.teamId ?? "", position: .quarterBack))
        } else if play == .sack {
            stats.append(createStat(statType: .sack, value: 1, playerId: qBack.id, teamId: qBack.teamId ?? "", position: .quarterBack))
        }
        if play != .sack {
            stats.append(createStat(statType: .attempt, value: 1, playerId: qBack.id, teamId: qBack.teamId ?? "", position: .quarterBack))
        }
        return stats
    }
    
    private func wideReceiverStats(for play: PlayType, wReceiver: Player) -> [Stat] {
        var stats = [Stat]()
        if play == .passCompleted || play == .touchdown {
            stats.append(createStat(statType: .passReception, value: 1, playerId: wReceiver.id, teamId: wReceiver.teamId ?? "", position: .wideReceiver))
            stats.append(createStat(statType: .yards, value: yardsGained ?? 0, playerId: wReceiver.id, teamId: wReceiver.teamId ?? "", position: .wideReceiver))
            if play == .touchdown {
                stats.append(createStat(statType: .touchdown, value: 1, playerId: wReceiver.id, teamId: wReceiver.teamId ?? "", position: .wideReceiver))
            }
        } else if play == .passFailed {
            stats.append(createStat(statType: .drop, value: 1, playerId: wReceiver.id, teamId: wReceiver.teamId ?? "", position: .wideReceiver))
        }
        return stats
    }
    
    private func defensiveBackStats(for play: PlayType, dBack: Player) -> [Stat] {
        var stats = [Stat]()
        if play == .passFailed {
            stats.append(createStat(statType: .knockdown, value: 1, playerId: dBack.id, teamId: dBack.teamId ?? "", position: .defensiveBack))
        } else if play == .interception || play == .pickSix {
            stats.append(createStat(statType: .interception, value: 1, playerId: dBack.id, teamId: dBack.teamId ?? "", position: .defensiveBack))
            if play == .pickSix {
                stats.append(createStat(statType: .pick6, value: 1, playerId: dBack.id, teamId: dBack.teamId ?? "", position: .defensiveBack))
            }
        }
        return stats
    }
    
    private func createStat(statType: StatType, value: Double, playerId: String, teamId: String, position: Position) -> Stat {
        return Stat(id: UUID().uuidString, type: statType, value: value, timeOfGame: self.gameStatus, playerId: playerId, teamId: teamId, gameId: self.gameId, seasonId: self.seasonId, leagueId: self.leagueId, mediaId: self.mediaId, position: position)
    }
    
    fileprivate func addPlayer(screenType: ScreenType, person: Person) {
        switch screenType {
        case .quarterback:
            quarterback = person
        case .wideReceiver:
            wideReceiver = person
        case .defensiveBack:
            defensiveback = person
        default:break
        }
    }
    
    fileprivate func removePlayer(screenType: ScreenType) {
        switch screenType {
        case .quarterback:
            quarterback = .none
        case .wideReceiver:
            wideReceiver = .none
        case .defensiveBack:
            defensiveback = .none
        default:break
        }
    }
    
    func getPreviousStatInfo() -> [Position: Person]? {
        var previousInfo = [Position:Person]()
        if let qBack = quarterback {
            previousInfo[.quarterBack] = qBack
            print("Quarterback - " + qBack.fullName())
        } else {
            print("Quarterback - No Quarterback Found")
        }
        if let wReceiver = wideReceiver {
            previousInfo[.wideReceiver] = wReceiver
            print("Wide Receiver - " + wReceiver.fullName())
        } else {
            print("Wide Receiver - No Wide Receiver Found")
        }
        if let dBack = defensiveback {
            previousInfo[.defensiveBack] = dBack
            print("Defensiveback - " + dBack.fullName())
        } else {
            print("Defensiveback - No Defensiveback Found")
        }
        if let mId = mediaId {
            print("Media Id: " + mId)
        } else {
            print("Media Id: None")
        }
        print("---------------------------------------------")
        return previousInfo
    }
    
    
    // MARK: - TableViewInformation
    fileprivate var screens: [ScreenType]?
    fileprivate var playType: PlayType?
    var screenIndex = 0
    var selectedTeam: Team?
    var isTeamOne = true
    var team1: Team?
    var team2: Team?
}


// MARK: - TableView Management

extension StatsCreationViewModel {
    func sections() -> Int {
        var count = 1
        if let currentScreen = screens?[screenIndex], let play = playType {
            switch currentScreen {
            case .quarterback:
                if let qBack = previousQuarterback, let playerCount = selectedTeam?.persons?.filter({ $0.id == qBack.id}).count, playerCount > 0 && qBack.players?.filter({$0.leagueId == self.leagueId}).first?.teamId == selectedTeam?.id {
                    count = 2
                } else {
                    count = 1
                }
            case .wideReceiver, .defensiveBack:
                if play == .passCompleted {
                    count = 1
                } else if play == .passFailed {
                    count = 2
                }
            case .yards:
                count = 1
            }
        }
        return count
    }
    
    func rows(for section: Int) -> Int {
        var count = 0
        if let currentScreen = screens?[screenIndex], let play = playType {
            if (play == .passFailed && section == 0 && (currentScreen == .wideReceiver || currentScreen == .defensiveBack)) || currentScreen == .yards {
                count = 1
            } else if let teamPersons = selectedTeam?.persons {
                if currentScreen == .quarterback {
                    if let qBack = previousQuarterback, let playerCount = selectedTeam?.persons?.filter({ $0.id == qBack.id}).count, playerCount > 0 && section == 0 {
                        count = 1
                    } else if let qBack = previousQuarterback, let teamCount = selectedTeam?.persons?.filter({ $0.id != qBack.id }).count {
                        count = teamCount
                    } else {
                        count = teamPersons.count
                    }
                } else {
                    count = teamPersons.count
                    if selectedTeam?.id == quarterback?.players?.filter({$0.leagueId == self.leagueId}).first?.teamId && count > 0 {
                        count -= 1
                    }
                }
            }
        } else {
            count = PlayType.allPlayTypes().count
        }
        return count
    }
    
    func data(for indexPath: IndexPath) -> String {
        var data = ""
        if let currentScreen = screens?[screenIndex], let play = playType {
            
            switch currentScreen {
            case .quarterback:
                if let previousQBack = previousQuarterback, selectedTeam?.id == previousQuarterback?.players?.filter({$0.leagueId == self.leagueId}).first?.teamId {
                    if let player = previousQBack.players?.filter({$0.leagueId == self.leagueId}).first, indexPath.section == 0 {
                        data = "#" + String(player.number) + " " + previousQBack.fullName()
                    } else {
                        if let teamPerson = selectedTeam?.persons?.filter({ $0.id != previousQBack.id })[indexPath.item], let player = teamPerson.players?.filter({$0.leagueId == self.leagueId}).first {
                            data = "#" + String(player.number) + " " + teamPerson.fullName()
                        }
                    }
                } else if let teamPerson = selectedTeam?.persons?[indexPath.item], let player = teamPerson.players?.filter({$0.leagueId == self.leagueId}).first {
                    data = "#" + String(player.number) + " " + teamPerson.fullName()
                }
            case .wideReceiver:
                if indexPath.section == 0 && play == .passFailed {
                    data = "None"
                } else if let teamPerson = selectedTeam?.persons?.filter({ $0.id != quarterback?.id })[indexPath.item], let player = teamPerson.players?.filter({$0.leagueId == self.leagueId}).first {
                    data = "#" + String(player.number) + " " + teamPerson.fullName()
                }
            case .defensiveBack:
                if indexPath.section == 0 && play == .passFailed {
                    data = "None"
                } else if let teamPerson = selectedTeam?.persons?[indexPath.item], let player = teamPerson.players?.filter({$0.leagueId == self.leagueId}).first {
                    data = "#" + String(player.number) + " " + teamPerson.fullName()
                }
            default:break
            }
        } else {
            data = PlayType.allPlayTypes()[indexPath.item].rawValue
        }
        return data
    }
    
    func reuseIdentifier() -> String {
        var reuseIdentifier = "genericCell"
        if let currentPage = screens?[screenIndex] {
            if currentPage == .yards {
                reuseIdentifier = "numberInputCell"
            } else {
                reuseIdentifier = "genericCell"
            }
        }
        return reuseIdentifier
    }
    
    func headerReuseIdentifier() -> String {
        return "genericHeaderCell"
    }
    
    func rowSelected(indexPath: IndexPath) {
        if let currentScreen = screens?[screenIndex], let play = playType, let teamPersons = selectedTeam?.persons {
            switch currentScreen {
            case .quarterback:
                if let qBack = previousQuarterback, currentScreen == .quarterback && selectedTeam?.id == qBack.players?.filter({$0.leagueId == self.leagueId}).first?.teamId {
                    if indexPath.section == 0 {
                        addPlayer(screenType: currentScreen, person: qBack)
                    } else if let teamPerson = selectedTeam?.persons?.filter({ $0.id != qBack.id})[indexPath.item] {
                        addPlayer(screenType: currentScreen, person: teamPerson)
                    }
                } else {
                    addPlayer(screenType: currentScreen, person: teamPersons[indexPath.item])
                }
            case .wideReceiver, .defensiveBack:
                if play == .passFailed {
                    if indexPath.section == 0 {
                        removePlayer(screenType: currentScreen)
                    } else if indexPath.section == 1 {
                        addPlayer(screenType: currentScreen, person: teamPersons.filter({ $0.id != quarterback?.id })[indexPath.item])
                    }
                } else if play != .passFailed {
                    addPlayer(screenType: currentScreen, person: teamPersons.filter({ $0.id != quarterback?.id })[indexPath.item])
                }
            default:break
            }
            screenIndex += 1
        } else {
            screens = PlayType.screens(for: PlayType.allPlayTypes()[indexPath.item])
            playType = PlayType.allPlayTypes()[indexPath.item]
        }
    }
    
    func yardsAdded(yards: Double) {
        yardsGained(yards: yards)
        screenIndex += 1
    }
    
    func rowIsSelectable(indexPath: IndexPath) -> Bool {
        var isSelectable = true
        if let currentScreen = screens?[screenIndex] {
            if currentScreen == .yards {
                isSelectable = false
            }
        }
        return isSelectable
    }
    
    func message() -> String {
        var message = ""
        if let currentScreen = screens?[screenIndex], let play = playType {
            message = PresentationMessages.message(for: currentScreen, playType: play)
        }
        return message
    }
    
    func title() -> String {
        var title = "Play Type"
        if let currentScreen = screens?[screenIndex] {
            title = currentScreen.rawValue
        }
        return title
    }
    
    func headerText() -> String {
        var headerMessage = ""
        if let currentScreen = screens?[screenIndex], let play = playType {
            headerMessage = PresentationMessages.message(for: currentScreen, playType: play)
        } else {
            headerMessage = PresentationMessages.playTypeDescription.rawValue
        }
        return headerMessage
    }
    
    func heightForHeader(for section: Int, screenSize: CGSize) -> CGFloat {
        var height: CGFloat = 100
        if screenSize.width > screenSize.height {
            height = 50
        }
        if section == 1 {
            height = 20
        }
        return height
    }
    
    func height(forRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func pageBack() {
        if screenIndex > 0 {
            screenIndex -= 1
        } else {
            playType = .none
            screens = .none
        }
    }
    
    func segmentChanged(selectedSegment: Int) {        
        if selectedSegment == 0 {
            selectedTeam = team1
            isTeamOne = true
        } else if selectedSegment == 1 {
            selectedTeam = team2
            isTeamOne = false
        }
    }
    
    func hideSegentedController() -> Bool {
        var shouldHide = true
        if let currentScreen = screens?[screenIndex] {
            if currentScreen == .quarterback {
                shouldHide = false
            }
        }
        return shouldHide
    }
    
    func segmentToDisplay() -> Int {
        var segment = 0
        var qBack = previousQuarterback
        if let currentScreen = screens?[screenIndex] {
            if let newQBack = quarterback {
                qBack = newQBack
            }
            
            if let qBackTeamId = qBack?.players?.filter({$0.leagueId == self.leagueId}).first?.teamId, qBackTeamId == team1?.id {
                if currentScreen == .wideReceiver || currentScreen == .quarterback {
                    segment = 0
                } else if currentScreen == .defensiveBack {
                    segment = 1
                }
            } else if let qBackTeamId = qBack?.players?.filter({$0.leagueId == self.leagueId}).first?.teamId, qBackTeamId == team2?.id {
                if currentScreen == .wideReceiver || currentScreen == .quarterback {
                    segment = 1
                } else if currentScreen == .defensiveBack {
                    segment = 0
                }
            }

        }
        segmentChanged(selectedSegment: segment)
        return segment
    }
    
    func showBackButton() -> Bool {
        guard let _ = screens else { return false }
        return true
    }
    
    private func summaryData(indexPath: IndexPath) -> String {
        var summaryDataString = ""
        if let currentScreen = screens?[indexPath.item] {
            switch currentScreen {
            case .quarterback:
                if let qBack = quarterback, let player = qBack.players?.filter({$0.leagueId == self.leagueId}).first {
                    summaryDataString = "Quarterback - #" + String(player.number) +  " " + qBack.fullName()
                }
            case .wideReceiver:
                if let wReceiver = wideReceiver, let player = wideReceiver?.players?.filter({$0.leagueId == self.leagueId}).first {
                    summaryDataString = "Wide Receiver - #" + String(player.number) +  " " + wReceiver.fullName()
                } else {
                    summaryDataString = "Wide Receiver - None"
                }
            case .defensiveBack:
                if let dBack = defensiveback, let player = dBack.players?.filter({$0.leagueId == self.leagueId}).first {
                    summaryDataString = "Defensive Back - #" + String(player.number) +  " " + dBack.fullName()
                } else {
                    summaryDataString = "Defensive Back - None"
                }
            case .yards:
                if let yards = yardsGained {
                    summaryDataString = String(Int(yards)) + " Yards Gained"
                }
            }
        }
        return summaryDataString
    }
    
    func statCreationFinished() -> Bool {
        var isFinished = false
        if screenIndex == screens?.count {
            isFinished = true
        }
        return isFinished
    }

}

// MARK: - Private Enums for Stats pages

private enum PlayType: String {
    case passCompleted = "Pass Completed", passFailed = "Incomplete Pass", sack = "Sack", interception = "Interception", pickSix = "Pick-6", touchdown = "Touchdown"
    
    static func allPlayTypes() -> [PlayType] {
        return [.passCompleted, .passFailed, .sack, .interception, .pickSix, .touchdown]
    }
    
    static func screens(for playtype: PlayType) -> [ScreenType] {
        var screens = [ScreenType]()
        switch playtype {
        case .touchdown, .passCompleted:
            screens = [.quarterback, .wideReceiver, .yards]
        case .passFailed:
            screens = [.quarterback, .wideReceiver, .defensiveBack]
        case .interception, .pickSix:
            screens = [.quarterback, .defensiveBack]
        case .sack:
            screens = [.quarterback]
        }
        return screens
    }
}

private enum ScreenType: String {
    case quarterback = "Quarterback", wideReceiver = "Wide Receiver", defensiveBack = "Defensive Back", yards = "Yards"
}

private enum PresentationMessages: String {
    case quarterback = "Who was the QUARTERBACK on this play?"
    case receiver = "Who was the WIDE RECEIVER on this play?"
    case yards = "How many YARDS were gained on this play?"
    case failedReceiver = "Which WIDE RECEIVER dropped the ball, if any?"
    case defensiveBack = "Which DEFENSIVE BACK knocked the ball down, if any?"
    case defensiveInterception = "Which DEFENSIVE BACK intercepted the pass?"
    case playTypeDescription = "Please select the RESULT of the play."
    
    static func message(for screenType: ScreenType, playType: PlayType) -> String {
        var presentationMessage = ""
        switch screenType {
        case .yards:
            presentationMessage = PresentationMessages.yards.rawValue
        case .wideReceiver:
            if playType == .passCompleted || playType == .touchdown {
                presentationMessage = PresentationMessages.receiver.rawValue
            } else if playType == .passFailed {
                presentationMessage = PresentationMessages.failedReceiver.rawValue
            }
        case .defensiveBack:
            if playType == .passFailed {
                presentationMessage = PresentationMessages.defensiveBack.rawValue
            } else if playType == .interception || playType == .pickSix {
                presentationMessage = PresentationMessages.defensiveInterception.rawValue
            }
        case .quarterback:
            presentationMessage = PresentationMessages.quarterback.rawValue
        }
        return presentationMessage
    }
}

