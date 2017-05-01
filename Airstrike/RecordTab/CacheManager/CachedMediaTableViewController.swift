//
//  CachedMediaTableViewController.swift
//  Airstrike
//
//  Created by Jeffrey K Lewis on 1/9/17.
//  Copyright © 2017 Airstrike. All rights reserved.
//

import UIKit
import ReachabilitySwift

protocol UploadDelegate {
    func uploadComplete()
    func progressUpdated(progress: Float)
}

protocol UploadStatusDelegate {
    func videosWillBeginUploading()
    func videosWillStopUploading()
}


class CachedMediaTableViewController: UITableViewController {
    @IBOutlet weak var uploadProgressBar: UIProgressView!
    @IBOutlet weak var uploadAllButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    var uploadStopped = false
    var delegate: UploadStatusDelegate?
    let reachability = Reachability()!
    
    fileprivate let viewModel = CachedMediaTableViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        self.navigationItem.rightBarButtonItems = [uploadAllButton]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func presentDataUsageAlert() {
        let alert = UIAlertController(title: "No Wifi Connection", message: "You are not connected to a wifi network. Press continue to use cellular data to upload the videos. Otherwise, press cancel and connect to a wifi network.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { _ in
            self.beginUploadingVideos()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: .none))
        present(alert, animated: true, completion: .none)
    }
    
    func presentNoInternetAlert() {
        let alert = UIAlertController(title: "No Internet Connection", message: "You are not connected to the internet. Please connect to the internet to proceed.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: .none))
        present(alert, animated: true, completion: .none)
    }
    
    func beginUploadingVideos() {
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed(_:)))
        self.navigationItem.rightBarButtonItems = [cancelButton]
        uploadStopped = false
        viewModel.uploadAllVideos()
        if let d = delegate {
            d.videosWillBeginUploading()
        }
    }

    
}

// MARK: - Table view data source

extension CachedMediaTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = viewModel.getCellCount()
        if count == 0 {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
        return count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cacheCell", for: indexPath)
        (cell as? CachedMediaTableViewCell)?.setLabels(description: self.viewModel.getDescription(for: indexPath), duration: self.viewModel.getDuration(for: indexPath))
        if indexPath.item == 0 {
            delegate = (cell as? CachedMediaTableViewCell)
        }
        self.viewModel.getThumbnailImage(for: indexPath) { (image) in
            DispatchQueue.main.async {
                (cell as? CachedMediaTableViewCell)?.setImage(image: image)
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.cellHeight()
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return viewModel.canEdit
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            viewModel.deleteItem(at: indexPath)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    
}

// MARK: - Actions

extension CachedMediaTableViewController {
    
    @IBAction func closeButtonAction(_ sender: UIBarButtonItem) {
        uploadStopped = true
        if let d = delegate {
            d.videosWillStopUploading()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func uploadAllBarButtonAction(_ sender: UIBarButtonItem) {
        if reachability.isReachableViaWiFi {
            beginUploadingVideos()
        } else if reachability.isReachableViaWWAN {
            presentDataUsageAlert()
        } else if !reachability.isReachable {
            presentNoInternetAlert()
        }
    }
    
    func cancelButtonPressed(_ sender: UIBarButtonItem) {
        let uploadAllButton = UIBarButtonItem(title: "Upload All", style: .plain, target: self, action: #selector(uploadAllBarButtonAction(_:)))
        self.navigationItem.rightBarButtonItems = [uploadAllButton]
        if let d = delegate {
            d.videosWillStopUploading()
        }
        uploadAllButton.isEnabled = false
        uploadStopped = true
    }
    
}

// MARK: Upload Delegate

extension CachedMediaTableViewController: UploadDelegate {
    func uploadComplete() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.uploadProgressBar.setProgress(0, animated: false)
            if !self.uploadStopped {
                self.viewModel.uploadAllVideos()
            } else {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
        }
    }
    
    func progressUpdated(progress: Float) {
        DispatchQueue.main.async {
            if let d = self.delegate {
                d.videosWillBeginUploading()
            }
            self.uploadProgressBar.setProgress(progress, animated: true)
        }
    }
}
