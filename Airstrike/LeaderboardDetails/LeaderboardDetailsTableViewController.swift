//
//  LeaderboardDetailsTableViewController.swift
//  Airstrike
//
//  Created by Bret Smith on 12/28/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

class LeaderboardDetailsTableViewController: UITableViewController {
    
    let viewModel = LeaderboardDetailsViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
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
        return viewModel.sections()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.rows()
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.reuseIdentifier(), for: indexPath)
        (cell as? LeaderboardDetailsTableViewCell)?.setData(playerLeaderboardInfo: viewModel.data(for: indexPath))

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let person = viewModel.getPerson(for: indexPath)
        let sb = UIStoryboard(name: "Profile", bundle: nil)
        if let vc = sb.instantiateInitialViewController() as? ProfileViewController {
            vc.setupPersonInViewModel(person: person)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.cellHeight()
    }

    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        _ = self.navigationController?.popViewController(animated: true)
    }
}
