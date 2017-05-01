//
//  AddTeamViewController.swift
//  Airstrike
//
//  Created by Bret Smith on 1/20/17.
//  Copyright © 2017 Airstrike. All rights reserved.
//

import UIKit

class AddTeamViewController: UIViewController {
    @IBOutlet weak var teamColorView: UIView!
    @IBOutlet weak var teamNameTextField: UITextField!
    @IBOutlet weak var colorPicker: HSBColorPicker!
//    @IBOutlet weak var teamNameUnderlineView: UIView!
    var leagueId = "No League Id"
    var teamColorSelected = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        colorPicker.delegate = self
        teamNameTextField.delegate = self
        self.leagueId = ServiceConnector.sharedInstance.getDisplayLeague()?.id ?? "No League Id"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

// MARK: IBActions

extension AddTeamViewController {
    
    @IBAction func closeBarButtonAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: .none)
    }
    
    @IBAction func continueButtonClicked(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "teamPayment", sender: self)
    }
        
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        if sender.text != "" && teamColorSelected {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
}

// MARK: Segue Preparation 

extension AddTeamViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let newController = segue.destination as? TeamPaymentViewController
        newController?.configureTeamDetails(color: self.teamColorView.backgroundColor, name: teamNameTextField.text, leagueId: leagueId)
    }
}

// MARK: Color Picker Delegate

extension AddTeamViewController: HSBColorPickerDelegate {
    func HSBColorColorPickerTouched(sender:HSBColorPicker, color: UIColor, point:CGPoint, state:UIGestureRecognizerState) {
        teamColorSelected = true
        self.teamColorView.backgroundColor = color
        teamNameTextField.textColor = color.findBestTextColorForBackgroundColor()
//        teamNameUnderlineView.backgroundColor = color.findBestTextColorForBackgroundColor()
        let backgroundColor = color.findBestTextColorForBackgroundColor()
        let placeHolderColor = UIColor(colorLiteralRed: Float(backgroundColor.components.red), green: Float(backgroundColor.components.green), blue: Float(backgroundColor.components.blue), alpha: 0.5)
        teamNameTextField.setValue(placeHolderColor, forKeyPath: "_placeholderLabel.textColor")
        
        if teamNameTextField.text != "" && teamColorSelected {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
}

// MARK: - UITextFieldDelegate

extension AddTeamViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == teamNameTextField {
            teamNameTextField.resignFirstResponder()
        }
        return false
    }
    
}
