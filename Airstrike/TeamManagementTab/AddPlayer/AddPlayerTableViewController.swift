//
//  AddPlayerTableViewController.swift
//  Airstrike
//
//  Created by Bret Smith on 1/23/17.
//  Copyright © 2017 Airstrike. All rights reserved.
//

import UIKit

class AddPlayerTableViewController: UITableViewController {
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    let viewModel = AddPlayerViewModel()
    var team: Team?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage.imageWithColor(color: Colors.tableViewCellDividerColor)
        tableView.allowsSelection = true
        viewModel.delegate = self
        tableView.register(UINib(nibName: "PlayerCell", bundle: nil), forCellReuseIdentifier: "playerCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func configureTeam(team: Team) {
        self.team = team
        viewModel.configureLeague(leagueId: team.leagueGuid)
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
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        if let personToAdd = viewModel.person(at: tableView.indexPathForSelectedRow), let t = team, let player = personToAdd.players?.filter({$0.leagueId == ServiceConnector.sharedInstance.getDisplayLeague()?.id}).first {
            var players = personToAdd.players ?? [Player]()
            players.append(Player(id: player.id, leagueId: player.leagueId, teamId: t.id, personId: player.personId, number: player.number, awards: player.awards))
            let updatedPerson = Person(id: personToAdd.id, firstName: personToAdd.firstName, lastName: personToAdd.lastName, profileImagePath: personToAdd.profileImagePath, profileDescription: personToAdd.profileDescription, players: players)
            var teamPersons = t.persons
            teamPersons?.append(updatedPerson)
            let updatedTeam = Team(id: t.id, name: t.name, color: t.color, pastGames: t.pastGames, currentGame: t.currentGame, futureGames: t.futureGames, currentSeasonWins: t.currentSeasonWins, currentSeasonLosses: t.currentSeasonLosses, leagueGuid: t.leagueGuid, managerGuid: t.managerGuid, persons: teamPersons)
            try? DAOTeam().update(team: updatedTeam)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "teamUpdated"), object: .none)
            ServiceConnector.sharedInstance.addPlayerToTeam(teamId: t.id, playerId: player.id)
            self.dismiss(animated: true, completion: .none)
        }
    }
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: .none)
    }

    @IBAction func searchTextDidChange(_ sender: UITextField) {
        viewModel.searchTextDidChange(searchValue: sender.text)
    }
}

extension AddPlayerTableViewController: SearchFinished {
    func searchFinished() {
        self.tableView.reloadData()
    }
}
