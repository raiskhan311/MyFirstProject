//
//  ProfileStatsTableViewController.swift
//  Airstrike
//
//  Created by Jeffrey K Lewis on 12/7/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

class StatsTableViewController: UITableViewController {
    
    @IBOutlet weak var headerLabel: UILabel!
    
    let viewModel = StatsTableViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(forName: ServiceNotificationType.allDataRefreshed, object: .none, queue: .none, using: refreshData)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        headerLabel.text = viewModel.getHeaderDisplayText()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - Table view data source

extension StatsTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getCellCount()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "statCell", for: indexPath)
        
        (cell as? StatsTableViewCell)?.setText(
            statType: viewModel.getDisplayNameForCell(at: indexPath),
            value: viewModel.getValueForCell(at: indexPath)
        )
        
        return cell
    }
    
}

// MARK: Protocol For Filter Callbacks

protocol FilterApplied {
    func setFilters(position: Position, seasons:[Season]?, teams: [Team]?)
}

// MARK: Actions

extension StatsTableViewController {
    
    @IBAction func filterButtonAction(_ sender: UIButton) {
        let sb = UIStoryboard(name: "StatsFilter", bundle: nil)
        guard let nc = sb.instantiateInitialViewController() as? UINavigationController else { return }
        if let vc = nc.viewControllers.first as? StatsFilterTableViewController {
            vc.viewModel.initialize(allSeasons: viewModel.allSeasons, seasons: viewModel.seasonsToShowStatsFor, position: viewModel.positionToShowStatsFor, allTeams: viewModel.allTeams, teamsToShowStatsFor: viewModel.teamsToShowStatsFor)
            vc.delegate = self
        }
        present(nc, animated: true, completion: nil)
    }
    
}

// MARK: Filters
extension StatsTableViewController: FilterApplied {
    
    func setFilters(position: Position, seasons:[Season]?, teams: [Team]?) {
        self.viewModel.changeDataToDisplay(to: seasons, position: position, teams: teams)
        self.headerLabel.text = self.viewModel.getHeaderDisplayText()
        self.tableView.reloadData()
    }
    
}

// MARK: Notification
extension StatsTableViewController {
    func refreshData(_ notification: Notification) {
        viewModel.reinitializeStats()
        self.tableView.reloadData()
    }
}

