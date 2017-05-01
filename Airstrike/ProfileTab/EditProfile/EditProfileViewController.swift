//
//  EditProfileViewController.swift
//  Airstrike
//
//  Created by BoHuang on 3/27/17.
//  Copyright © 2017 Airstrike. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {

    fileprivate let viewModel = EditProfileViewModel()
    
    @IBOutlet weak var doneRightBarItem: UIBarButtonItem!
    @IBOutlet weak var cancelLeftBarItem: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        removeNavBarShadow()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        cancelAction()
    }
    @IBAction func doneButtonPressed(_ sender: Any) {
        doneAction()
    }
  
    
}

// MARK: Helper Functions

extension EditProfileViewController {
    
    fileprivate func changeStatusBarColor() {
        if viewModel.getAccentColor().findBestTextColorForBackgroundColor() == .white {
            UIApplication.shared.statusBarStyle = .lightContent
        } else {
            UIApplication.shared.statusBarStyle = .default
        }
    }
    
    fileprivate func removeNavBarShadow() {
	        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
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

extension EditProfileViewController{
    
    fileprivate func cancelAction(){
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func doneAction(){
    }
}
