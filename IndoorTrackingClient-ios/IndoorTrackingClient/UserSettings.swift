//
//  UserSettings.swift
//  IndoorTrackingClient
//
//  Created by Phillip McKenna on 29/9/17.
//  Copyright © 2017 IDC. All rights reserved.
//

import Foundation

class UserSettings {
    
    // Singleton
    static var shared = UserSettings()
    
    // Members
    private(set) var currentUser: User?
    
    // Login
    func login(user: User) -> Bool {
        guard currentUser == nil else {
            // Already logged in.
            return false
        }
        
        self.currentUser = user
        return true
    }
}
