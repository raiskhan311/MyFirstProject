//
//  LeaderboardDetailsViewModel.swift
//  Airstrike
//
//  Created by Bret Smith on 12/28/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

class LeaderboardDetailsViewModel: NSObject {
    private var statisticType: StatType?
    private var persons: [Person]?
    private var position: Position?
    private var leaderboardData: [(Person, Int)]?
    private var stats: [Stat]?
    private var leagueId = "No league Id"
    
    override init() {
        guard let newPersons = try? DAOPerson().getAllPersons() else { return }
        persons = newPersons
        leagueId = ServiceConnector.sharedInstance.getDisplayLeague()?.id ?? "No league Id"
    }
    
    func statisticType(statType: StatType?) {
        statisticType = statType
    }
    
    func positionType(position: Position?) {
        self.position = position
    }
    
    func statsForTeam(teamId: String) {
        persons = persons?.filter { $0.players?.filter({$0.leagueId == self.leagueId}).first?.teamId == teamId }
        if let statType = statisticType {
            guard let newStats = try? DAOStat().getAllStatsOfTypeForTeam(statType: statType, teamId: teamId) else { return }
            stats = newStats?.filter { $0.position == position }
            configureLeaderboardData()
        }
    }
    
    func statsForLeague(leagueId: String) {
        let personsInLeague = persons?.filter {
            var isInLeague = false
            $0.players?.forEach { player in
                if player.leagueId == leagueId {
                    isInLeague = true
                }
            }
            return isInLeague
        }
        persons = personsInLeague
        if let statType = statisticType {
            guard let newStats = try? DAOStat().getAllStatsOfTypeForLeague(statType: statType, leagueId: leagueId) else { return }
            stats = newStats?.filter { $0.position == position }
            configureLeaderboardData()
        }
    }
    func cellHeight() -> CGFloat {
        return 60
    }
    
    func reuseIdentifier() -> String {
        return "leaderboardDetailsCell"
    }
    
    func sections() -> Int {
        return 1
    }
    
    func rows() -> Int {
        var count = 0
        if let lbd = leaderboardData {
            count = lbd.count
        }
        return count
    }
    
    func data(for indexPath: IndexPath) -> [String:String] {
        var data = [String:String]()
        
        if let leaderData = leaderboardData {
            let person = leaderData[indexPath.item].0
            data[LeaderboardInfo.playerName.rawValue] = person.fullName()
            data[LeaderboardInfo.imagePath.rawValue] = person.profileImagePath
            data[LeaderboardInfo.ranking.rawValue] = String(indexPath.item + 1)
            data[LeaderboardInfo.statValue.rawValue] = String(leaderData[indexPath.item].1)
            if let teamName = try? DAOTeam().getTeam(teamGuid: person.players?.filter({$0.leagueId == self.leagueId}).first?.teamId)?.name {
                data[LeaderboardInfo.teamName.rawValue] = teamName
            }
        }
        return data
    }
    
    func getPerson(for indexPath: IndexPath) -> Person? {
        guard let lbd = leaderboardData else { return .none }
        return lbd[indexPath.item].0
    }
    
    private func configureLeaderboardData() {
        var personStats = [(Person, Int)]()
        persons?.forEach { person in
            let personStatistics = stats?.filter { stat in
                stat.playerId == person.players?.filter({$0.leagueId == self.leagueId}).first?.id
            }
            var personStatsValue: Double = 0
            personStatistics?.forEach { personStatsValue += $0.value }
            
            personStats.append((person, Int(personStatsValue)))
        }
        
        leaderboardData = personStats.sorted { $0.1 > $1.1 }
    }
}
