//
//  RosterTableViewController.swift
//  Airstrike
//
//  Created by Brian Nielson on 12/23/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

class RosterTableViewController: UITableViewController {

    var team: Team?
    
    let viewModel = RosterViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.initialize(team: team)
        tableView.register(UINib(nibName: "RosterCell", bundle: nil), forCellReuseIdentifier: "rosterCell")
        tableView.register(UINib(nibName:"RosterHeaderCell", bundle: nil), forCellReuseIdentifier: "rosterHeader")
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "rosterCell", for: indexPath) as! RosterCell

        cell.playerNumberAndNameLabel.text = viewModel.getPlayerName(indexPath: indexPath)
        cell.profileImageView.cache_imageForURL(viewModel.getPlayerImageURL(indexPath: indexPath))

        return cell
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: "rosterHeader") as? RosterHeaderCell
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.setPerson(for: indexPath)
        performSegue(withIdentifier: "profileViewSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination as? ProfileViewController
        destinationViewController?.setupPersonInViewModel(person: viewModel.getPerson())
    }

}
