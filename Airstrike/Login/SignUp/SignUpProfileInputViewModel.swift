//
//  SignUpProfileInputViewModel.swift
//  Airstrike
//
//  Created by BoHuang on 4/1/17.
//  Copyright © 2017 Airstrike. All rights reserved.
//

import UIKit

class SignUpProfileInputViewModel {
    
    
    typealias completionHandler = (_ success: Bool) -> ()
    
    enum PageType: Int {
        case height, weight, fourtyTime, benchPress, verticalJump, fiveTenFive
    }
    
    fileprivate var currentPage = PageType.height
    
    var pages: [PageType] = [.height, .weight, .fourtyTime, .benchPress, .verticalJump, .fiveTenFive]
    
    var type = "player"
    var heightUnit: String?
    var height: String?
    var weight: String?
    var fourtyTime: String?
    var benchPress: String?
    var verticalJump: String?
    var fiveTenFive: String?
    
    var email: String?
    var firstName: String?
    var lastName: String?
    var password: String?
    var playerNumber: String?
    var description: String?
    
    
}

// MARK: - Helper functions

extension SignUpProfileInputViewModel {
    
    func nextButtonPressed(input: String, completion: @escaping completionHandler) {
        switch currentPage {
        case .height:
            height = input
            completion(true)
        case .weight:
            weight = input
            completion(true)
        case .fourtyTime:
            fourtyTime = input
            completion(true)
        case .benchPress:
            benchPress = input
            completion(true)
        case.verticalJump:
            verticalJump = input
            completion(true)
        case .fiveTenFive:
            fiveTenFive = input
            completion(true)
        default: break
        }
    }
    
    func getCurrentPage() -> PageType {
        return currentPage
    }
    
    fileprivate func setupForNextPage() {
        if currentPage == .height {
            currentPage = .weight
        } else {
            if let index = pages.index(of: currentPage	) {
                currentPage = pages[index + 1]
            }
        }
    }
}

// MARK: - Getters

extension SignUpProfileInputViewModel {
    func getUnitText() -> String {
        let unit: String
        switch currentPage {
        case .height:
            unit = heightUnit ?? "";
        case .weight:
            unit = "found"
        case .fourtyTime:
            unit = "s"
        case .benchPress:
            unit = "s"
        case .verticalJump:
            unit = heightUnit ?? "";
        case .fiveTenFive:
            unit = "s"
        
        }
        return unit
    }
    
    func getPromptText() -> String {
        let prompt: String
        switch currentPage {
        case .height:
            prompt = "Enter your height:"
        case .weight:
            prompt = "Enter your weight:"
        case .fourtyTime:
            prompt = "Enter your 40 time:"
        case .benchPress:
            prompt = "Enter your 185 bench press:"
        case .verticalJump:
            prompt = "Enter your vertical jump:"
        case .fiveTenFive:
            prompt = "Enter your 5-10-5:"
        }
        return prompt
    }
    
    func getPlaceholderText() -> String {
        let placeholder: String
        switch currentPage {
        case .height:
            placeholder = "Height"
        case .weight:
            placeholder = "Weight"
        case .fourtyTime:
            placeholder = "185 bench press"
        case .benchPress:
            placeholder = "Vertical Jump"
        case .verticalJump:
            placeholder = "Player Number"
        case .fiveTenFive:
            placeholder = "5-10-5"
        }
        return placeholder
    }
    
    func shouldActivateNextButton(given input: String) -> Bool {
        let isValidInput: Bool
        switch currentPage {
        case .height:
            isValidInput = input != ""
        case .weight:
            isValidInput = input != ""
        case .fourtyTime:
            isValidInput = input != ""
        case .benchPress:
            isValidInput = input != ""
        case .verticalJump:
            isValidInput = input != ""
        case .fiveTenFive:
            isValidInput = input != ""
            
        }
        return isValidInput
    }
    
    func getKeyboardType() -> UIKeyboardType {
        let keyboardType: UIKeyboardType
        switch currentPage {
        case .height, .weight, .fourtyTime, .benchPress, .verticalJump, .fiveTenFive:
            keyboardType = .numberPad
        }
        return keyboardType
    }
    
    func needsSecureEntry() -> Bool {
        return false
    }
    
    func shouldGoToAnotherSignUpInputView() -> Bool {
        var shouldGo = true
        if currentPage == .fiveTenFive {
            shouldGo = false
        } else {
          setupForNextPage()
        }
        /*if currentPage == .playerDescription && type == "player" {
            shouldGo = false
        } else if currentPage == .lastName && type == "nonPlayer" {
            shouldGo = false
        } else {
         
        }*/
        return shouldGo
    }
    
    func isFirstController() -> Bool {
        var isFirst = false
        if currentPage == .height {
            isFirst = true
        }
        return isFirst
    }
}
