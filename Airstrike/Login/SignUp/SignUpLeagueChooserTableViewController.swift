//
//  SignUpLeagueChooserTableViewController.swift
//  Airstrike
//
//  Created by Bret Smith on 2/14/17.
//  Copyright © 2017 Airstrike. All rights reserved.
//

import UIKit

class SignUpLeagueChooserTableViewController: UITableViewController {

    @IBOutlet weak var refreshControllerView: UIView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    let viewModel = SignUpLeagueChooserViewModel()
    var leagues: [League]?
    var signupInfo: [String: Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage.imageWithColor(color: Colors.tableViewCellDividerColor)
        viewModel.initialize(leagues: leagues)
        tableView.register(UINib(nibName: "GenericTableViewCell", bundle: nil), forCellReuseIdentifier: viewModel.reuseIdentifier())
        tableView.register(UINib(nibName: "GenericHeaderCell", bundle: nil), forCellReuseIdentifier: viewModel.headerReuseIdentifier())
        setupRefreshControl()
        submitButton.isEnabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        (cell as? GenericTableViewCell)?.setData(viewModel.data(for: indexPath))
        (cell as? GenericTableViewCell)?.disclosureImageView.isHidden = true
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.cellHeight()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.rowSelected(at: indexPath)
        submitButton.isEnabled = true
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var header: GenericHeaderTableViewCell?
        header = tableView.dequeueReusableCell(withIdentifier: viewModel.headerReuseIdentifier()) as? GenericHeaderTableViewCell
        header?.setLabel(header: viewModel.headerText())
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return viewModel.heightForHeader()
    }
    
    fileprivate func postNotification (notificationType: Notification.Name, userInfo: [NSObject: AnyObject]?) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: notificationType, object: self, userInfo: userInfo)
        }
    }
}

extension SignUpLeagueChooserTableViewController {
    @IBAction func cancelButtonAction(_ sender: UIButton) {
        _ = navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func nextButtonAction(_ sender: UIButton) {
        activityIndicator.startAnimating()
        if let email = signupInfo?["email"] as? String,
            let password = signupInfo?["password"] as? String,
            let firstName = signupInfo?["firstName"] as? String,
            let lastName = signupInfo?["lastName"] as? String {
            ServiceConnector.sharedInstance.signup(email: email, password: password, firstName: firstName, lastName: lastName, description: signupInfo?["description"] as? String, playerNumber: signupInfo?["playerNumber"] as? String, leagueId: viewModel.selectedLeagueId, complete: { (success) in
                if success {
                    DispatchQueue.main.async {
                        self.postNotification(notificationType: ServiceNotificationType.userLoggedIn, userInfo: .none)
                        self.performSegue(withIdentifier: "mainSegue", sender: self)
                    }
                }
            })
        }
    }

}

// MARK: Refresh

extension SignUpLeagueChooserTableViewController {
    
    fileprivate func setupRefreshControl() {
        self.refreshControl?.addTarget(self, action: #selector(handleRefresh(sender:)), for: UIControlEvents.valueChanged)
    }
    
    func handleRefresh(sender: UIRefreshControl) {
        submitButton.isEnabled = false
        ServiceConnector.sharedInstance.getLeagues(complete: { (success, leagues) in
            if success {
                DispatchQueue.main.async {
                    self.viewModel.initialize(leagues: leagues)
                    self.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                }
            } else {
                self.refreshControl?.endRefreshing()
                let ac = UIAlertController(title: "Failed to update", message: "Check your internet connection and try again", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default, handler: .none))
                self.present(ac, animated: true, completion: .none)
            }
        })
    }
    
}

