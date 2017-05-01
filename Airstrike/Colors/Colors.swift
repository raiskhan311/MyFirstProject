//
//  Colors.swift
//  Airstrike
//
//  Created by Brian Nielson on 12/7/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

class Colors {
    
    // Text Colors
    static let darkTextColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    static let mediumTextColor = #colorLiteral(red: 0.4549019608, green: 0.4549019608, blue: 0.4549019608, alpha: 1)
    static let lightTextColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    
    // Colors Used throughout the app
    static let airstrikeDarkColor = #colorLiteral(red: 0.05709137768, green: 0.0961606428, blue: 0.1299809217, alpha: 1)
    static let tableViewCellDividerColor = #colorLiteral(red: 0.9294117647, green: 0.9333333333, blue: 0.9176470588, alpha: 1)
    
    // Login Colors
    static let loginSeparatorColor = #colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 1)
    static let loginTextColor = #colorLiteral(red: 0.537254902, green: 0.537254902, blue: 0.537254902, alpha: 1)
    static let defaultDarkColor = #colorLiteral(red: 0.3333333333, green: 0.3333333333, blue: 0.3333333333, alpha: 1)
    static let errorColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
    
    // Onboarding Colors
    static let onboardingButtonColor = #colorLiteral(red: 0.4549019608, green: 0.4745098039, blue: 0.4901960784, alpha: 1)
    
    // Profile Colors
    static let profileDetailsBackgroundViewColor = #colorLiteral(red: 0.662745098, green: 0.662745098, blue: 0.662745098, alpha: 1)
    
    // Team Colors
//    static let teamRedColor = #colorLiteral(red: 0.7647058824, green: 0, blue: 0.0862745098, alpha: 1)
//    static let teamBlueColor = #colorLiteral(red: 0.231372549, green: 0.4784313725, blue: 0.8588235294, alpha: 1)
//    static let teamGreenColor = #colorLiteral(red: 0.431372549, green: 0.8078431373, blue: 0.1019607843, alpha: 1)
//    static let teamYellowColor = #colorLiteral(red: 0.9647058824, green: 0.8980392157, blue: 0.09411764706, alpha: 1)
//    static let teamPurpleColor = #colorLiteral(red: 0.4823529412, green: 0, blue: 0.9921568627, alpha: 1)
//    static let teamOrangeColor = #colorLiteral(red: 0.9450980392, green: 0.5882352941, blue: 0.1098039216, alpha: 1)
    
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(hex netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
    
    func findBestTextColorForBackgroundColor() -> UIColor {
        let components = self.cgColor.components
        
        var brightness = 0.0
        if let count = components?.count, count > 2, let redC = components?[0], let greenC = components?[1], let blueC = components?[2] {
            let r = redC * 299
            let g = greenC * 587
            let b = blueC * 114
            brightness = (Double(r) + Double(g) + Double(b)) / 1000.0
        }
        
        
        if brightness < 0.5 {
            return UIColor.white
        } else {
            return UIColor.black
        }
    }
    
}
