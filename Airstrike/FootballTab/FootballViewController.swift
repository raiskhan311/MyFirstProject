//
//  FootballViewController.swift
//  Airstrike
//
//  Created by Jeffrey K Lewis on 12/2/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

class FootballViewController: UIViewController {
        
    @IBOutlet weak var sectionSwitcherSegmentedControl: CustomSegmentedControl!
    @IBOutlet weak var containerView: UIView!
    
    fileprivate let viewModel = FootballViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fillContainerViewWithInitialView()
        addBarButtonItems()
        setupColors()
        setupNavBarTitle()
        registerNotifications()
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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        sectionSwitcherSegmentedControl.didRotateTo(size: size)
    }
    
}

// MARK: View helper methods

extension FootballViewController {
    
    fileprivate func setupNavBarTitle() {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        let image = CustomSegmentedControl.embedTextInImage(image: #imageLiteral(resourceName: "downArrow"), string: ServiceConnector.sharedInstance.getDisplayLeague()?.name ?? "", color: .black, imageAlignment: 1)
        let button = UIButton()
        button.setImage(image, for: .normal)
        button.frame = container.frame
        button.addTarget(self, action: #selector(leagueSelectorButtonAction(sender:)), for: .touchUpInside)
        container.addSubview(button)
        self.navigationItem.titleView = container
    }
    
    fileprivate func fillContainerViewWithInitialView() {
        if let vc = viewModel.getViewControllerForIndex(index: 0) {
            self.addChildViewController(vc)
            vc.view.frame = CGRect(x: 0, y: 0, width: containerView.frame.width, height: containerView.frame.height)
            containerView.addSubview(vc.view)
            vc.didMove(toParentViewController: self)
        }
    }
    
    fileprivate func addBarButtonItems() {
        if viewModel.shouldShowSignUpButton() {
            let signUpBarButton = UIBarButtonItem(title: "Sign Up", style: .plain, target: self, action: #selector(signUpBarButtonAction(sender:)))
            self.navigationItem.setLeftBarButton(signUpBarButton, animated: false)
        }
        self.navigationItem.leftBarButtonItem?.tintColor = Colors.darkTextColor
        // **** Uncomment this to add the notificationIcon to the notification bar  ****
//        let notificationBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "notificationIcon"), style: .plain, target: self, action: #selector(notificationBarButtonAction(sender:)))
//        self.navigationItem.setLeftBarButton(notificationBarButton, animated: false)
//        self.navigationItem.leftBarButtonItem?.tintColor = Colors.darkTextColor
        
//        let searchBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "searchIcon"), style: .plain, target: self, action: #selector(searchBarButtonAction(sender:)))
//        self.navigationItem.setRightBarButton(searchBarButton, animated: false)
//        self.navigationItem.rightBarButtonItem?.tintColor = Colors.darkTextColor
    }
    
    fileprivate func setupColors() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage.imageWithColor(color: Colors.tableViewCellDividerColor)
        sectionSwitcherSegmentedControl.tintColor = Colors.darkTextColor
    }

}

// MARK: Notification Methods

extension FootballViewController {
    
    fileprivate func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(displayLeagueChanged(notification:)), name: ServiceNotificationType.displayLeagueChanged, object: .none)
    }
    
    func displayLeagueChanged(notification: Notification) {
        setupNavBarTitle()
    }
    
}

// MARK: Action Methods

extension FootballViewController {
    
    func signUpBarButtonAction(sender: UIBarButtonItem) {
        
    }
    
    func leagueSelectorButtonAction(sender: UIButton) {
        let sb = UIStoryboard(name: "LeagueSelector", bundle: .none)
        guard let vc = sb.instantiateInitialViewController() else { return }
        self.present(vc, animated: true, completion: .none)
    }
    
    func notificationBarButtonAction(sender: UIBarButtonItem) {
        
    }
    
    func searchBarButtonAction(sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "footballToSearch", sender: nil)
    }
    
    @IBAction func sectionSwitcherSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        containerView.subviews.forEach { $0.removeFromSuperview() }
        
        if let vc = viewModel.getViewControllerForIndex(index: sender.selectedSegmentIndex) {
            self.addChildViewController(vc)
            vc.view.frame = CGRect(x: 0, y: 0, width: containerView.frame.width, height: containerView.frame.height)
            containerView.addSubview(vc.view)
            vc.didMove(toParentViewController: self)
        }
    }
    
}
