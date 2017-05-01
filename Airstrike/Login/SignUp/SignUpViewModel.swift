//
//  SignUpViewModel.swift
//  Airstrike
//
//  Created by Brian Nielson on 1/18/17.
//  Copyright © 2017 Airstrike. All rights reserved.
//

import UIKit

class SignUpViewModel {
    
    typealias completionHandler = (_ success: Bool) -> ()

    enum PageType: Int {
        case email, password, firstName, lastName, playerNumber, playerDescription
    }
    
    fileprivate var currentPage = PageType.email
    
    var pages: [PageType] = [.email, .password, .firstName, .lastName, .playerNumber, .playerDescription]
    var type = "player"
    
    var email: String?
    var firstName: String?
    var lastName: String?
    var password: String?
    var playerNumber: String?
    var description: String?
    var leagues: [League]?

}

// MARK: - Helper functions

extension SignUpViewModel {
    
    func nextButtonPressed(input: String, completion: @escaping completionHandler) {
        switch currentPage {
        case .email:
            email = input
            completion(true)
        case .firstName:
            firstName = input
            completion(true)
        case .lastName:
            lastName = input
            completion(true)
        case .password:
            password = input
            completion(true)
        case.playerNumber:
            playerNumber = input
            completion(true)
        case.playerDescription:
            description = input
            completion(true)
        }
    }
    
    func getCurrentPage() -> PageType {
        return currentPage
    }
    
    fileprivate func setupForNextPage() {
        if currentPage == .email {
            currentPage = .password
        } else {
            if let index = pages.index(of: currentPage) {
                currentPage = pages[index + 1]
            }
        }
    }
}

// MARK: - Getters

extension SignUpViewModel {
    
    func getPromptText() -> String {
        let prompt: String
        switch currentPage {
        case .email:
            prompt = "Enter your email address:"
        case .firstName:
            prompt = "Enter your first name:"
        case .lastName:
            prompt = "Enter your last name:"
        case .password:
            prompt = "Choose a password (8-50 characters):"
        case .playerNumber:
            prompt = "Enter a number between 0-99:"
        case .playerDescription:
            prompt = "Enter a brief description of yourself:"
        }
        return prompt
    }
    
    func getPlaceholderText() -> String {
        let placeholder: String
        switch currentPage {
        case .email:
            placeholder = "Email"
        case .firstName:
            placeholder = "First name"
        case .lastName:
            placeholder = "Last name"
        case .password:
            placeholder = "Password"
        case .playerNumber:
            placeholder = "Player Number"
        case .playerDescription:
            placeholder = "Player Description"
        }
        return placeholder
    }
    
    func shouldActivateNextButton(given input: String) -> Bool {
        let isValidInput: Bool
        switch currentPage {
        case .email:
            isValidInput = LoginHelperFunctions.isValidEmail(testStr: input)
        case .password:
            isValidInput = LoginHelperFunctions.isValidPassword(testStr: input)
        case .firstName, .lastName:
            isValidInput = input != ""
        case .playerNumber:
            isValidInput = (input != "" && input.characters.count < 3)
        case .playerDescription:
            isValidInput = input != ""
        }
        return isValidInput
    }
    
    func getKeyboardType() -> UIKeyboardType {
        let keyboardType: UIKeyboardType
        switch currentPage {
        case .email:
            keyboardType = .emailAddress
        case .password, .firstName, .lastName, .playerDescription:
            keyboardType = .default
        case .playerNumber:
            keyboardType = .numberPad
        }
        return keyboardType
    }
    
    func needsSecureEntry() -> Bool {
        return currentPage == .password
    }
    
    func shouldGoToAnotherSignUpInputView() -> Bool {
        var shouldGo = true
        if currentPage == .playerDescription && type == "player" {
            shouldGo = false
        } else if currentPage == .lastName && type == "nonPlayer" {
            shouldGo = false
        } else {
            setupForNextPage()
        }
        return shouldGo
    }
    
    func isFirstController() -> Bool {
        var isFirst = false
        if currentPage == .email {
                isFirst = true
        }
        return isFirst
    }
}

