//
//  LoginHelperFunctions.swift
//  Airstrike
//
//  Created by Brian Nielson on 12/12/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

class LoginHelperFunctions: NSObject {
    
    class func changeRootViewController(toRootOf storyboard: UIStoryboard) {
        guard let window = UIApplication.shared.windows.first else { return }
        let desiredViewController = storyboard.instantiateInitialViewController() as? UINavigationController
        
        guard let view = window.rootViewController?.view else { return }
        
        guard let endView = desiredViewController?.view else { return }
        
        UIView.transition(from: view, to: endView, duration: 0.3, options: UIViewAnimationOptions.transitionCrossDissolve, completion: { someBool in
            window.rootViewController = desiredViewController
        })
    }
    
    class func isValidEmail(testStr: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    class func isValidPassword(testStr: String) -> Bool {
        let passwordRegEx = ".{8,50}"
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return passwordTest.evaluate(with: testStr)
    }
}
