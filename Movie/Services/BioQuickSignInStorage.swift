//
//  BioQuickSignInStorage.swift
//  Movie
//
//  Created by ekaterina.shevchenko on 10.05.2026.
//

import Foundation

enum BioQuickSignInStorage {
    private static let key = "bio_quick_sign_in_enabled"
    
    static var isEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key)}
    }
    
    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
