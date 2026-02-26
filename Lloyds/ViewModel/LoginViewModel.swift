//
//  LoginViewModel.swift
//  Lloyds
//
//  Created by Manisha on 24/12/25.
//

import Foundation
import Combine
  // This one gives ThingSmartHomeManager and ThingSmartHomeModel
import AuthenticationServices


// ViewModel for login screen
class LoginViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var isLoggedIn = false
    @Published var error: String?
    @Published var  company_account_name = ""
    @Published var department = ""
    @Published var designation = ""
    private var cancellables = Set<AnyCancellable>()
    
    @Published var showErrorAlert = false
  
    @Published var userInfo: [String: Any]? = nil
    @Published var currentUser: AuthResponse?
    
    init() {
        loadSavedData()
        checkLoginStatus()
        
        NotificationCenter.default.addObserver(
               self,
               selector: #selector(handleLogout),
               name: .userDidLogout,
               object: nil
           )
        
        
    }

    func loadSavedData() {
        self.username = UserDefaults.standard.string(forKey: "savedUsername") ?? ""
    }
    

    
    @objc private func handleLogout() {
        self.isLoggedIn = false
    }
    
    
    
//    let dynamicToken = KeychainHelper.shared.getToken() ?? ""
    var dynamicToken: String {
        KeychainHelper.shared.getToken() ?? ""
    }

    func checkLoginStatus() {
            let token = KeychainHelper.shared.getToken()
            
          
            if let token = token, !token.isEmpty {
                
                if let savedUser = UserDefaultsHelper.shared.getUser() {
                    self.currentUser = savedUser
                    self.isLoggedIn = true
                } else {
                    
                    isLoggedIn = false
                }
            } else {
                isLoggedIn = false
            }
        }

        func login() {
            isLoading = true
            APIService.shared.login(username: username, password: password)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    self?.isLoading = false
                    // ... handle error
                    
                    switch completion {
                       case .failure(let error):
                           print("❌ Login Error:", error.localizedDescription)

                           self?.error = "Invalid username or password"
                           self?.showErrorAlert = true   // ✅ ALERT TRIGGER

                       case .finished:
                           break
                       }

        
                    
                } receiveValue: { [weak self] response in
                    
                    UserDefaultsHelper.shared.saveUser(response)
                    KeychainHelper.shared.saveToken(response.accessToken ?? "")
                    
                    let userType = response.customRoles.first ?? ""
                        UserDefaults.standard.set(userType, forKey: "loggedInUserType")
                        print("✅ Saved userType:", userType) // → AREA_OWNER print hoga
                    
                    self?.currentUser = response
                    self?.isLoggedIn = true
                    
                    NotificationCenter.default.post(name: .userDidLogin, object: nil)
                }
                .store(in: &cancellables)
        }
    }
    



extension Notification.Name {
    static let userDidLogin = Notification.Name("userDidLogin")
}
