//
//  ScoresTableViewController.swift
//  Airstrike
//
//  Created by Bret Smith on 12/7/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

class ScoresTableViewController: UITableViewController {

    let viewModel = ScoresViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRefreshControl()
        tableView.delegate = self
        
        tableView.register(UINib(nibName: "GameProgressCell", bundle: nil), forCellReuseIdentifier: "gameProgress")
        tableView.register(UINib(nibName: "ScoreHeaderCell", bundle: nil), forCellReuseIdentifier: viewModel.headerReuseIdentifier())
        registerNotifications()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.cellReuseIdentifier(), for: indexPath)
        (cell as? GameProgressTableViewCell)?.setCell(gameInfo: viewModel.gameData(for: indexPath))
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.cellHeight()
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var header = tableView.dequeueReusableCell(withIdentifier: viewModel.headerReuseIdentifier()) as? ScoreHeaderCell
        header?.setLabel(header: viewModel.headerText(for: section))
        if !viewModel.isRowGameCell() {
            header = .none
        }
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return viewModel.headerHeight()
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if viewModel.isRowGameCell() {
            return indexPath
        } else {
            return .none
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.gameSelected(at: indexPath)
        performSegue(withIdentifier: "gameDetail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination as? GameDetailViewController
        destinationViewController?.viewModel.configureGame(newGame: viewModel.selectedGame)
    }

}

// MARK: Notification Methods

extension ScoresTableViewController {
    
    fileprivate func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(displayLeagueChanged(notification:)), name: ServiceNotificationType.displayLeagueChanged, object: .none)
    }
    
    func displayLeagueChanged(notification: Notification) {
        viewModel.initializeSeason()
        self.tableView.reloadData()
    }
    
}

// MARK: Refresh
extension ScoresTableViewController {
    
    fileprivate func setupRefreshControl() {
        self.refreshControl?.addTarget(self, action: #selector(handleRefresh(sender:)), for: UIControlEvents.valueChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshSuccess(notification:)), name: ServiceNotificationType.allDataRefreshed, object: .none)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshFailure(notification:)), name: ServiceNotificationType.allDataRefreshedFailed, object: .none)
    }
    
    func refreshSuccess(notification: Notification) {
        refreshControl?.endRefreshing()
        viewModel.initializeSeason()
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

