//
//  MediaCollectionViewController.swift
//  Airstrike
//
//  Created by Bret Smith on 1/6/17.
//  Copyright © 2017 Airstrike. All rights reserved.
//

import AVFoundation
import AVKit
import UIKit

class MediaCollectionViewController: UICollectionViewController {
    
    let viewModel = MediaViewModel()
    @IBOutlet weak var noMediaLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(deviceRotated(notification:)), name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: .none)
    }
    
    func deviceRotated(notification: Notification) {
        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.invalidateLayout()
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
    
        return viewModel.sections()
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let items = viewModel.items()
        if items > 0 {
            noMediaLabel.isHidden = true
        }
        return items
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: viewModel.reuseIdentifier(), for: indexPath)
        DispatchQueue.main.async {
            (cell as? MediaCollectionViewCell)?.setData(videoToken: self.viewModel.videoToken(for: indexPath))
        }
        return cell
    }
    
    func createPlayer(indexPath: IndexPath)-> AVPlayer? {
        var player: AVPlayer?
        if let token = viewModel.videoToken(for: indexPath),let url = URL(string: MediaServiceConnector.sharedInstance.ziggeo.videos.GetURLForVideo(token)) {
            player = AVPlayer(url: url)
        }
        return player
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let playerController = AVPlayerViewController()
        playerController.player = createPlayer(indexPath: indexPath)
        self.present(playerController, animated: true, completion: nil)
        playerController.player?.play()
    }
    
}

// MARK: Delegate Layout

extension MediaCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let optimalSize: CGFloat = 180
        let divisor = (collectionView.frame.size.width/optimalSize).rounded()
        let cellSideLength = (collectionView.frame.size.width / divisor) - 1
        return CGSize(width: cellSideLength, height: cellSideLength)
    }
}
