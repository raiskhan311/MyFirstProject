//
//  ManagerTeamsTableViewController.swift
//  Airstrike
//
//  Created by Bret Smith on 1/19/17.
//  Copyright © 2017 Airstrike. All rights reserved.
//

import UIKit

class ManagerTeamsTableViewController: UITableViewController {
    
    let viewModel = ManagerTeamsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage.imageWithColor(color: Colors.tableViewCellDividerColor)
        tableView.register(UINib(nibName: "GenericTableViewCell", bundle: nil), forCellReuseIdentifier: viewModel.reuseIdentifier())
        registerNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.initialize()
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
        // Dispose of any resources that can be recreated.
    }
    
    func teamsUpdated(notification: Notification) {
        viewModel.initialize()
        tableView.reloadData()
    }
}


// MARK: - Table view data source

extension ManagerTeamsTableViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.rows()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.reuseIdentifier(), for: indexPath)
        (cell as? GenericTableViewCell)?.setData(viewModel.teamName(for: indexPath))
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.cellHeight()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.rowSelected(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "manageTeam", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as? ManageTeamRosterTableViewController
        destination?.configureTeam(team: viewModel.selectedTeam)
    }

}

// MARK: Notification Methods

extension ManagerTeamsTableViewController {
    
    fileprivate func registerNotifications() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "teamAdded"), object: .none, queue: .none, using: teamsUpdated)
        NotificationCenter.default.addObserver(self, selector: #selector(displayLeagueChanged(notification:)), name: ServiceNotificationType.displayLeagueChanged, object: .none)
    }
    
    func displayLeagueChanged(notification: Notification) {
        viewModel.initialize()
        self.tableView.reloadData()
    }
    
}
