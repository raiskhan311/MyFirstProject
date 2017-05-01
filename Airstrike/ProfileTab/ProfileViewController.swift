//
//  ProfileViewController.swift
//  Airstrike
//
//  Created by Jeffrey K Lewis on 12/7/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var segmentedControl: CustomSegmentedControl!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileDetailsView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var profileLabel: UILabel!
    
    @IBOutlet weak var profilePenMark: UIImageView!
    @IBOutlet weak var descriptionPenMark: UIImageView!
    @IBOutlet weak var teamPenMark: UIImageView!
    @IBOutlet weak var numberPenMark: UIImageView!
    @IBOutlet weak var imagePenMark: UIImageView!
    fileprivate let viewModel = ProfileViewModel()

    @IBOutlet var playerNameNumberGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet var profileImageGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet var descriptionLabelGestureRecognizer: UITapGestureRecognizer!
    
    var isEdit = false
    var editBarButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        setPersonIfNonePresent()
        fillContainerViewWithInitialView()
        setupProfileImageView()
        configureGestureRecognizers()
        registerNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        changeStatusBarColor()
        removeNavBarShadow()
        addBarButtonItems()
        setupColors()
        setupSegmentedControl()
        setupLabelsText()
        showPenMarks(isShow: isEdit)
    }
    
    override func viewWillDisappear(_ animated: Bool) {

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupPersonInViewModel(person: Person?) {
        if let p = person {
            viewModel.configurePerson(person: p)
        }
    }
}

