//
//  ServiceNotificationType.swift
//  Airstrike
//
//  Created by Brian Nielson on 12/12/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import Foundation

class ServiceNotificationType: NSObject {
    
    static let invalidUsernameOrPassword = Notification.Name("SNInvalidUsernameOrPassword")
    
    static let userLoggedIn = Notification.Name("SNUserLoggedIn")
    
    static let paymentFailed = Notification.Name("NotificationPaymentFailed")
    
    static let allDataRefreshed = Notification.Name("SNNotificationAllDataRefreshed")
    
    static let allDataRefreshedFailed = Notification.Name("SNNotificationAllDataRefreshedFailed")
    
    static let displayLeagueChanged = Notification.Name("SNDisplayLeagueChanged")
    
    static let gameStatusChanged = Notification.Name("SNGameStatusChanged")
    
}
