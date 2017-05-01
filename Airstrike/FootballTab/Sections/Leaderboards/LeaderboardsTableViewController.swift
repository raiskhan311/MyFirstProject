//
//  LeaderboardsTableViewController.swift
//  Airstrike
//
//  Created by Brian Nielson on 12/19/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

class LeaderboardsTableViewController: UITableViewController {
    
    let viewModel = LeaderboardsViewModel()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "GenericTableViewCell", bundle: nil), forCellReuseIdentifier: viewModel.identifier())
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
        let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.identifier(), for: indexPath)
        (cell as? GenericTableViewCell)?.setData(viewModel.textLabelForRow(indexPath: indexPath))
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.cellHeight()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.statType(for: indexPath)
        performSegue(withIdentifier: "leaderboardDetails", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination as? LeaderboardDetailsTableViewController
        destinationViewController?.viewModel.statisticType(statType: viewModel.statType)
        destinationViewController?.viewModel.positionType(position: viewModel.position)
        destinationViewController?.viewModel.statsForLeague(leagueId: viewModel.leagueId())
        destinationViewController?.navigationItem.title = viewModel.title
    }
    
}
