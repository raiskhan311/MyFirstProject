//
//  CleanDouble.swift
//  Airstrike
//
//  Created by Jeffrey K Lewis on 12/22/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import Foundation

extension Double {
    var cleanValue: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}
