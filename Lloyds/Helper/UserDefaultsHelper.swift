//
//  UserDefaultsHelper.swift
//  Lloyds
//
//  Created by Manisha on 23/12/25.
//

import Foundation

class UserDefaultsHelper {
    static let shared = UserDefaultsHelper()
    private let userKey = "loggedInUser"
    //    private let passwordKey = "userPassword"
    func saveUser(_ user: AuthResponse) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: userKey)
        }
        
    }
    
    func getUser() -> AuthResponse? {
        if let savedData = UserDefaults.standard.data(forKey: userKey),
           let user = try? JSONDecoder().decode(AuthResponse.self, from: savedData) {
            return user
        }
        return nil
    }
    
    func clearUser() {
        UserDefaults.standard.removeObject(forKey: userKey)
    }
}
