//
//  KeychainHelper.swift
//  Airstrike
//
//  Created by Bret Smith on 1/24/17.
//  Copyright © 2017 Airstrike. All rights reserved.
//

import Foundation
import Security
class KeychainHelper {
    
    class func get(_ key: String) -> String? {
        guard let data = getData(key), let value = String(data: data, encoding: String.Encoding.utf8) else { return .none }
        return value
    }
    
    private class func getData(_ key: String) -> Data? {
        
        let query: [String: Any] = [
            kSecClass as String         : kSecClassGenericPassword,
            kSecAttrAccount as String   : key,
            kSecReturnData as String    : kCFBooleanTrue,
            kSecMatchLimit as String    : kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        
        let resultCode = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        
        guard resultCode == noErr else { return .none }
        
        return result as? Data
    }
    
    
    class func set(_ value: Data, forKey key: String) {
        
        delete(key)
        
        let query: [String : Any] = [
            kSecClass as String             : kSecClassGenericPassword,
            kSecAttrAccount as String       : key,
            kSecValueData as String         : value,
            kSecAttrAccessible as String    : kSecAttrAccessibleWhenUnlocked
        ]
        
        _ = SecItemAdd(query as CFDictionary, nil)
        
    }
    
    class func delete(_ key: String) {
        
        let query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key
        ]
        
        _ = SecItemDelete(query as CFDictionary)
        
    }
    
}
