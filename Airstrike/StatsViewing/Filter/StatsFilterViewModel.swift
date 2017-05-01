//
//  StatsFilterViewModel.swift
//  Airstrike
//
//  Created by Jeffrey K Lewis on 12/23/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

class StatsFilterViewModel: NSObject {

    fileprivate var allSeasons: [Season]?
    fileprivate var seasonsToShowStatsFor: [Season]?
    fileprivate var positionToShowStatsFor = Position.quarterBack
    fileprivate var selectedPositionIndex = 0
    
    fileprivate var allTeams: [Team]?
    fileprivate var teamsToShowStatsFor: [Team]?

    func selectedPosition(indexPath: IndexPath) {
        selectedPositionIndex = indexPath.item
    }
}

// MARK: Initialization

extension StatsFilterViewModel {
    
    func initialize(allSeasons: [Season]?, seasons: [Season]?, position: Position, allTeams: [Team]?, teamsToShowStatsFor: [Team]?) {
        self.allSeasons = allSeasons
        seasonsToShowStatsFor = seasons
        positionToShowStatsFor = position
        self.allTeams = allTeams
        self.teamsToShowStatsFor = teamsToShowStatsFor
        if let selectedIndex = PositionHelperFunctions.getAllPositions().index(of: position) {
            selectedPositionIndex = selectedIndex
        }
    }
    
}

// MARK: Helper Functions

extension StatsFilterViewModel {
    
    fileprivate func seasonIsSelected(indexPath: IndexPath) -> Bool {
        var seasonSelected = false
        if let seasonForIndexPath = allSeasons?[indexPath.item], let count = seasonsToShowStatsFor?.filter({ $0.id == seasonForIndexPath.id }).count {
            if count > 0 {
                seasonSelected = true
            }
        }
        return seasonSelected
    }
    
}

// MARK: Getters

extension StatsFilterViewModel {
    
    func sections() -> Int {
        return 3
    }
    
    func getCellCountFor(section: Int) -> Int {
        var count: Int?
        if section == 0 {
            count = PositionHelperFunctions.getAllPositions().count
        } else if section == 1 {
            count = allSeasons?.count
        } else if section == 2 {
            count = allTeams?.count
        }
        
        return count ?? 0
    }
    
    func data(for indexPath: IndexPath) -> String {
        var data = ""
        switch indexPath.section {
        case 0:
            data = PositionHelperFunctions.getAllPositions()[indexPath.item].rawValue
        case 1:
            data = allSeasons?[indexPath.item].name ?? ""
        case 2:
            data = allTeams?[indexPath.item].name ?? ""
        default:break
        }
        return data
    }
    
    func currentlySelectedPositionIndex() -> Int {
        return selectedPositionIndex
    }
    
    func position() -> Position {
        return PositionHelperFunctions.getAllPositions()[currentlySelectedPositionIndex()]
    }
    
    func seasons(selectedIndexPaths: [IndexPath]?) -> [Season]? {
        var seasons = [Season]()
        if let indexPaths = selectedIndexPaths, let everySeason = allSeasons {
            indexPaths.forEach {
                if $0.section == 1 {
                    seasons.append(everySeason[$0.item])
                }
            }
        }
        return seasons.count > 0 ? seasons : .none
    }
    
    func teams(selectedIndexPaths: [IndexPath]?) -> [Team]? {
        var teams = [Team]()
        if let indexPaths = selectedIndexPaths, let everyTeam = allTeams {
            indexPaths.forEach {
                if $0.section == 2 {
                    teams.append(everyTeam[$0.item])
                }
            }
        }
        return teams.count > 0 ? teams : .none
    }
    
    func headerMessage(for section: Int) -> String {
        var message = ""
        if section == 0 {
            message = "Select the position that you would like to see the stats for."
        } else if section == 1 {
            message = "Select the date ranges of the seasons you would like to see the statistics for."
        } else if section == 2 {
            message = "Select the teams you would like to see stats for."
        }
        return message
    }
        
    func cellIsSelectedInitially(indexPath: IndexPath) -> Bool {
        var selectedInitially = false
        if indexPath.section == 0 {
            if PositionHelperFunctions.getAllPositions().index(of: positionToShowStatsFor) == indexPath.item {
                selectedInitially = true
            }
        } else if indexPath.section == 1 {
            if seasonIsSelected(indexPath: indexPath) {
                selectedInitially = true
            }
        } else if indexPath.section == 2 {
            guard let t = allTeams?[indexPath.item] else { return false }
            selectedInitially = teamsToShowStatsFor?.contains(t) ?? false
        }
        return selectedInitially
    }
    
    func doneButtonEnabled(selectedIndexPaths: [IndexPath]?) -> Bool {
        var enabled = true
        for index in 0..<sections() {
            var iterationSuccess = false
            selectedIndexPaths?.forEach {
                if $0.section == index {
                    iterationSuccess = true
                }
            }
            enabled = iterationSuccess
            if !enabled {
                break
            }
        }
        return enabled
    }
}
