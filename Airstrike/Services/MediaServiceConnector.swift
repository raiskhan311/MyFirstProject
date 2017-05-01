//
//  MediaServiceConnector.swift
//  Airstrike
//
//  Created by Jeffrey K Lewis on 1/4/17.
//  Copyright © 2017 Airstrike. All rights reserved.
//

import Foundation
import ZiggeoSwiftFramework

class MediaServiceConnector: NSObject {
    
    class var sharedInstance: MediaServiceConnector {
        struct Singleton {
            static let instance = MediaServiceConnector()
        }
        return Singleton.instance
    }
    
    var ziggeo: Ziggeo! = Ziggeo(token: Constants.ziggeoToken)
    
}
