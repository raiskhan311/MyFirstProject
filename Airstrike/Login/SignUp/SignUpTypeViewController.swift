//
//  SignUpTypeViewController.swift
//  Airstrike
//
//  Created by Bret Smith on 2/16/17.
//  Copyright © 2017 Airstrike. All rights reserved.
//

import UIKit

class SignUpTypeViewController: UIViewController {
    
    var isPlayer = false

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func playerSignupPressed(_ sender: UIButton) {
        isPlayer = true
        performSegue(withIdentifier: "proceedToSignUp", sender: self)
    }

    @IBAction func nonPlayerSignupPressed(_ sender: UIButton) {
        isPlayer = false
        performSegue(withIdentifier: "proceedToSignUp", sender: self)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if !isPlayer {
            let destination = segue.destination as? SignUpTableViewController
            destination?.viewModel.pages = [.email,.password,.firstName,.lastName]
            destination?.viewModel.type = "nonPlayer"
        }
    }
}
