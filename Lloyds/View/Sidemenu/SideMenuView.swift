//
//  Untitled.swift
//  Lloyds
//
//  Created by Manisha on 19/02/26.
//

//import SwiftUI
//import UIKit
//
//
//struct SideMenuView: View {
//
//    @Binding var showMenu: Bool
//    var username: String
//
//    var body: some View {
//        ZStack(alignment: .leading) {
//
//            // Background blur
//            Color.black.opacity(0.4)
//                .ignoresSafeArea()
//                .onTapGesture {
//                    withAnimation(.easeInOut) {
//                        showMenu = false
//                    }
//                }
//
//            // Menu Panel
//            VStack(alignment: .leading, spacing: 30) {
//
//                // 👤 User Header
//                VStack(alignment: .leading, spacing: 8) {
//                    Circle()
//                        .fill(Color.blue.opacity(0.2))
//                        .frame(width: 60, height: 60)
//                        .overlay(
//                            Text(String(username.prefix(1)))
//                                .font(.title)
//                                .bold()
//                                .foregroundColor(.blue)
//                        )
//
//                    Text(username)
//                        .font(.headline)
//
//                    Text("View Profile")
//                        .font(.footnote)
//                        .foregroundColor(.gray)
//                }
//                .padding(.top, 60)
//
//                Divider()
//
//                // 📋 Menu Items
//                VStack(alignment: .leading, spacing: 25) {
//
//                    menuRow(icon: "person.crop.circle", title: "Account")
//
//                    menuRow(icon: "lock.shield", title: "Privacy Policy")
//
//                    menuRow(icon: "arrow.backward.circle", title: "Logout", isLogout: true)
//                }
//
//                Spacer()
//            }
//            .padding(.horizontal, 24)
//            .frame(width: 280)
//            .background(
//                RoundedRectangle(cornerRadius: 30)
//                    .fill(Color.white)
//                    .shadow(radius: 10)
//            )
//            .ignoresSafeArea()
//            .transition(.move(edge: .leading))
//        }
//    }
//
//    // MARK: Menu Row
//    private func menuRow(icon: String, title: String, isLogout: Bool = false) -> some View {
//        Button {
//            print("\(title) tapped")
//        } label: {
//            HStack(spacing: 16) {
//                Image(systemName: icon)
//                    .font(.title3)
//                    .foregroundColor(isLogout ? .red : .blue)
//
//                Text(title)
//                    .font(.system(size: 16, weight: .medium))
//                    .foregroundColor(isLogout ? .red : .black)
//
//                Spacer()
//            }
//        }
//    }
//}


import SwiftUI
import UIKit

struct SideMenuView: View {

    @Binding var showMenu: Bool
   // var username: String
    var user: AuthResponse
    @EnvironmentObject var appState: AppStateManager

    var body: some View {
            ZStack(alignment: .leading) {

                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            showMenu = false
                        }
                    }

                VStack(alignment: .leading, spacing: 30) {

                    // 👤 Header
                    VStack(alignment: .leading, spacing: 8) {

                        Circle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Text(String(user.username.prefix(1)).uppercased())
                                    .font(.title)
                                    .bold()
                                    .foregroundColor(.blue)
                            )

                        Text(user.username)
                            .font(.headline)

                        Text("View Profile")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 60)

                    Divider()

                    VStack(alignment: .leading, spacing: 25) {

                        // ✅ ACCOUNT NAVIGATION
                        NavigationLink {
                            AccountDetailScreen(user: user)
                        } label: {
                            menuLabel(icon: "person.crop.circle", title: "Account")
                        }

                        // ✅ PRIVACY POLICY
                        Button {
                            if let url = URL(string: "https://deltafour-policy.web.app/") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            menuLabel(icon: "lock.shield", title: "Privacy Policy")
                        }

                        // ✅ LOGOUT
                        Button {
                            logoutUser()
                        } label: {
                            menuLabel(icon: "arrow.backward.circle",
                                      title: "Logout",
                                      isLogout: true)
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal, 24)
                .frame(width: 280)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.white)
                        .shadow(radius: 15)
                )
                .ignoresSafeArea()
                .transition(.move(edge: .leading))
            }
        }

        // MARK: Menu UI
        private func menuLabel(icon: String,
                               title: String,
                               isLogout: Bool = false) -> some View {

            HStack(spacing: 16) {

                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(isLogout ? .red : .blue)

                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isLogout ? .red : .black)

                Spacer()
            }
        }

        // MARK: Logout Logic
//        private func logoutUser() {
//          
//            UserDefaultsHelper.shared.clearUser()
//            KeychainHelper.shared.clearToken()
//
//            UserDefaults.standard.removeObject(forKey: "isLoggedIn")
//            UserDefaults.standard.removeObject(forKey: "companyName")
//            UserDefaults.standard.removeObject(forKey: "username")
//            UserDefaults.standard.removeObject(forKey: "department")
//            UserDefaults.standard.removeObject(forKey: "designation")
//            UserDefaults.standard.removeObject(forKey: "email")
//            UserDefaults.standard.removeObject(forKey: "empId")
//
//            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//               let window = scene.windows.first {
//
//                window.rootViewController = UIHostingController(rootView: LoginWrapper())
//                window.makeKeyAndVisible()
//
//                UIView.transition(with: window,
//                                  duration: 0.3,
//                                  options: .transitionCrossDissolve,
//                                  animations: nil)
//            }
//        }
    
    
    private func logoutUser() {
        
        // ✅ Clear only required data
        UserDefaultsHelper.shared.clearUser()
        KeychainHelper.shared.clearToken()

        // ❌ Ye sab remove mat karo (username rehne do UX ke liye)
        // UserDefaults.standard.removeObject(forKey: "username")

        // ✅ IMPORTANT: Notification bhejo
        NotificationCenter.default.post(name: .userDidLogout, object: nil)
        
        UserDefaults.standard.removeObject(forKey: "loggedInUserType")
    }
    
    
    
    }


extension Notification.Name {
    static let userDidLogout = Notification.Name("userDidLogout")
}
