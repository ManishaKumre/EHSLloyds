//
//  DebugMenuView.swift
//  Lloyds
//
//  Created by Manisha on 24/12/25.
//

import SwiftUI

struct DebugMenuView: View {
    @State private var selectedServerName: String = UserDefaults.standard.string(forKey: "SelectedServerName") ?? "Test Server"
    @State private var customURL: String = ""
    
    var onClose: () -> Void
    var onServerChange: ((String) -> Void)? = nil

    var body: some View {
        VStack(spacing: 20) {
            
            Text("Choose Server")
                .font(.title2.bold())
                .padding(.top, 40)
            
            // Server Buttons
            VStack(spacing: 12) {
                Button("Production Server") {
                    switchToServer(
                        name: "Production Server",
                        baseURL: "https://api.deltafour.co/java/api/"
                    )
                }
                .buttonStyle(ServerButtonStyle())
                
                Button("Demo Server") {
                    switchToServer(
                        name: "Demo Server",
                        baseURL: "https://test.deltafour.co/dev/api/"
                    )
                }
                .buttonStyle(ServerButtonStyle())
                
                Button("Test Server") {
                    switchToServer(
                        name: "Test Server",
                        baseURL: "https://test.deltafour.co/api/"
                    )
                }
                .buttonStyle(ServerButtonStyle())
            }
            
            // Custom URL Field
            TextField("Custom URL", text: $customURL)
                .padding()
                .frame(height: 50)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 1)
                .padding(.horizontal, 30)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            
            Button("Confirm Custom URL") {
                if !customURL.isEmpty {
                    switchToServer(
                        name: "Custom Server",
                        baseURL: customURL
                    )
                }
            }
            .buttonStyle(ServerButtonStyle())
            .padding(.top, 10)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGray6))
    }
    
    // ✅ MAIN FIX: Centralized server switching logic
    private func switchToServer(name: String, baseURL: String) {
        selectedServerName = name
        UserDefaults.standard.set(name, forKey: "SelectedServerName")
        
        let cleanURL = baseURL.hasSuffix("/") ? baseURL : baseURL + "/"
        APIConfig.overrideBaseURL = cleanURL
//        KeychainHelper.shared.clearToken()
        APIService.shared.refreshBaseURL()
        UserDefaults.standard.removeObject(forKey: "savedPermitIds")
        
        // 🔹 Notify parent
        onServerChange?(name)
        print("🔄 Server switched to: \(name)")
            print("🌍 Base URL: \(cleanURL)")
        feedbackAndRestart()
    }

    
    private func feedbackAndRestart() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        onClose()
        
        // App restart
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            print("♻️ App restarting in 0.5 seconds...")
//            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
//            exit(0)
//        }
    }
}

struct ServerButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(Color.blue)
            .foregroundColor(.white)
            .font(.system(size: 16, weight: .semibold))
            .cornerRadius(10)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .padding(.horizontal, 30)
    }
}

struct DebugMenuView_Previews: PreviewProvider {
    static var previews: some View {
        DebugMenuView(onClose: {
            print("Closed Debug Menu")
        })
    }
}
