//
//  ScrollViewPageNumber.swift
//  Airstrike
//
//  Created by Bret Smith on 12/27/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import UIKit

extension UIScrollView {
    var currentPageIndex: Int {
        return Int((self.contentOffset.x / self.frame.size.width))
    }
    
    func offsetForPageIndex(pageIndex: Int) -> CGPoint {
        return CGPoint(x: CGFloat(pageIndex) * self.frame.size.width, y: 0)
    }
}
