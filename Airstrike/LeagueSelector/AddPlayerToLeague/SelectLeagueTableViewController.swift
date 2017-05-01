//
//  SelectLeagueTableViewController.swift
//  Airstrike
//
//  Created by Bret Smith on 2/17/17.
//  Copyright © 2017 Airstrike. All rights reserved.
//

import UIKit

class SelectLeagueTableViewController: UITableViewController {

    private let viewModel = SelectLeagueViewModel()
    
    var hasJoinButton = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.initialize()
        tableView.register(UINib(nibName: "GenericTableViewCell", bundle: nil), forCellReuseIdentifier: viewModel.reuseIdentifier())
        tableView.register(UINib(nibName: "GenericHeaderCell", bundle: nil), forCellReuseIdentifier: viewModel.headerReuseIdentifier())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.rows()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.reuseIdentifier(), for: indexPath)
        (cell as? GenericTableViewCell)?.setData(viewModel.nameOfLeague(at: indexPath))
        (cell as? GenericTableViewCell)?.disclosureImageView.isHidden = true
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.cellHeight()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.rowSelected(at: indexPath)
        if !hasJoinButton {
            self.addJoinButton()
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var header: GenericHeaderTableViewCell?
        header = tableView.dequeueReusableCell(withIdentifier: viewModel.headerReuseIdentifier()) as? GenericHeaderTableViewCell
        header?.setLabel(header: viewModel.headerText())
        return header
    }
    
    fileprivate func addJoinButton() {
        hasJoinButton = true
        let joinButton = UIBarButtonItem(title: "Join", style: .done, target: self, action: #selector(joinButtonAction(sender:)))
        self.navigationItem.rightBarButtonItem = joinButton
    }
    
    fileprivate func addSpinner() {
        let uiBusy = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        uiBusy.hidesWhenStopped = true
        uiBusy.startAnimating()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: uiBusy)
    }
    
    func joinButtonAction(sender: UIBarButtonItem) {
        guard let s = viewModel.selectedLeagueId, let user = try? DAOUser().getUser(), let u = user, let person = u.person else { return }
        addSpinner()
        ServiceConnector.sharedInstance.addPlayerToLeague(leagueId: s, personId: person.id, playerNumber: 1) { (success, playerId) in
            if success {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: .none)
                }
            } else {
                DispatchQueue.main.async {
                    self.addJoinButton()
                }
            }
        }
    }

}
