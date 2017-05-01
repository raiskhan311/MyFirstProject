//
//  StatsFilterTableViewController.swift
//  Airstrike
//
//  Created by Jeffrey K Lewis on 12/23/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

class StatsFilterTableViewController: UITableViewController {
    
    let viewModel = StatsFilterViewModel()
    
    var delegate: FilterApplied?
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "GenericHeaderCell", bundle: nil), forCellReuseIdentifier: "genericHeaderCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureNavigationItem()
        tableView.allowsMultipleSelection = true
        super.viewWillAppear(animated)
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
    
    private func configureNavigationItem() {
        self.navigationItem.leftBarButtonItems = [cancelButton]
        self.navigationItem.rightBarButtonItems = [doneButton]
        self.navigationItem.title = "Stats Filter"
    }
    
    fileprivate func setDoneButtonEnabled() {
        if viewModel.doneButtonEnabled(selectedIndexPaths: tableView.indexPathsForSelectedRows) {
            doneButton.isEnabled = true
        } else {
            doneButton.isEnabled = false
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: .none)
    }
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        delegate?.setFilters(position: viewModel.position(), seasons: viewModel.seasons(selectedIndexPaths: tableView.indexPathsForSelectedRows), teams: viewModel.teams(selectedIndexPaths: tableView.indexPathsForSelectedRows))
        self.dismiss(animated: true, completion: .none)
    }
}




// MARK: - Table view data source

extension StatsFilterTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getCellCountFor(section: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "statsFilterCell", for: indexPath)
        cell.textLabel?.text = viewModel.data(for: indexPath)
        if viewModel.cellIsSelectedInitially(indexPath: indexPath) {
           tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let indexPathToDeselect = IndexPath(item: viewModel.currentlySelectedPositionIndex(), section: 0)
            if indexPath != indexPathToDeselect {
                tableView.deselectRow(at: indexPathToDeselect, animated: true)
                viewModel.selectedPosition(indexPath: indexPath)
            }
        }
        setDoneButtonEnabled()
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        setDoneButtonEnabled()
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var header: GenericHeaderTableViewCell?
        header = tableView.dequeueReusableCell(withIdentifier: "genericHeaderCell") as? GenericHeaderTableViewCell
        header?.setLabel(header: viewModel.headerMessage(for: section))
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    
    
}
