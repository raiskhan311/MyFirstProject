//
//  SignUpLeagueChooserViewModel.swift
//  Airstrike
//
//  Created by Bret Smith on 2/14/17.
//  Copyright © 2017 Airstrike. All rights reserved.
//

import UIKit

class SignUpLeagueChooserViewModel: NSObject {
    var leagues: [League]?
    var selectedLeagueId = "No League Id"
    
    func initialize(leagues: [League]?) {
        if let l = leagues {
            self.leagues = l
        } else {
            guard let dbLeagues = try? DAOLeague().getAllLeagues() else { return }
            self.leagues = dbLeagues
        }
    }
}

// MARK: TableView Information

extension SignUpLeagueChooserViewModel {
    func sections() -> Int {
        return 1
    }
    
    func rows() -> Int {
        return leagues?.count ?? 0
    }
    
    func reuseIdentifier() -> String {
        return "genericCell"
    }
    
    func data(for indexPath: IndexPath) -> String {
        return leagues?[indexPath.item].name ?? "No League Name"
    }
    
    func cellHeight() -> CGFloat {
        return 60
    }
    
    func rowSelected(at indexPath: IndexPath) {
        selectedLeagueId = leagues?[indexPath.item].id ?? "No League Id"
    }
    
    func headerReuseIdentifier() -> String {
        return "genericHeaderCell"
    }
    
    func headerText() -> String {
        return "Select the league you will be playing in."
    }
    
    func heightForHeader() -> CGFloat {
        return 60
    }

}
