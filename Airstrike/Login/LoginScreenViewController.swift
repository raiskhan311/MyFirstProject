//
//  LoginScreenViewController.swift
//  Airstrike
//
//  Created by Brian Nielson on 12/7/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

class LoginScreenViewController: UITableViewController {

    @IBOutlet weak var loginImage: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var emailHintLabel: UILabel!
    @IBOutlet weak var passwordHintLabel: UILabel!
    
    @IBOutlet weak var mailIconImageView: UIImageView!
    @IBOutlet weak var lockIconImageView: UIImageView!
    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var tableFooterView: UIView!
    // Lines(Views) that can change color if there is an error
    @IBOutlet weak var emailLineView: UIView!
    @IBOutlet weak var passwordLineView: UIView!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
        
    
    // MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTableViewFooterHeight()
        setupColors()
        setupHintLabels()
        addNotificationObservers()
        
        emailTextField.text = "zander95@gmail.com"
        passwordTextField.text = "Honeybadger11"
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

// MARK: - Helper Functions

extension LoginScreenViewController {
    
    fileprivate func setTableViewFooterHeight() {
        tableFooterView.frame.size = CGSize(width: view.frame.width, height: view.frame.height - 264)// 264 is the height of the other views
    }
    
    fileprivate func setupHintLabels() {
        emailHintLabel.isHidden = true
        passwordHintLabel.isHidden = true
        changeColorError(emailLineView: .none, passwordLineView: .none, emailHintLabel: emailHintLabel, passwordHintLabel: passwordHintLabel)
    }
    
    fileprivate func checkEmailAndLogin() -> Bool {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return false }
        if email == password {
            changeColorCorrect(emailLineView: emailLineView, passwordLineView: passwordLineView)
            return true
        } else {
            changeColorError(emailLineView: emailLineView, passwordLineView: passwordLineView, emailHintLabel: .none, passwordHintLabel: .none)
            return false
        }
    }
    
    fileprivate func showInvalidEmailHint() {
        changeColorError(emailLineView: emailLineView, passwordLineView: .none, emailHintLabel: .none, passwordHintLabel: .none)
        emailHintLabel.isHidden = false
    }
    
    fileprivate func showValidEmail() {
        changeColorCorrect(emailLineView: emailLineView, passwordLineView: .none)
        emailHintLabel.isHidden = true
    }
    
    fileprivate func showInvalidEmailOrPassword() {
        changeColorError(emailLineView: emailLineView, passwordLineView: passwordLineView, emailHintLabel: .none, passwordHintLabel: .none)
        passwordHintLabel.isHidden = false
    }
    
    fileprivate func presentIncorrectLoginAlert() {
        let alert = UIAlertController(title: "Incorrect Username or Password", message: "The username or password entered is not correct.", preferredStyle: .alert)
        let button = UIAlertAction(title: "OK", style: .default, handler: .none)
        alert.addAction(button)
        present(alert, animated: true, completion: .none)
    }
    
}

// MARK: - Color changing functions

extension LoginScreenViewController {
    
    fileprivate func setupColors() {
        loginButton.tintColor = Colors.lightTextColor
        loginButton.backgroundColor = Colors.airstrikeDarkColor
        
        signUpButton.tintColor = Colors.lightTextColor
        signUpButton.backgroundColor = Colors.loginTextColor
        
        emailLineView.backgroundColor = Colors.tableViewCellDividerColor
        passwordLineView.backgroundColor = Colors.tableViewCellDividerColor
    }
    
    fileprivate func changeColorError(emailLineView: UIView?, passwordLineView: UIView?, emailHintLabel: UILabel?, passwordHintLabel: UILabel?) {
        emailLineView?.backgroundColor = Colors.errorColor
        passwordLineView?.backgroundColor = Colors.errorColor
        emailHintLabel?.textColor = Colors.errorColor
        passwordHintLabel?.textColor = Colors.errorColor
    }
    
    fileprivate func changeColorCorrect(emailLineView: UIView?, passwordLineView: UIView?) {
        emailLineView?.backgroundColor = Colors.tableViewCellDividerColor
        passwordLineView?.backgroundColor = Colors.tableViewCellDividerColor
    }
    
}

// MARK: - UITextFieldDelegate

extension LoginScreenViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            textField.resignFirstResponder()
            loginButtonAction(self)
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
    
}

// MARK: - NSNotification Methods

extension LoginScreenViewController {
    
    fileprivate func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(invalidUserNameOrPassword(notification:)), name: ServiceNotificationType.invalidUsernameOrPassword, object: .none)
        
        NotificationCenter.default.addObserver(self, selector: #selector(userLoggedIn(notification:)), name: ServiceNotificationType.userLoggedIn, object: .none)
    }
    
    func invalidUserNameOrPassword(notification: NSNotification) {
        showInvalidEmailOrPassword()
    }
    
    func userLoggedIn(notification: NSNotification) {
        self.performSegue(withIdentifier: "loginToMain", sender: nil)
    }
    
    fileprivate func postNotification (notificationType: Notification.Name, userInfo: [NSObject: AnyObject]?) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: notificationType, object: self, userInfo: userInfo)
        }
    }
    
}

// MARK: - IBActions

extension LoginScreenViewController {
    
    @IBAction func loginButtonAction(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        
        self.loginButton.loadingIndicator(show: true)
        ServiceConnector.sharedInstance.login(email: email, password: password) { (success) in
            if success {
                self.postNotification(notificationType: ServiceNotificationType.userLoggedIn, userInfo: .none)
            } else {
                DispatchQueue.main.async {
                    self.loginButton.loadingIndicator(show: false)
                    self.presentIncorrectLoginAlert()
                }
            }
        }
    }
    
    @IBAction func signUPButtonAction(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func emailTextFieldDidEndEditingAction(_ sender: UITextField) {
        guard let t = sender.text else { return }
        if (LoginHelperFunctions.isValidEmail(testStr: t)) {
            showValidEmail()
        } else {
            showInvalidEmailHint()
        }
    }
    
}
