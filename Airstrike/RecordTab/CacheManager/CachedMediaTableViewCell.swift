//
//  CachedMediaTableViewCell.swift
//  Airstrike
//
//  Created by Jeffrey K Lewis on 1/9/17.
//  Copyright © 2017 Airstrike. All rights reserved.
//

import UIKit

class CachedMediaTableViewCell: UITableViewCell {
    
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func awakeFromNib() {
        super.awakeFromNib()
        activityIndicator.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setLabels(description: String?, duration: String?) {
        self.descriptionLabel.text = description ?? ""
        self.durationLabel.text = duration ?? ""
    }
    
    func setImage(image: UIImage?) {
        self.thumbnailImageView.image = image
    }
    

}

// MARK: Upload Status Delegate

extension CachedMediaTableViewCell: UploadStatusDelegate {
    func videosWillBeginUploading() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func videosWillStopUploading() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
}
