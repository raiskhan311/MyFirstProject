//
//  MediaCollectionViewCell.swift
//  Airstrike
//
//  Created by Bret Smith on 1/6/17.
//  Copyright © 2017 Airstrike. All rights reserved.
//

import UIKit

class MediaCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var mediaThumbNail: UIImageView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    
    func setData(videoToken: String?) {
        if let token = videoToken {
            _ = MediaServiceConnector.sharedInstance.ziggeo.videos.GetImageForVideo(token) { (thumbnailImage, response, error) in
                DispatchQueue.main.async {
                    self.mediaThumbNail.image = thumbnailImage
                }
            }
        }
    }
}
