//
//  FeedCollectionViewController.swift
//  Airstrike
//
//  Created by Jeffrey K Lewis on 12/2/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class FeedCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let viewModel = FeedViewModel()
    
    let refreshControl = UIRefreshControl()
    
    fileprivate var didRotate = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRefreshControl()
        collectionView?.register(UINib(nibName: "FeedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: viewModel.reuseIdentifier())
        registerNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.initialize()
        if didRotate {
            collectionViewLayout.invalidateLayout()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.collectionViewLayout.invalidateLayout()
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.sections()   
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.cells(for: section)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: viewModel.reuseIdentifier(), for: indexPath)
        (cell as? FeedCollectionViewCell)?.setData(feedInformation: viewModel.cellData(for: indexPath))
        (cell as? FeedCollectionViewCell)?.delegate = { imgToken, description in
            DispatchQueue.main.async {
                self.showDetailsMenu(imageToken: imgToken, description: description)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: 329)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let playerController = CustomAVPlayerViewController()
        playerController.rotationDelegate = {
            self.didRotate = true
        }
        playerController.player = createPlayer(indexPath: indexPath)
        self.present(playerController, animated: true, completion: nil)
        playerController.player?.play()
    }
    
    func createPlayer(indexPath: IndexPath)-> AVPlayer? {
        var player: AVPlayer?
        if let token = viewModel.videoToken(for: indexPath),let url = URL(string: MediaServiceConnector.sharedInstance.ziggeo.videos.GetURLForVideo(token)) {
            player = AVPlayer(url: url)
        }
        return player
    }
    
    func showDetailsMenu(imageToken: String, description: String) {
        let ac = UIAlertController(title: .none, message: .none, preferredStyle: .actionSheet)
        let aCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: .none)
        let aShare = UIAlertAction(title: "Share", style: .default) { (action) in
            DispatchQueue.main.async {
                let share = MediaServiceConnector.sharedInstance.ziggeo.videos.GetURLForVideo(imageToken)
                guard let shareURL = URL(string: share) else { return }
                
                let objectsToShare: [Any] = [description, shareURL]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                self.present(activityVC, animated: true, completion: nil)
            }
        }
        ac.addAction(aCancel)
        ac.addAction(aShare)
        self.present(ac, animated: true, completion: .none)
    }

}

// MARK: Refresh

extension FeedCollectionViewController {
    
    fileprivate func setupRefreshControl() {
        self.refreshControl.addTarget(self, action: #selector(handleRefresh(sender:)), for: UIControlEvents.valueChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshSuccess(notification:)), name: ServiceNotificationType.allDataRefreshed, object: .none)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshFailure(notification:)), name: ServiceNotificationType.allDataRefreshedFailed, object: .none)
        self.collectionView?.addSubview(refreshControl)
        self.collectionView?.alwaysBounceVertical = true
    }
    
    func refreshSuccess(notification: Notification) {
        refreshControl.endRefreshing()
        viewModel.initialize()
        self.collectionView?.reloadData()
    }
    
    func refreshFailure(notification: Notification) {
        refreshControl.endRefreshing()
        let ac = UIAlertController(title: "Failed to update", message: "Check your internet connection and try again", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: .none))
        self.present(ac, animated: true, completion: .none)
    }
    
    func handleRefresh(sender: UIRefreshControl) {
        ServiceConnector.sharedInstance.refreshData()
    }
    
}

// MARK: Notification Methods

extension FeedCollectionViewController {
    
    fileprivate func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(displayLeagueChanged(notification:)), name: ServiceNotificationType.displayLeagueChanged, object: .none)
    }
    
    func displayLeagueChanged(notification: Notification) {
        viewModel.initialize()
        self.collectionView?.reloadData()
    }
    
}
