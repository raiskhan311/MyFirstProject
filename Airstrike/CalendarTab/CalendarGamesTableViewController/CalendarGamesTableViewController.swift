//
//  CalendarGamesTableViewController.swift
//  Airstrike
//
//  Created by Bret Smith on 12/23/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

class CalendarGamesTableViewController: UITableViewController {
    
    let viewModel = CalendarGamesViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nc = NotificationCenter.default
        nc.addObserver(forName:Notification.Name(rawValue:"CalendarDateChanged"), object:nil, queue:nil, using:dateChanged)
        setupRefreshControl()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.rows(for: section)
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.reuseIdentifier(), for: indexPath)
        (cell as? CalendarGameTableViewCell)?.setData(gameInfo: viewModel.gameInfo(for: indexPath))

        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        var selectedIndexPath: IndexPath? = indexPath
        if !viewModel.hasGamesScheduled {
            selectedIndexPath = .none
        }
        return selectedIndexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.gameSelected(at: indexPath)
        performSegue(withIdentifier: "gameDetail", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        (segue.destination as? GameDetailViewController)?.viewModel.game = viewModel.selectedGame
    }
    
    
    private func dateChanged(notification: Notification) {
        if let userInfo = notification.userInfo, let games = userInfo["games"] as? [Game] {
            viewModel.games = games
            if games.count > 0 {
                viewModel.hasGamesScheduled = true
                tableView.separatorStyle = .singleLine
            } else {
                viewModel.hasGamesScheduled = false
                tableView.separatorStyle = .none
            }
            tableView.reloadData()
        } else {
            viewModel.games = .none
            viewModel.hasGamesScheduled = false
            tableView.separatorStyle = .none
            tableView.reloadData()
        }
    }
    
}

// MARK: Refresh

extension CalendarGamesTableViewController {
    
    fileprivate func setupRefreshControl() {
        self.refreshControl?.addTarget(self, action: #selector(handleRefresh(sender:)), for: UIControlEvents.valueChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshSuccess(notification:)), name: ServiceNotificationType.allDataRefreshed, object: .none)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshFailure(notification:)), name: ServiceNotificationType.allDataRefreshedFailed, object: .none)
    }
    
    func refreshSuccess(notification: Notification) {
        refreshControl?.endRefreshing()
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
