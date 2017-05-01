//
//  Constants.swift
//  Airstrike
//
//  Created by Bret Smith on 1/24/17.
//  Copyright © 2017 Airstrike. All rights reserved.
//

import UIKit

class Constants: NSObject {

    // MARK: URLs
    
    //static let baseURLPOST = "https://airstrike.bubbleapps.io/version-test/api/1.0/wf/"
    static let baseURLPOST = "https://airstrike.bubbleapps.io/version-live/api/1.0/wf/"
    
    //static let baseURLGET = "https://airstrike.bubbleapps.io/version-test/api/1.0/obj/"
    static let baseURLGET = "https://airstrike.bubbleapps.io/version-live/api/1.0/obj/"
    static let loginURL = baseURLPOST + "login"
    
    static let signUpURL = baseURLPOST + "signup"
    
    static let createEvent = baseURLPOST + "event"
    
    static let refreshData = baseURLPOST + "refresh-data"
        
    static let addTeam = baseURLPOST + "add-team"
    
    static let addPlayerToLeague = baseURLPOST + "add-player-to-league"
    
    static let addMedia = baseURLPOST + "add-media"
    
    static let addPlayerToTeam = baseURLPOST + "add-player-to-team"
    
    static let removePlayerFromTeam = baseURLPOST + "remove-player-from-team"
    
    static let updateProfile = baseURLPOST + "update-profile"
    
    static let updateGameStatus = baseURLPOST + "update-game-status"
    
    static let updateGameScore = baseURLPOST + "update-game-score"
    
    static let updateProfileImagePath = baseURLPOST + "update-profile-image"
    
    static let updateTeamRecords = baseURLPOST + "update-team-records"
    
    //static let uploadPhoto = "https://airstrike.bubbleapps.io/version-test/fileupload"
    static let uploadPhoto = "https://airstrike.bubbleapps.io/version-live/fileupload"
    
    static let getAllEvents = baseURLGET + "event"
    
    static let getAllGames = baseURLGET + "game"
    
    static let getAllFeed = baseURLGET + "feed"
    
    static let getAllMedia = baseURLGET + "media"
    
    static let getAllPlayer = baseURLGET + "player"
    
    static let getAllPerson = baseURLGET + "person"
    
    static let getAllTeam = baseURLGET + "team"
    
    static let getAllAward = baseURLGET + "award"
    
    static let getAllSeason = baseURLGET + "season"
    
    static let getAllLeague = baseURLGET + "league"

    // MARK: Keys
    
    static let emailKey = "EMAIL"
    
    static let passwordKey = "PASSWORD"
    
    static let userIdKey = "USERID"
    
    static let authTokenKey = "AUTHTOKEN"
    
    // MARK: Ziggeo
    
    static let ziggeoToken = "aeb484a19cf4ffbfec51a8327cf1cac0"
    
    // MARK: Stripe
    
    static let stripeKey = "pk_test_ELvItNV5x2acDM9yNo8qZeSv"
    
//    static let stripeKey = "pk_live_toOHIo9TeuXeGGX7qBMtn3iO"
    
    // Change to port 9913 for PRODUCTION
   // static let stripeURL = "http://54.161.141.69:9912/charge"
    static let stripeURL = "http://54.161.141.69:9913/charge"

    
}
