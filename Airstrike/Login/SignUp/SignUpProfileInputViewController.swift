//
//  SignUpProfileInputViewController.swift
//  Airstrike
//
//  Created by BoHuang on 4/1/17.
//  Copyright © 2017 Airstrike. All rights reserved.
//

import UIKit

class SignUpProfileInputViewController: UIViewController {
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var responseTextField: UITextField!
    @IBOutlet weak var inputSeparatorView: UIView!
    @IBOutlet weak var unitText: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var viewModel = SignUpProfileInputViewModel()

    var signupInfo: [String: Any]?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setContent()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func responseTextChanged(_ sender: Any) {
        nextButton.isEnabled = viewModel.shouldActivateNextButton(given: (sender as! UITextField).text ?? "")

    }

}

// MARK: - Setup

extension SignUpProfileInputViewController {
    
    fileprivate func setContent() {
        if(signupInfo != nil){
            viewModel.heightUnit = signupInfo?["height_unit"] as? String;
            viewModel.email = signupInfo?["email"] as? String;
            viewModel.password = signupInfo?["password"] as? String;
            viewModel.firstName = signupInfo?["firstName"] as? String;
            viewModel.lastName = signupInfo?["lastName"] as? String;
            viewModel.playerNumber = signupInfo?["playerNumber"] as? String;
            viewModel.description = signupInfo?["description"] as? String;
        }

        
        nextButton.isEnabled = viewModel.shouldActivateNextButton(given: responseTextField.text ?? "")
        nextButton.setTitleColor(Colors.loginTextColor, for: .disabled)
        nextButton.setTitleColor(Colors.airstrikeDarkColor, for: .normal)
        promptLabel.text = viewModel.getPromptText()
        responseTextField.placeholder = viewModel.getPlaceholderText()
        responseTextField.isSecureTextEntry = viewModel.needsSecureEntry()
        responseTextField.keyboardType = viewModel.getKeyboardType()
        responseTextField.becomeFirstResponder()
        
        unitText.text = viewModel.getUnitText();

        
    }
    
}

// MARK: - Helpers

extension SignUpProfileInputViewController {
    
    fileprivate func goToNextPage() {
        if viewModel.shouldGoToAnotherSignUpInputView() {
            let sb = UIStoryboard(name: "SignUp", bundle: .none)
            guard let vc = sb.instantiateViewController(withIdentifier: "SignUpProfileInputViewController") as? SignUpProfileInputViewController else { return }
            vc.viewModel = self.viewModel
            navigationController?.pushViewController(vc, animated: true)
        } else {
             self.performSegue(withIdentifier: "chooseLeague", sender: nil)
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chooseLeague" {
            let destination = segue.destination as? SignUpLeagueChooserTableViewController
             var signupInfo = [String:Any]()
            signupInfo["height"] = viewModel.height
            signupInfo["weight"] = viewModel.weight
            signupInfo["fourtyTime"] = viewModel.fourtyTime
            signupInfo["benchPress"] = viewModel.benchPress
            signupInfo["verticalJump"] = viewModel.verticalJump
            signupInfo["fiveTenFive"] = viewModel.fiveTenFive
            signupInfo["email"] = viewModel.email
            signupInfo["password"] = viewModel.password
            signupInfo["firstName"] = viewModel.firstName
            signupInfo["lastName"] = viewModel.lastName
            signupInfo["playerNumber"] = viewModel.playerNumber
            signupInfo["description"] = viewModel.description
            destination?.signupInfo = signupInfo
        }
        

    }
    
   /* func setLeagues(notification: Notification) -> Void {
        if let leagues = notification.userInfo?["leagues"] as? [League] {
            self.viewModel.leagues = leagues
        }
    }*/
}


// MARK: - Text Field Delegates

extension SignUpProfileInputViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let shouldReturn = viewModel.shouldActivateNextButton(given: responseTextField.text ?? "")
        if shouldReturn {
            nextButtonAction(nextButton)
        }
        return shouldReturn
    }
    
}

// MARK: - Actions

extension SignUpProfileInputViewController {
    
    @IBAction func cancelButtonAction(_ sender: UIButton) {
        _ = navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func nextButtonAction(_ sender: UIButton) {
        activityIndicator.startAnimating()
        responseTextField.isEnabled = false
        viewModel.nextButtonPressed(input: responseTextField.text ?? "") { (success) in
            DispatchQueue.main.async {
                if success {
                    self.goToNextPage()
                } else {
                    self.activityIndicator.stopAnimating()
                    let alertController = UIAlertController(title: "Error", message: "Make sure your input is correct and you are connected to the internet.", preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "OK", style: .default, handler: .none)
                    alertController.addAction(alertAction)
                    self.present(alertController, animated: true, completion: .none)
                }
            }
        }
    }
    
 
    
}
