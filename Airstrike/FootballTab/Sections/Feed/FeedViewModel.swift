//
//  FeedViewModel.swift
//  Airstrike
//
//  Created by Jeffrey K Lewis on 12/2/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

class FeedViewModel {
    
    var feedPosts: [Feed]?
    
    let dateFormatter = DateFormatter()
    
    func initialize() {
        dateFormatter.dateStyle = .short
        guard let league = ServiceConnector.sharedInstance.getDisplayLeague(), let feedPosts = try? DAOFeed().getAllWithLeagueId(league.id) else { return }
        self.feedPosts = feedPosts?.sorted(by: { $0.creationDate > $1.creationDate })
    }

    func sections() -> Int {
        return 1
    }
    
    func cells(for section: Int) -> Int {
        return feedPosts?.count ?? 0
    }
    
    func reuseIdentifier() -> String {
        return "feedCell"
    }
    
    func cellData(for indexPath: IndexPath) -> [String:Any] {
        var feedInformation = [String: Any]()
        guard let f = feedPosts, f.count > indexPath.item else { return feedInformation }
        feedInformation["feedImage"] = f[indexPath.item].mediaId
        feedInformation["feedContent"] = f[indexPath.item].title
        feedInformation["timeStamp"] = dateFormatter.string(from: f[indexPath.item].creationDate)
        return feedInformation
    }
    
    func videoToken(for indexPath: IndexPath) -> String? {
        guard let f = feedPosts, f.count > indexPath.item else { return .none }
        return f[indexPath.item].mediaId
    }
}
