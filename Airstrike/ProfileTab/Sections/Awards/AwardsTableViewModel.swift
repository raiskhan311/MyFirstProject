//
//  AwardsTableViewModel.swift
//  Airstrike
//
//  Created by Brian Nielson on 12/30/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

class AwardsTableViewModel: NSObject {
    fileprivate var player: Player?
    fileprivate let dateFormatter = DateFormatter()
}

// MARK: - Initialization

extension AwardsTableViewModel {
    func initialize(player: Player?) {
        self.player = player
        dateFormatter.dateStyle = .short
    }
}


// MARK: - Getters

extension AwardsTableViewModel {
    
    func getNumberOfRows() -> Int {
        var numberOfAwards = 0
        if let awardCount = player?.awards?.count {
            numberOfAwards = awardCount
        }
        
        return numberOfAwards
    }
    
    func getRowHeight() -> CGFloat {
        return 60
    }
    
    func getAwardNameForCell(at indexPath: IndexPath) -> String {
        guard let awards = player?.awards, awards.count > indexPath.item else { return "" }
        return awards[indexPath.item].title
    }
    
    func getDateForCell(at indexPath: IndexPath) -> String {
        guard let awards = player?.awards, awards.count > indexPath.item else { return "" }
        return dateFormatter.string(from: awards[indexPath.item].date)
    }
    
}
