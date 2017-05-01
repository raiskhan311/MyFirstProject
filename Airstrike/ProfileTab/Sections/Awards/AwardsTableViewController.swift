//
//  AwardsTableViewController.swift
//  Airstrike
//
//  Created by Brian Nielson on 12/30/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

class AwardsTableViewController: UITableViewController {

    var player: Player?
    
    fileprivate let viewModel = AwardsTableViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.initialize(player: player)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}


// MARK: - Table view data source

extension AwardsTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getNumberOfRows()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.getRowHeight()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "awardCell", for: indexPath)
        
        (cell as? AwardsTableViewCell)?.setText(
            awardTitle: viewModel.getAwardNameForCell(at: indexPath),
            date: viewModel.getDateForCell(at: indexPath)
        )
        
        return cell
    }

}
