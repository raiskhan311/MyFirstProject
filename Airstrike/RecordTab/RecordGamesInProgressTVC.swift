//
//  RecordGamesInProgressTVC.swift
//  Airstrike
//
//  Created by Bret Smith on 12/29/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

class RecordGamesInProgressTVC: UITableViewController {
    
    let viewModel = RecordTVCViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "GameProgressCell", bundle: nil), forCellReuseIdentifier: viewModel.cellReuseIdentifier())
        viewModel.initialize()
        setupRefreshControl()
        addNotificationObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .default
        navigationController?.navigationBar.tintColor = .black
        let titleDict = [NSForegroundColorAttributeName: UIColor.black]
        navigationController?.navigationBar.titleTextAttributes = titleDict
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.shadowImage = UIImage.imageWithColor(color: Colors.tableViewCellDividerColor)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.rows()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.cellReuseIdentifier(), for: indexPath)
        cell.selectionStyle = .none
        (cell as? GameProgressTableViewCell)?.setCell(gameInfo: viewModel.gameData(for: indexPath))

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.cellHeight()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.setSelectedCellData(for: indexPath)
        viewModel.infoForStat(indexPath: indexPath)
        performSegue(withIdentifier: "recordSegue", sender: self)
    }
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as? RecordingViewController
        if let selectedData = viewModel.selectedCellData {
            destinationVC?.gameInfoOpt = selectedData
            destinationVC?.infoForStat = viewModel.statInfoForIndexPath
        }
    }
}

// MARK: Notification

extension RecordGamesInProgressTVC {
    
    fileprivate func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshSuccess(notification:)), name: ServiceNotificationType.displayLeagueChanged, object: .none)
    }
    
}

// MARK: Refresh

extension RecordGamesInProgressTVC {
    
    fileprivate func setupRefreshControl() {
        self.refreshControl?.addTarget(self, action: #selector(handleRefresh(sender:)), for: UIControlEvents.valueChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshSuccess(notification:)), name: ServiceNotificationType.allDataRefreshed, object: .none)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshFailure(notification:)), name: ServiceNotificationType.allDataRefreshedFailed, object: .none)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshSuccess(notification:)), name: ServiceNotificationType.gameStatusChanged, object: .none)
    }
    
    func refreshSuccess(notification: Notification) {
        refreshControl?.endRefreshing()
        viewModel.initialize()
        self.tableView?.reloadData()
    }
    
    func refreshFailure(notification: Notification) {
        refreshControl?.endRefreshing()
        let ac = UIAlertController(title: "Failed to update", message: "Check your internet connection and try again", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: .none))
        self.present(ac, animated: true, completion: .none)
    }
    
    func handleRefresh(sender: UIRefreshControl) {
        ServiceConnector.sharedInstance.refreshData()
    }
    
}

