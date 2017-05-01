//
//  LeagueSelectorTableViewController.swift
//  Airstrike
//
//  Created by Jeffrey K Lewis on 2/16/17.
//  Copyright © 2017 Airstrike. All rights reserved.
//

import UIKit

class LeagueSelectorTableViewController: UITableViewController {
    
    let viewModel = LeagueSelectorViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "GenericHeaderCell", bundle: nil), forCellReuseIdentifier: "genericHeaderCell")
        
        guard let user = try? DAOUser().getUser(), let person = user?.person, let _ = person.players?.first else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem()
            return
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

// MARK: - Table view data source

extension LeagueSelectorTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.getSectionCount()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getCellCount(for: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "leagueSelectorCell", for: indexPath)
        (cell as? LeagueSelectorTableViewCell)?.titleLabel.text = viewModel.getTitle(forCellAt: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let leagueId = viewModel.getLeagueId(forCellAt: indexPath) else { return }
        ServiceConnector.sharedInstance.updateDisplayLeague(leagueId: leagueId)
        self.dismiss(animated: true, completion: .none)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var header: GenericHeaderTableViewCell?
        header = tableView.dequeueReusableCell(withIdentifier: "genericHeaderCell") as? GenericHeaderTableViewCell
        header?.setLabel(header: viewModel.getHeaderText(section: section))
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 54.0
    }
    
}

// MARK: Actions

extension LeagueSelectorTableViewController {
    
    @IBAction func cancelButtonAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: .none)
    }
    
    @IBAction func joinLeagueButtonAction(_ sender: UIBarButtonItem) {
        guard let user = try? DAOUser().getUser() else { return }
        if let person = user?.person, let player = person.players?.first {
            var signupInfo = [String:Any]()
            signupInfo["number"] = player.number
            signupInfo["personId"] = person.id
            let sb = UIStoryboard(name: "AddToLeague", bundle: .none)
            guard let vc = sb.instantiateInitialViewController() else { return }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
