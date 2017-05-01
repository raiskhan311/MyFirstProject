//
//  TeamsTableViewController.swift
//  Airstrike
//
//  Created by Brian Nielson on 12/19/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

class TeamsTableViewController: UITableViewController {

    let viewModel = TeamsViewModel()
    var league: League?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRefreshControl()
        tableView.register(UINib(nibName: "TeamsTableViewCell", bundle: nil), forCellReuseIdentifier: "TeamsTableViewCell")
        
        registerNotifications()

        teamsForLeagueId()
        
    }
    
    fileprivate func teamsForLeagueId() {
        guard let teams = try? DAOTeam().getTeams(leagueGuid: league?.id) else { return }
        viewModel.teams = teams
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
       return viewModel.numberOfSections()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TeamsTableViewCell", for: indexPath) as! TeamsTableViewCell
        cell.teamNameLabel.text = viewModel.textLabelForRow(indexPath: indexPath)
        cell.winLossLabel.text = viewModel.textNumbersForWinLoss(indexPath: indexPath)
        cell.teamColorTagView.backgroundColor = viewModel.teamColor(indexPath: indexPath)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sb = UIStoryboard(name: "TeamDetail", bundle: nil)
        guard let vc = sb.instantiateInitialViewController() as? TeamDetailViewController else { return }
        vc.team = viewModel.getTeamForCell(at: indexPath)
        navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.cellHeight()
    }

}

// MARK: Notification Methods

extension TeamsTableViewController {
    
    fileprivate func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(displayLeagueChanged(notification:)), name: ServiceNotificationType.displayLeagueChanged, object: .none)
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "teamUpdated"), object: .none, queue: .none, using: teamsUpdated)
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "teamAdded"), object: .none, queue: .none, using: teamsUpdated)
    }
    
    func displayLeagueChanged(notification: Notification) {
        self.league = ServiceConnector.sharedInstance.getDisplayLeague()
        self.teamsForLeagueId()
        self.tableView.reloadData()
    }
    
    func teamsUpdated(notification: Notification) {
        teamsForLeagueId()
        self.tableView.reloadData()
    }
    
}

// MARK: Refresh
extension TeamsTableViewController {
    
    fileprivate func setupRefreshControl() {
        self.refreshControl?.addTarget(self, action: #selector(handleRefresh(sender:)), for: UIControlEvents.valueChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshSuccess(notification:)), name: ServiceNotificationType.allDataRefreshed, object: .none)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshFailure(notification:)), name: ServiceNotificationType.allDataRefreshedFailed, object: .none)
    }
    
    func refreshSuccess(notification: Notification) {
        refreshControl?.endRefreshing()
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
