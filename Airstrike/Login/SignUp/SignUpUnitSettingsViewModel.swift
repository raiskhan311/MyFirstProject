//
//  SignUpUnitSettingsViewModel.swift
//  Airstrike
//
//  Created by BoHuang on 4/1/17.
//  Copyright © 2017 Airstrike. All rights reserved.
//

import Foundation
class SignUpUnitSettingsViewModel {
    var selectedUnit = "fit"
    var unitPickOptions = ["fit", "inch"]
    
}

extension SignUpUnitSettingsViewModel {
    
    func itemCount() -> Int {
        return unitPickOptions.count
    }
    
    
    func data(for index: Int) -> String {
        
        return unitPickOptions[index]
    }
    func selectUnit(index: Int) {
        selectedUnit = unitPickOptions[index]
    }
}
