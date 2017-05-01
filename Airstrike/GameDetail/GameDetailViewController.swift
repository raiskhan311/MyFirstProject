//
//  GameDetailViewController.swift
//  Airstrike
//
//  Created by Bret Smith on 1/4/17.
//  Copyright © 2017 Airstrike. All rights reserved.
//

import UIKit

class GameDetailViewController: UIViewController {
    @IBOutlet weak var teamOneName: UILabel!
    @IBOutlet weak var teamTwoName: UILabel!
    @IBOutlet weak var teamOnePoints: UILabel!
    @IBOutlet weak var teamTwoPoints: UILabel!
    @IBOutlet weak var gameStatusLabel: UILabel!
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var segmentedController: CustomSegmentedControl!
    @IBOutlet weak var containerView: UIView!
    
    let viewModel = GameDetailViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fillContainerViewWithInitialView()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.reloadGame()
        configureLabels()
        configureNavigationItem()
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
        // Dispose of any resources that can be recreated.
    }
    
}

extension GameDetailViewController {
    fileprivate func configureLabels() {
        let gameInfo = viewModel.gameInfo()
        teamOneName.text = gameInfo[GameInfo.teamOneName]
        teamOnePoints.text = gameInfo[GameInfo.teamOnePoints]
        teamTwoName.text = gameInfo[GameInfo.teamTwoName]
        teamTwoPoints.text = gameInfo[GameInfo.teamTwoPoints]
        gameStatusLabel.text = gameInfo[GameInfo.gameStatus]
        dateTimeLabel.text = gameInfo[GameInfo.time]
        addressLabel.text = gameInfo[GameInfo.location]
    }
    
    fileprivate func fillContainerViewWithInitialView() {
        if let vc = viewModel.getViewControllerForIndex(index: 0) {
            self.addChildViewController(vc)
            vc.view.frame = CGRect(x: 0, y: 0, width: containerView.frame.width, height: containerView.frame.height)
            containerView.addSubview(vc.view)
            vc.didMove(toParentViewController: self)
        }
    }
    
    fileprivate func setupSegmentedControl() {
        segmentedController.makeSegmentsImagesWithText(imagesWithText: (#imageLiteral(resourceName: "profileStatsIcon"), "Stats"), (#imageLiteral(resourceName: "profileMediaIcon"), "Media"))
    }
    
    fileprivate func configureNavigationItem() {
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "reverseDisclosureIcon"),  style: .plain, target: self, action: #selector(backButtonPressed(sender:)))
        backButton.tintColor = Colors.darkTextColor
        self.navigationItem.leftBarButtonItems = [backButton]
        self.navigationItem.title = viewModel.title()
    }

}

extension GameDetailViewController {
    @IBAction func sectionSwitcherSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        containerView.subviews.forEach { $0.removeFromSuperview() }
        
        if let vc = viewModel.getViewControllerForIndex(index: sender.selectedSegmentIndex) {
            self.addChildViewController(vc)
            vc.view.frame = CGRect(x: 0, y: 0, width: containerView.frame.width, height: containerView.frame.height)
            containerView.addSubview(vc.view)
            vc.didMove(toParentViewController: self)
        }
    }
    
    func backButtonPressed(sender: UIBarButtonItem) {
        _ = self.navigationController?.popViewController(animated: true)
    }
}
