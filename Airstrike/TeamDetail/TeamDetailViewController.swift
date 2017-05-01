//
//  TeamDetailViewController.swift
//  Airstrike
//
//  Created by Jeffrey K Lewis on 12/22/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

class TeamDetailViewController: UIViewController {
    
    @IBOutlet weak var backBarButton: UIBarButtonItem!
    @IBOutlet weak var winLossBarButon: UIBarButtonItem!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var behindSegmentedControlView: UIView!
    @IBOutlet weak var segmentedControl: CustomSegmentedControl!
    
    fileprivate let viewModel = TeamDetailViewModel()
    var team: Team?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.initialize(team: team)
        fillContainerViewWithInitialView()
        setupNavigationBar()
        setColors()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupNavigationBar()
        setColors()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        segmentedControl.didRotateTo(size: size)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {

    }
    
}

// MARK: Helper Functions

extension TeamDetailViewController {
    
    fileprivate func setupNavigationBar() {
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.barTintColor = viewModel.getTeamColor()
        navigationItem.title = viewModel.getTeamName()
        let titleDict = [NSForegroundColorAttributeName: viewModel.getTeamColor().findBestTextColorForBackgroundColor()]
        navigationController?.navigationBar.titleTextAttributes = titleDict
        navigationController?.navigationBar.tintColor = viewModel.getTeamColor().findBestTextColorForBackgroundColor()
        navigationItem.rightBarButtonItem?.title = viewModel.getWinLoss()
        if viewModel.getTeamColor().findBestTextColorForBackgroundColor() == .white {
            UIApplication.shared.statusBarStyle = .lightContent
        } else {
            UIApplication.shared.statusBarStyle = .default
        }
    }
    
    fileprivate func setColors() {
        behindSegmentedControlView.backgroundColor = viewModel.getTeamColor()
        segmentedControl.setColor(viewModel.getTeamColor().findBestTextColorForBackgroundColor())
    }
    
    fileprivate func fillContainerViewWithInitialView() {
        if let vc = viewModel.getViewControllerForIndex(index: 0) {
            self.addChildViewController(vc)
            vc.view.frame = CGRect(x: 0, y: 0, width: containerView.frame.width, height: containerView.frame.height)
            containerView.addSubview(vc.view)
            vc.didMove(toParentViewController: self)
        }
    }
    
}

// MARK: Actions

extension TeamDetailViewController {
    
    @IBAction func backBarButtonAction(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func segmentedControlValueChangedAction(_ sender: CustomSegmentedControl) {
        containerView.subviews.forEach { $0.removeFromSuperview() }
        
        if let vc = viewModel.getViewControllerForIndex(index: sender.selectedSegmentIndex) {
            self.addChildViewController(vc)
            vc.view.frame = CGRect(x: 0, y: 0, width: containerView.frame.width, height: containerView.frame.height)
            containerView.addSubview(vc.view)
            vc.didMove(toParentViewController: self)
        }
    }
    
}
