//
//  EditProfileViewModel.swift
//  Airstrike
//
//  Created by BoHuang on 3/27/17.
//  Copyright © 2017 Airstrike. All rights reserved.
//

import Foundation

import UIKit

class EditProfileViewModel: NSObject {
    
    var person: Person?
    fileprivate var team: Team?
    fileprivate var league: League?
    fileprivate var userisPerson = true
    fileprivate var seasons: [Season]?
    fileprivate enum segmentSection: Int {
        case stats, media, awards
    }
    
    fileprivate var statsVc: StatsTableViewController?
    fileprivate var mediaVc: MediaCollectionViewController?
    fileprivate var awardsVc: AwardsTableViewController?
    
    func configurePerson(person: Person) {
        self.person = person
        userisPerson = false
        setupData()
    }
    
    func configureUser() {
        if person == .none || userisPerson {
            if let p = try? DAOUser().getPersonForUser() {
                self.person = p
                setupData()
            }
        }
    }
    
}

// MARK: Helper Methods

extension EditProfileViewModel {
    
    func setupData() {
        self.seasons = .none
        self.team = .none
        var seasons = [Season]()
        if let l = ServiceConnector.sharedInstance.getDisplayLeague() {
            league = l
            if let currentSeason = l.currentSeason {
                l.pastSeasons?.forEach { seasons.append($0) }
                seasons.append(currentSeason)
                l.futureSeasons?.forEach { seasons.append($0) }
            }
        }
        if let teamId = person?.players?.filter({$0.leagueId == league?.id}).first?.teamId, let teamOpt = try? DAOTeam().getTeam(teamGuid: teamId) {
            self.team = teamOpt
        }
        self.seasons = seasons
    }
    
    func reloadContainerView() {
        var teams: [Team]?
        if let tId = person?.players?.filter({$0.leagueId == league?.id}).first?.teamId, let tOpt = try? DAOTeam().getTeam(teamGuid: tId), let t = tOpt {
            teams = [t]
        }
        let thisPlayer = person?.players?.filter({$0.leagueId == league?.id}).first
        statsVc?.viewModel.initialize(player: thisPlayer, teams: teams, games: .none, notAPlayer: thisPlayer == .none)
        statsVc?.tableView?.reloadData()
        mediaVc?.viewModel.initialize(player: person?.players?.filter({$0.leagueId == league?.id}).first, game: .none, team: .none, season: .none, league: .none)
        mediaVc?.collectionView?.reloadData()
        awardsVc?.player = person?.players?.filter({$0.leagueId == league?.id}).first
        awardsVc?.tableView.reloadData()
    }
    
    func personIsPlayerInDisplayLeague() -> Bool {
        var personIsInLeage = false
        if let person = person, let _ = person.players?.filter({$0.leagueId == league?.id}).first {
            personIsInLeage = true
        }
        return personIsInLeage
    }
    
}

// MARK: Getters

extension EditProfileViewModel {
    
    func getAccentColor() -> UIColor {
        return team?.color ?? .black
    }
    
    func getPlayerImageURL() -> String? {
        var imageURL: String?
        if let url = person?.profileImagePath {
            imageURL = url
        }
        return imageURL
    }
    
    
    func getDisplayName() -> String {
        var displayName = ""
        if let person = person, let player = person.players?.filter({$0.leagueId == league?.id}).first {
            displayName = "#" + String(player.number) + " " + person.firstName + " " + person.lastName
        } else if let person = person {
            displayName = person.firstName + " " + person.lastName
        }
        return displayName
    }
    
    func getSubtitleText() -> String {
        var subtitleText = ""
        if personIsPlayerInDisplayLeague() {
            subtitleText += team?.name ?? "No Assigned Team"
            if let l = league?.name {
                subtitleText += " |" + " " + l
            }
        } else {
            if let l = league?.name {
                subtitleText = "Not a player in " + l
            }
        }
        return subtitleText
    }
    
    func getDescriptionText() -> String {
        return person?.profileDescription ?? ""
    }
    
    func userIsPerson() -> Bool {
        return self.userisPerson
    }
    
    func firstName() -> String? {
        return person?.firstName
    }
    
    func lastName() -> String? {
        return person?.lastName
    }
    
    func playerNumber() -> String? {
        var numberString: String?
        if let person = person, let player = person.players?.filter({$0.leagueId == league?.id}).first {
            numberString = String(player.number)
        }
        return numberString
    }
}
