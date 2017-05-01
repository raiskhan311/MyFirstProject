//
//  TabBarController.swift
//  Airstrike
//
//  Created by Jeffrey K Lewis on 2/16/17.
//  Copyright © 2017 Airstrike. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    var removedRecordViewController: UINavigationController?
    var removedTeamManagementViewController: UINavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerNotifications()
        checkTabs()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

// MARK: Helper

extension TabBarController {
    
    fileprivate func checkTabs() {
        guard let userOpt = try? DAOUser().getUser(), let user = userOpt, let league = ServiceConnector.sharedInstance.getDisplayLeague() else { return }
        
        if (user.coordinatorLeagueIds?.contains(league.id) ?? false) || (user.playerLeagueIds?.contains(league.id) ?? false) {
            addTeamManagementTab()
            addRecordingTabIfNeeded(user: user, league: league)
        } else {
            removeRecordingTab()
            removeTeamManagementTab()
        }
    }
    
    private func addRecordingTabIfNeeded(user: User, league: League) {
        if user.coordinatorLeagueIds?.contains(league.id) ?? false {
            addRecordingTab()
        } else {
            removeRecordingTab()
        }
    }
    
    private func addRecordingTab() {
        if let r = removedRecordViewController {
            self.viewControllers?.insert(r, at: 2)
            removedRecordViewController = .none
        }
    }
    
    private func addTeamManagementTab() {
        var index = 4
        if removedRecordViewController != .none {
            index -= 1
        }
        if let r = removedTeamManagementViewController {
            self.viewControllers?.insert(r, at: index)
            removedTeamManagementViewController = .none
        }
    }
    
    private func removeRecordingTab() {
        if removedRecordViewController == .none {
            removedRecordViewController = self.viewControllers?.remove(at: 2) as? UINavigationController
        }
    }
    
    private func removeTeamManagementTab() {
        var index = 4
        if removedRecordViewController != .none {
            index -= 1
        }
        if removedTeamManagementViewController == .none {
            removedTeamManagementViewController = self.viewControllers?.remove(at: index) as? UINavigationController
        }
    }
    
}

// MARK: Notification Methods

extension TabBarController {
    
    fileprivate func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(displayLeagueChanged(notification:)), name: ServiceNotificationType.displayLeagueChanged, object: .none)
    }
    
    func displayLeagueChanged(notification: Notification) {
        checkTabs()
    }
    
}
