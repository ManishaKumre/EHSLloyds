//
//  AppStateManager.swift
//  Lloyds
//
//  Created by Manisha on 24/12/25.
//


import SwiftUI
import Combine

class AppStateManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var isInsidePNE: Bool = true
    @Published var navigateToAccount: Bool = false

    init() {
        let token = KeychainHelper.shared.getToken()
          print("App Start Token:", token ?? "nil")
        
        
        checkLoginStatus()
    }
    
//    func checkLoginStatus() {
//        isLoggedIn = UserDefaultsHelper.shared.getUser() != nil
//    }
    
    func checkLoginStatus() {
        let token = KeychainHelper.shared.getToken()
        
        if let token = token, !token.isEmpty {
            isLoggedIn = true
        } else {
            isLoggedIn = false
        }
    }
    
    func logout() {
        KeychainHelper.shared.clearToken()
        UserDefaultsHelper.shared.clearUser()
        
        // ✅ Main thread pe UI update karein
        DispatchQueue.main.async {
            self.isLoggedIn = false
        }
    }
    
    func login() {
        DispatchQueue.main.async {
            self.isLoggedIn = true
        }
    }
}
