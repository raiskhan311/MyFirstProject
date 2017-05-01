//
//  SignUpTableViewController.swift
//  Airstrike
//
//  Created by Brian Nielson on 1/18/17.
//  Copyright © 2017 Airstrike. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class SignUpTableViewController: UITableViewController {
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var responseTextField: UITextField!
    @IBOutlet weak var inputSeparatorView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //Create Action Button for Facebook and Twitter Signup 
    var dict : [String : AnyObject]!
    @IBAction func btn_SignupbyFacebook(_ sender: Any) {
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                if fbloginresult.grantedPermissions != nil {
                    if(fbloginresult.grantedPermissions.contains("email"))
                    {
                        self.getFBUserData()
                        fbLoginManager.logOut()
                    }
                }
            }
        }
    }
    func getFBUserData(){
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    self.dict = result as! [String : AnyObject]
                    print(result!)
                    print(self.dict)
                }
            })
        }
    }
    @IBAction func btn_SignupbyTwitter(_ sender: Any) {
        
    }
    
    var viewModel = SignUpViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if viewModel.isFirstController() {
            ServiceConnector.sharedInstance.getLeagues(complete: { (success, leagues) in
                if success {
                    NotificationCenter.default.post(name:Notification.Name(rawValue:"LeaguesRetrieved"), object: nil, userInfo: ["leagues" : leagues as Any])
                }
            })
        }
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue:"LeaguesRetrieved"), object: nil, queue: .none, using: setLeagues)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setContent()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    fileprivate func postNotification (notificationType: Notification.Name, userInfo: [NSObject: AnyObject]?) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: notificationType, object: self, userInfo: userInfo)
        }
    }
}

// MARK: - Setup

extension SignUpTableViewController {
    
    fileprivate func setContent() {
        nextButton.isEnabled = viewModel.shouldActivateNextButton(given: responseTextField.text ?? "")
        nextButton.setTitleColor(Colors.loginTextColor, for: .disabled)
        nextButton.setTitleColor(Colors.airstrikeDarkColor, for: .normal)
        promptLabel.text = viewModel.getPromptText()
        responseTextField.placeholder = viewModel.getPlaceholderText()
        responseTextField.isSecureTextEntry = viewModel.needsSecureEntry()
        responseTextField.keyboardType = viewModel.getKeyboardType()
        responseTextField.becomeFirstResponder()
    }
    
}

// MARK: - Helpers

extension SignUpTableViewController {
    
    fileprivate func goToNextPage() {
        if viewModel.shouldGoToAnotherSignUpInputView() {
            let sb = UIStoryboard(name: "SignUp", bundle: .none)
            guard let vc = sb.instantiateInitialViewController() as? SignUpTableViewController else { return }
            vc.viewModel = self.viewModel
            if vc.viewModel.getCurrentPage() == .lastName && vc.viewModel.type == "nonPlayer" {
//                vc.nextButton.setTitle("Finish", for: .normal)
            }
            navigationController?.pushViewController(vc, animated: true)
        } else {
            if viewModel.type == "nonPlayer" {
                activityIndicator.startAnimating()
                if let email = viewModel.email,
                    let password = viewModel.password,
                    let firstName = viewModel.firstName,
                    let lastName = viewModel.lastName {
                    ServiceConnector.sharedInstance.signup(email: email, password: password, firstName: firstName, lastName: lastName, description: .none, playerNumber: .none, leagueId: .none, complete: { (success) in
                        if success {
                            DispatchQueue.main.async {
                                self.postNotification(notificationType: ServiceNotificationType.userLoggedIn, userInfo: .none)
                                self.performSegue(withIdentifier: "mainSegue", sender: self)
                            }
                        }
                    })
                }
            } else {
                self.performSegue(withIdentifier: "unitSetting", sender: nil)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chooseLeague" {
            let destination = segue.destination as? SignUpLeagueChooserTableViewController
            var signupInfo = [String:Any]()
            signupInfo["email"] = viewModel.email
            signupInfo["password"] = viewModel.password
            signupInfo["firstName"] = viewModel.firstName
            signupInfo["lastName"] = viewModel.lastName
            signupInfo["playerNumber"] = viewModel.playerNumber
            signupInfo["description"] = viewModel.description
            destination?.leagues = self.viewModel.leagues
            destination?.signupInfo = signupInfo
        }
        
        if segue.identifier == "unitSetting" {
            let destination = segue.destination as? SignUpUnitSettingsViewController
            var signupInfo = [String:Any]()
            signupInfo["email"] = viewModel.email
            signupInfo["password"] = viewModel.password
            signupInfo["firstName"] = viewModel.firstName
            signupInfo["lastName"] = viewModel.lastName
            signupInfo["playerNumber"] = viewModel.playerNumber
            signupInfo["description"] = viewModel.description
            destination?.signupInfo = signupInfo
        }
    }
    
    func setLeagues(notification: Notification) -> Void {
        if let leagues = notification.userInfo?["leagues"] as? [League] {
            self.viewModel.leagues = leagues
        }
    }
}

// MARK: - Text Field Delegates

extension SignUpTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let shouldReturn = viewModel.shouldActivateNextButton(given: responseTextField.text ?? "")
        if shouldReturn {
            nextButtonAction(nextButton)
        }
        return shouldReturn
    }
    
}

// MARK: - Actions

extension SignUpTableViewController {
    
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
    
    @IBAction func responseTextFieldEditingDidChangeAction(_ sender: UITextField) {
        nextButton.isEnabled = viewModel.shouldActivateNextButton(given: sender.text ?? "")
    }
    
}

