//
//  SignUpUnitSettingsViewController.swift
//  Airstrike
//
//  Created by BoHuang on 4/1/17.
//  Copyright © 2017 Airstrike. All rights reserved.
//

import UIKit

class SignUpUnitSettingsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate  {
    @IBOutlet weak var heightSettingLab: UILabel!
    @IBOutlet weak var heightSettingTF: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var indicateAnimator: UIActivityIndicatorView!
    
    var signupInfo: [String: Any]?
    let viewModel = SignUpUnitSettingsViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pickerView = UIPickerView()
        pickerView.delegate = self
        heightSettingTF.inputView = pickerView
        
        cancelButton.addTarget(self, action: 	#selector(dismissAction(sender:)), for: .touchUpInside)
        nextButton.addTarget(self, action: 	#selector(nextAction(sender:)), for: .touchUpInside)
        nextButton.isEnabled = false
        
        
        
        pickerView.selectRow(0, inComponent: 0, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

// Mark: UIPickerViewDataSource

extension SignUpUnitSettingsViewController{
 
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.itemCount()
    }
}

// Mark: UIPickerViewDelegate

extension SignUpUnitSettingsViewController{
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel.data(for: row)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        heightSettingTF.text = viewModel.data(for: row)
        viewModel.selectUnit(index: row)
        nextButton.isEnabled = true
    }
}

// Mark: SignUpUnitSettingsViewController Actions

extension SignUpUnitSettingsViewController{
    func dismissAction(sender: UIButton) {
        _ = navigationController?.popToRootViewController(animated: true)
    }
    
    func nextAction(sender: UIButton) {
        signupInfo?["height_unit"] = viewModel.selectedUnit
    
        self.performSegue(withIdentifier: "profileInput", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "profileInput" {
            let destination = segue.destination as? SignUpProfileInputViewController
            destination?.signupInfo = signupInfo
       
        }
    }
}
