//
//  StatsCreationViewController.swift
//  Airstrike
//
//  Created by Bret Smith on 12/29/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

protocol PreviousStatInfoUpdated {
    func updateStats(previousStatInfo: [Position:Person]?)
}

protocol StatsEntered {
    func statsEntered(stats: [Stat])
}

class StatsCreationViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: CustomSegmentedControl!
    var viewModel: StatsCreationViewModel?
    var infoForStat: [String: String]?
    var previousStatInfo: [Position:Person]?
    var delegate: PreviousStatInfoUpdated?
    var statsEnteredDelegate: StatsEntered?
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if viewModel == .none {
            if let statInfo = infoForStat {
                viewModel = StatsCreationViewModel(gameId: statInfo["gameId"] ?? "", seasonId: statInfo["seasonId"] ?? "", leagueId: statInfo["leagueId"] ?? "",mediaId: statInfo["mediaId"], gameStatus: GameStatus(rawValue:statInfo["gameStatus"] ?? "") ?? .notStarted, previousStatInfo: self.previousStatInfo)
            }
            configureMenus()
            configureSegementedControl()
        }
        
        if let model = viewModel {
            self.tableView.register(UINib(nibName: "GenericTableViewCell", bundle: nil), forCellReuseIdentifier: "genericCell")
            self.tableView.register(UINib(nibName: "NumberInputCell", bundle: nil), forCellReuseIdentifier: "numberInputCell")
            tableView.register(UINib(nibName: "GenericHeaderCell", bundle: nil), forCellReuseIdentifier: model.headerReuseIdentifier())
            configureMenus()
            configureSegementedControl()
        }
    }
        
    override func viewDidLayoutSubviews() {
        guard let model = viewModel else { return }
        segmentedControl.selectedSegmentIndex = model.segmentToDisplay()
        segmentedControl.valueChanged(segmentedControl)
        segmentedControl.didRotateTo(size: self.tableView.frame.size)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        segmentedControl.didRotateTo(size: size)
    }

    private func configureMenus() {
        self.navItem.title = viewModel?.title()
        if let model = viewModel {
            if model.hideSegentedController() {
                tableViewTopConstraint.constant = 0
            } else {
                tableViewTopConstraint.constant = segmentedControl.bounds.height + 5
            }
            if model.showBackButton() {
                self.navItem.leftBarButtonItems = [backButton]
            } else {
                self.navItem.leftBarButtonItems = [cancelButton]
            }
        }
    }
    
    private func configureSegementedControl() {
        guard let model = viewModel else { return }
        segmentedControl.setTitle(model.team1?.name, forSegmentAt: 0)
        segmentedControl.setTitle(model.team2?.name, forSegmentAt: 1)
    }
}

// MARK: - IBActions

extension StatsCreationViewController {
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        if let model = viewModel {
            model.pageBack()
        }
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func segmentedControlChanged(_ sender: CustomSegmentedControl) {
        if let model = viewModel {
            model.segmentChanged(selectedSegment: sender.selectedSegmentIndex)
            tableView.reloadData()
        }
    }

    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - TableViewController Delegate

extension StatsCreationViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        var sections = 0
        if let model = viewModel {
            sections = model.sections()
        }
        return sections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        if let model = viewModel {
            rows = model.rows(for: section)
        }
        return rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = viewModel else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: model.reuseIdentifier(), for: indexPath)
        (cell as? GenericTableViewCell)?.setData(model.data(for: indexPath))
        (cell as? GenericTableViewCell)?.titleLabel.font = UIFont.systemFont(ofSize: 20)
        (cell as? NumberInputTableViewCell)?.delegate = { yardsGained in
            model.yardsAdded(yards: yardsGained)
            self.determineTransition()
        }
        (cell as? NumberInputTableViewCell)?.textInput.becomeFirstResponder()
        
        return cell
    }
                                                                            
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        var path: IndexPath? = indexPath
        guard let model = viewModel else { return .none }
        if !model.rowIsSelectable(indexPath: indexPath) {
            path = .none
        }
        return path
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let model = viewModel else { return }
        model.rowSelected(indexPath: indexPath)
        determineTransition()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let model = viewModel else { return 0 }
        return model.height(forRowAt: indexPath)
    }
        
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var header: GenericHeaderTableViewCell?
        if section == 0 {
            if let model = viewModel {
                header = tableView.dequeueReusableCell(withIdentifier: model.headerReuseIdentifier()) as? GenericHeaderTableViewCell
                header?.setLabel(header: model.headerText())
            }
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let model = viewModel else { return 0 }
        return model.heightForHeader(for: section, screenSize: self.tableView.frame.size)
    }
    
    private func determineTransition() {
        guard let model = viewModel else { return }
        if model.statCreationFinished() {
            saveStats()
        } else {
            addViewToStack()
        }
    }
    
    private func saveStats() {
        guard let model = viewModel else { return }
        if let d = delegate {
            d.updateStats(previousStatInfo: model.getPreviousStatInfo())
        }
        if let sEntered = statsEnteredDelegate {
            sEntered.statsEntered(stats: model.createStats())
        }
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
     private func addViewToStack() {
        let storyboard = UIStoryboard(name: "StatsCreation", bundle: .none)
        if let newController = storyboard.instantiateViewController(withIdentifier: "StatsCreationVC") as? StatsCreationViewController {
            newController.viewModel = viewModel
            newController.delegate = self.delegate
            newController.statsEnteredDelegate = self.statsEnteredDelegate
            self.navigationController?.pushViewController(newController, animated: true)
        }
    }
}
