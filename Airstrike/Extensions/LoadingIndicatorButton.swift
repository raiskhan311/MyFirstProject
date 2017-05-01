//
//  LoadingIndicatorButton.swift
//  Airstrike
//
//  Created by Jeffrey K Lewis on 2/15/17.
//  Copyright © 2017 Airstrike. All rights reserved.
//

import UIKit

extension UIButton {
    
    func loadingIndicator(show: Bool) {
        if show {
            self.titleLabel?.alpha = 0.0
            let indicator = UIActivityIndicatorView()
            indicator.center = CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
            self.addSubview(indicator)
            indicator.startAnimating()
        } else {
            self.titleLabel?.alpha = 1.0
            if let indicator = self.subviews.filter({ ($0 as? UIActivityIndicatorView) != .none }).first as? UIActivityIndicatorView {
                indicator.stopAnimating()
                indicator.removeFromSuperview()
            }
        }
    }
    
}
