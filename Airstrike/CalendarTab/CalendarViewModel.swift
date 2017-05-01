//
//  CalendarViewModel.swift
//  Airstrike
//
//  Created by Jeffrey K Lewis on 12/2/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit
import CVCalendar

class CalendarViewModel: NSObject {
    var games: [Game]?
    var gamesOfVisibleMonth: [Game]?
    var selectedDate = Date()
    var currentMonth = Date()
    var isFirstDayOfMonth = false
    
    override init() {
        if let league = ServiceConnector.sharedInstance.getDisplayLeague(), let gamesFromDAO = try? DAOGame().getGames(leagueGuid: league.id) {
            games = gamesFromDAO
        }
    }
    
    func initialize() {
        if let league = ServiceConnector.sharedInstance.getDisplayLeague(), let gamesFromDAO = try? DAOGame().getGames(leagueGuid: league.id) {
            games = gamesFromDAO
        }
        monthChanged(currentMonth)
    }
    
    func configureGamesForInitialMonth() {
        monthChanged(Date())
    }
    
    
    func shouldShowDotMarkerOn(dayView: DayView) -> Bool {
        var gameIsOnSelectedDate = false
        if let date = dayView.date.convertedDate(calendar: Calendar.current) {
            games?.forEach {
                let order = Calendar.current.compare($0.dateTime, to: date, toGranularity: .day)
                if order == ComparisonResult.orderedSame {
                    gameIsOnSelectedDate = true
                }
            }
        }
        return gameIsOnSelectedDate
    }
    
    func monthChanged(_ date: Date) {
        var gamesOfNewMonth = [Game]()
        isFirstDayOfMonth = true
        games?.forEach {
            let order = Calendar.current.compare($0.dateTime, to: date, toGranularity: .month)
            if order == ComparisonResult.orderedSame {
                gamesOfNewMonth.append($0)
            }
        }
        gamesOfVisibleMonth = gamesOfNewMonth
    }
    
    func gamesForSelectedDate(_ date: Date) -> [Game]? {
        var gamesForSelectedMonth = gamesOfVisibleMonth
        if isFirstDayOfMonth {
            gamesForSelectedMonth = games
            isFirstDayOfMonth = false
        }
        return gamesForSelectedMonth?.filter {
            let order = Calendar.current.compare($0.dateTime, to: date, toGranularity: .day)
            if order == ComparisonResult.orderedSame {
                return true
            }
            return false
        }
    }
}
