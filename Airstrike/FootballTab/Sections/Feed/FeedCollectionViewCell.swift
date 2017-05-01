//
//  FeedCollectionViewCell.swift
//  Airstrike
//
//  Created by Bret Smith on 12/21/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

typealias ShareFeedItemDelegate = (_ imageToken: String, _ description: String) -> ()

class FeedCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var feedImageView: UIImageView!
    @IBOutlet weak var feedContentLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var detailsButton: UIButton!
    
    var imageToken: String?
    var desc: String?
    var delegate: ShareFeedItemDelegate?
    
    func setData(feedInformation: [String:Any]) {
        if let imgToken = feedInformation["feedImage"] as? String {
            self.imageToken = imgToken
            _ = MediaServiceConnector.sharedInstance.ziggeo.videos.GetImageForVideo(imgToken, callback: { (image, response, error) in
                self.feedImageView.image = image
            })
        }
        desc = feedInformation["feedContent"] as? String
        feedContentLabel.text = desc
        timeStampLabel.text = feedInformation["timeStamp"] as? String
    }
    
    @IBAction func detailsButtonPressed(_ sender: Any) {
        if let d = delegate, let i = imageToken, let de = desc {
            d(i, de)
        }
    }
}