// Gesture Recognizers

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func configureGestureRecognizers() {
        if viewModel.userIsPerson() {
            playerNameNumberGestureRecognizer.addTarget(self, action: #selector(nameNumberPressed))
            descriptionLabelGestureRecognizer.addTarget(self, action: #selector(descriptionPressed))
            profileImageGestureRecognizer.addTarget(self, action: #selector(imagePressed))
        }
    }
    
    func nameNumberPressed() {
        if !isEdit {
            return
        }
        let alert = UIAlertController(title: "User Info", message: "Edit Name or Number below.", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addTextField { (firstNameTextField) in
            firstNameTextField.autocapitalizationType = .words
            firstNameTextField.text = self.viewModel.firstName()
        }
        alert.addTextField { (lastNameTextField) in
            lastNameTextField.autocapitalizationType = .words
            lastNameTextField.text = self.viewModel.lastName()
        }
        
        if viewModel.personIsPlayerInDisplayLeague() {
            alert.addTextField { (numberTextField) in
                numberTextField.text = self.viewModel.playerNumber()
            }
            alert.addAction(UIAlertAction(title: "Update", style: UIAlertActionStyle.default, handler:{ (UIAlertAction) in
                if let firstName = alert.textFields?[0].text, let lastName = alert.textFields?[1].text, let number = alert.textFields?[2].text  {
                    self.titleLabel.text = "#" + number + " " + firstName + " " + lastName
                    self.updateProfile(firstName: firstName, lastName: lastName, number: Int(number), profileDescription: .none)
                }
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: .none))
            
            self.present(alert, animated: true, completion: .none)
        } else {
            alert.addAction(UIAlertAction(title: "Update", style: UIAlertActionStyle.default, handler:{ (UIAlertAction) in
                if let firstName = alert.textFields?[0].text, let lastName = alert.textFields?[1].text {
                    self.titleLabel.text = firstName + " " + lastName
                    self.updateProfile(firstName: firstName, lastName: lastName, number: .none, profileDescription: .none)
                }
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: .none))
            
            self.present(alert, animated: true, completion: .none)
        }
    }
    
    func descriptionPressed() {
        if !isEdit {
            return
        }
        let alert = UIAlertController(title: "Player Description", message: "Enter a brief description for yourself.", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (descriptionTextField) in
            descriptionTextField.autocapitalizationType = .sentences
        })
        alert.addAction(UIAlertAction(title: "Update", style: UIAlertActionStyle.default, handler:{ (UIAlertAction) in
            if let description = alert.textFields?[0].text {
                self.descriptionLabel.text = description
                self.updateProfile(firstName: .none, lastName: .none, number: .none, profileDescription: description)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: .none))
        
        self.present(alert, animated: true, completion: .none)
    }
    
    func getPhoto(source: UIImagePickerControllerSourceType) {

        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = source
            imagePicker.allowsEditing = true
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePressed() {
        if !isEdit {
            return
        }
        let actionController = UIAlertController(title: "Choose a source for your photo.", message: .none, preferredStyle: .actionSheet)
        actionController.addAction(UIAlertAction(title: "Choose Photo from Library", style: .default, handler: { _ in
            self.getPhoto(source: .photoLibrary)
        }))
        actionController.addAction(UIAlertAction(title: "Take a Photo", style: .default, handler: { _ in
            self.getPhoto(source: .camera)
        }))
        actionController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: .none))
        present(actionController, animated: true, completion: .none)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            profileImageView.contentMode = .scaleAspectFit
            profileImageView.image = pickedImage
            ServiceConnector.sharedInstance.uploadImage(image: pickedImage, person: viewModel.person)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: Helper Functions

extension ProfileViewController {
    
    fileprivate func fillContainerViewWithInitialView() {
        if let vc = viewModel.getViewControllerForIndex(index: 0) {
            self.addChildViewController(vc)
            vc.view.frame = CGRect(x: 0, y: 0, width: containerView.frame.width, height: containerView.frame.height)
            containerView.addSubview(vc.view)
            vc.didMove(toParentViewController: self)
        }
    }
    
    fileprivate func changeStatusBarColor() {
        if viewModel.getAccentColor().findBestTextColorForBackgroundColor() == .white {
            UIApplication.shared.statusBarStyle = .lightContent
        } else {
            UIApplication.shared.statusBarStyle = .default
        }
    }
    
    fileprivate func removeNavBarShadow() {
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    
    fileprivate func setupSegmentedControl() {
        segmentedControl.makeSegmentsImagesWithText(imagesWithText: (#imageLiteral(resourceName: "profileStatsIcon"), "Stats"), (#imageLiteral(resourceName: "profileMediaIcon"), "Media"), (#imageLiteral(resourceName: "profileAwardIcon"), "Awards"))
    }
    
    fileprivate func setupProfileImageView() {
        profileImageView.cache_imageForURL(viewModel.getPlayerImageURL())
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
    }
    
    fileprivate func showPenMarks(isShow: Bool){
        imagePenMark.isHidden = !isShow
        numberPenMark.isHidden = !isShow
        
        teamPenMark.isHidden = true
        descriptionPenMark.isHidden = !isShow
        profilePenMark.isHidden = !isShow
        
    }
    
    fileprivate func setupColors() {
        let accentColor = viewModel.getAccentColor()
        let titleDict = [NSForegroundColorAttributeName: accentColor.findBestTextColorForBackgroundColor()]
        navigationController?.navigationBar.titleTextAttributes = titleDict
        navigationController?.navigationBar.tintColor = accentColor.findBestTextColorForBackgroundColor()
        navigationController?.navigationBar.barTintColor = accentColor
        profileDetailsView.backgroundColor = accentColor
        if accentColor.findBestTextColorForBackgroundColor() == .white {
            titleLabel.textColor = Colors.lightTextColor
            subtitleLabel.textColor = Colors.lightTextColor
            descriptionLabel.textColor = Colors.lightTextColor
            profileLabel.textColor = Colors.lightTextColor
            UIApplication.shared.statusBarStyle = .lightContent
            segmentedControl.setColor(Colors.lightTextColor)
        } else {
            titleLabel.textColor = Colors.darkTextColor
            subtitleLabel.textColor = Colors.darkTextColor
            descriptionLabel.textColor = Colors.darkTextColor
            profileLabel.textColor = Colors.darkTextColor
            UIApplication.shared.statusBarStyle = .default
            segmentedControl.setColor(Colors.darkTextColor)
        }
        navigationController?.navigationBar.tintColor = accentColor.findBestTextColorForBackgroundColor()
    }
    
    fileprivate func addBarButtonItems() {
        self.navigationItem.leftBarButtonItems = .none
        self.navigationItem.rightBarButtonItems = .none

        if viewModel.userIsPerson() {
            let logoutBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "logoutIcon"), style: .plain, target: self, action: #selector(logoutBarButtonAction(sender:)))
            self.navigationItem.setLeftBarButton(logoutBarButton, animated: false)
            self.navigationItem.leftBarButtonItem?.tintColor = viewModel.getAccentColor().findBestTextColorForBackgroundColor()
            
            //Add edit button
            editBarButton = UIBarButtonItem.init(title: "Edit", style: .plain, target: self, action: #selector(editProfileButtonAction(sender:)))
            editBarButton.title = "Edit"
            
            self.navigationItem.setRightBarButton(editBarButton, animated:false)
            self.navigationItem.rightBarButtonItem?.tintColor = viewModel.getAccentColor().findBestTextColorForBackgroundColor()
            
            

            
        } else {
            let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "reverseDisclosureIcon"), style: .plain, target: self, action: #selector(backBarButtonAction(sender:)))
            self.navigationItem.leftBarButtonItems = [backButton]
        }
    }
    
    fileprivate func setupLabelsText() {
        titleLabel.text = viewModel.getDisplayName()
        subtitleLabel.text = viewModel.getSubtitleText()
        descriptionLabel.text = viewModel.getDescriptionText()
        profileLabel.text = viewModel.getProfileText()
    }
    
    fileprivate func setPersonIfNonePresent() {
        viewModel.configureUser()
    }
    
    fileprivate func updateProfile(firstName: String?, lastName: String?, number: Int?, profileDescription: String?) {
        if let p = viewModel.person {
            let playerId = p.players?.filter({ $0.leagueId == ServiceConnector.sharedInstance.getDisplayLeague()?.id}).first?.id
            ServiceConnector.sharedInstance.updateProfile(firstName: firstName, lastName: lastName, profileDescription: profileDescription, number: number, personId: p.id, playerId: playerId, complete: { (success) in
                if success {
                    var players = p.players ?? [Player]()
                    if let pl = p.players?.filter({ $0.leagueId == ServiceConnector.sharedInstance.getDisplayLeague()?.id}).first {
                        if let i = players.index(where: { $0.id == pl.id }) {
                            players.remove(at: i)
                        }
                        players.append(Player(id: pl.id, leagueId: pl.leagueId, teamId: pl.teamId, personId: pl.personId, number: number ?? pl.number, awards: pl.awards))
                    }
                    if players.count == 0 {
                        let person = Person(id: p.id, firstName: firstName ?? p.firstName, lastName: lastName ?? p.lastName, profileImagePath: p.profileImagePath, profileDescription: profileDescription ?? p.profileDescription, players: .none)
                        try? DAOPerson().update(person)
                        self.viewModel.person = person
                    } else {
                        let person = Person(id: p.id, firstName: firstName ?? p.firstName, lastName: lastName ?? p.lastName, profileImagePath: p.profileImagePath, profileDescription: profileDescription ?? p.profileDescription, players: players)
                        try? DAOPerson().update(person)
                        self.viewModel.person = person
                    }
                }
            })
        }
    }

}

// MARK: Notification Methods

extension ProfileViewController {
    
    fileprivate func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(displayLeagueChanged(notification:)), name: ServiceNotificationType.displayLeagueChanged, object: .none)
        NotificationCenter.default.addObserver(self, selector: #selector(displayLeagueChanged(notification:)), name: ServiceNotificationType.allDataRefreshed, object: .none)
    }
    
    func displayLeagueChanged(notification: Notification) {
        viewModel.setupData()
        setPersonIfNonePresent()
        setupProfileImageView()
        setupLabelsText()
        viewModel.reloadContainerView()
    }
    
}

// MARK: Action Functions

extension ProfileViewController {
    
    func logoutBarButtonAction(sender: UIBarButtonItem) {
        ServiceConnector.sharedInstance.logout()
        let storyboard = UIStoryboard(name: "OnboardingScreen", bundle: nil)
        LoginHelperFunctions.changeRootViewController(toRootOf: storyboard)
    }
    
    func backBarButtonAction(sender: UIBarButtonItem) {
        self.presentedViewController?.dismiss(animated: true, completion: .none)
        _ = navigationController?.popViewController(animated: true)
    }
    func editProfileButtonAction(sender: UIBarButtonItem){
        /*let storyboard = UIStoryboard(name:"EditProfile", bundle: nil)
        let controller = storyboard.instantiateInitialViewController()
        self.present(controller!, animated: true, completion: nil)*/
        isEdit = !isEdit
        if(isEdit){
            editBarButton.title = "Done"
        }else {
            editBarButton.title = "Edit"
        }
        showPenMarks(isShow: isEdit)
        
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
