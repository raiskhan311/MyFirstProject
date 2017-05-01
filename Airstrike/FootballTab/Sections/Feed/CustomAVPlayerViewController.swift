//
//  CustomAVPlayerViewController.swift
//  Airstrike
//
//  Created by Jeffrey K Lewis on 2/14/17.
//  Copyright © 2017 Airstrike. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

typealias VideoRotatedDelegate = () -> ()

class CustomAVPlayerViewController: AVPlayerViewController {
    
    var rotationDelegate: VideoRotatedDelegate?

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        guard let d = rotationDelegate else { return }
        d()
    }

}
