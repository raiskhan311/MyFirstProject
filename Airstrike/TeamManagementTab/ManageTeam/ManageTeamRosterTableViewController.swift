//
//  ManageTeamRosterTableViewController.swift
//  Airstrike
//
//  Created by Bret Smith on 1/20/17.
//  Copyright © 2017 Airstrike. All rights reserved.
//

import UIKit

class ManageTeamRosterTableViewController: UITableViewController {

    let viewModel = ManageTeamRosterViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage.imageWithColor(color: Colors.tableViewCellDividerColor)
        tableView.register(UINib(nibName: "PlayerCell", bundle: nil), forCellReuseIdentifier: "playerCell")
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "teamUpdated"), object: .none, queue: .none, using: teamUpdated)
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
    
    func configureTeam(team: Team?) {
        viewModel.configureTeam(team: team)
    }
    
    func teamUpdated(notification: Notification) {
        guard let team = try? DAOTeam().getTeam(teamGuid: viewModel.team?.id) else { return }
        viewModel.configureTeam(team: team)
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.rows()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.reuseIdentifier(), for: indexPath)
        (cell as? AddPlayerTableViewCell)?.setData(playerData: viewModel.data(for: indexPath))
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.cellHeight()
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return .none
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            viewModel.deleteItem(at: indexPath)
            tableView.deleteRows(at: [indexPath], with: .fade)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "teamUpdated"), object: .none)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addPlayer" {
            let destination = segue.destination as? UINavigationController
            let firstController = destination?.topViewController as? AddPlayerTableViewController
            if let team = viewModel.team {
                firstController?.configureTeam(team: team)
            }
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "addPlayer", sender: self)
    }
}
