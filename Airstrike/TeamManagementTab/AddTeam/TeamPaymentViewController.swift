//
//  TeamPaymentViewController.swift
//  Airstrike
//
//  Created by Bret Smith on 1/20/17.
//  Copyright © 2017 Airstrike. All rights reserved.
//

import UIKit
import Stripe

class TeamPaymentViewController: UIViewController {
    
    @IBOutlet weak var paymentView: UIView!
    
    var teamColor = UIColor.black
    var teamName = "No Team Name"
    var leagueId = "No League Id"
    
    let paymentTextField = STPPaymentCardTextField()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem?.isEnabled = false
        configurePaymentTextField()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

// MARK: Setup

extension TeamPaymentViewController {
    
    func configureTeamDetails(color: UIColor?, name: String?, leagueId: String) {
        if let c = color, let n = name {
            self.teamColor = c
            self.teamName = n
        }
        self.leagueId = leagueId
    }
    
    fileprivate func configurePaymentTextField() {
        paymentTextField.keyboardAppearance = .light
        paymentTextField.frame = CGRect(x: 0, y: 0, width: paymentView.frame.width, height: 44)
        paymentTextField.delegate = self
        paymentTextField.borderColor = .white
        paymentTextField.textColor = Colors.airstrikeDarkColor
        paymentTextField.translatesAutoresizingMaskIntoConstraints = false
        paymentView.addSubview(paymentTextField)
        
        
        let views = ["newView": paymentTextField]
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-[newView]-|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: views)
        paymentView.addConstraints(horizontalConstraints)
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-[newView]-|", options: NSLayoutFormatOptions.alignAllCenterX, metrics: nil, views: views)
        paymentView.addConstraints(verticalConstraints)
    }
    
}

// MARK: STPPaymentCardTextFieldDelegate

extension TeamPaymentViewController: STPPaymentCardTextFieldDelegate {
    
    func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
        navigationItem.rightBarButtonItem?.isEnabled = textField.valid
    }
    
}

// MARK: Helper

extension TeamPaymentViewController {
    
    fileprivate func getPaymentToken(complete: @escaping (STPToken?) -> ()) {
        STPAPIClient.shared().createToken(withCard: paymentTextField.cardParams) { (token, error) in
            if token == .none {
                self.presentAlert(message: "Make sure you are connected to the internet and try again.")
            }
            complete(token)
        }
    }
    
    fileprivate func presentAlert(message: String) {
        DispatchQueue.main.async {
            let ac = UIAlertController(title: "Payment Failed", message: message, preferredStyle: .alert)
            let aa = UIAlertAction(title: "OK", style: .default, handler: .none)
            ac.addAction(aa)
            self.present(ac, animated: true, completion: .none)
        }
    }
    
}

// MARK: IBActions

extension TeamPaymentViewController {
    
    @IBAction func addTeamButtonPressed(_ sender: UIBarButtonItem) {
        getPaymentToken { (token) in
            guard let t = token else { return }
            guard let uO = try? DAOUser().getUser(), let u = uO, let player = u.person?.players?.filter({$0.leagueId == self.leagueId}).first else { return }
            let playerId = player.id
            let leagueId = player.leagueId
            ServiceConnector.sharedInstance.submitPaymentTokenToBackend(t, amount: 5000, leagueId: leagueId, userId: u.id, complete: { (success, errorMessage) in
                if success {
                    ServiceConnector.sharedInstance.addTeam(name: self.teamName, color: self.teamColor.toHexString(), managerId: u.id, leagueId: leagueId, playerId: playerId)
                    self.dismiss(animated: true, completion: .none)
                } else {
                    self.presentAlert(message: errorMessage ?? "Check your internet connection and try again in a minute.")
                }
            })
        }
    }
    
}
