//
//  LoginView.swift
//  Lloyds
//
//  Created by Manisha on 24/12/25.
//

import UIKit
import SwiftUI

// MARK: - Login View
struct LoginView: View {

    // MARK: - State
    @State private var showPassword = false
    @FocusState private var focusedField: Field?
    @EnvironmentObject var appState: AppStateManager

    @StateObject private var viewModel = LoginViewModel()
  
    // MARK: Debug States
    @State private var logoTapCount = 0
    @State private var showPasswordPrompt = false
    @State private var debugPasswordInput = ""
    @State private var isDebugUnlocked = false
    @State private var debugWindowExpiry: Date? = nil
    @State private var showDebugMenu = false

    private let requiredTapCount = 20
    private let secretPassword = "deltaFour@20.0.158"
    private let debugWindowSeconds: TimeInterval = 60

    enum Field { case user, pass }

    var body: some View {

        if #available(iOS 16.0, *) {

            ScrollView {
                VStack(spacing: 0) {

                    Header(
                        onLogoLongPress: { showPasswordPrompt = true },
                        onLogoTap: handleLogoTap
                    )

                    VStack(spacing: 16) {

                        // MARK: Username
                        TextField("username", text: $viewModel.username)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding(.horizontal, 14)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(.systemBackground))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(.systemGray4))
                            )
                            .focused($focusedField, equals: .user)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .pass }

                        // MARK: Password
                        HStack {
                            Group {
                                if showPassword {
                                    TextField("password", text: $viewModel.password)
                                } else {
                                    SecureField("password", text: $viewModel.password)
                                }
                            }
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding(.horizontal, 14)
                            .padding(.vertical, 14)

                            Button {
                                showPassword.toggle()
                            } label: {
                                Image(systemName: showPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.secondary)
                                    .padding(.trailing, 12)
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemBackground))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(.systemGray4))
                        )
                        .focused($focusedField, equals: .pass)
                        .submitLabel(.go)
                        .onSubmit(login)

                        // MARK: Login Button
                        Button(action: login) {
                            if viewModel.isLoading {
                                ProgressView()
                            } else {
                                Text("Login")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(
                            viewModel.isLoading ||
                            viewModel.username.isEmpty ||
                            viewModel.password.isEmpty
                        )

                        // MARK: Error Message
//                        if let error = viewModel.error {
//                            Text(error)
//                                .foregroundColor(.red)
//                                .font(.footnote)
//                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 24)

                    
                    .alert("Login Failed", isPresented: $viewModel.showErrorAlert) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text(viewModel.error ?? "Invalid username or password.")
                    }
                    
                    Spacer(minLength: 40)
                }
            }
            .scrollDismissesKeyboard(.interactively)

            
            .onAppear {
                viewModel.username = ""
                viewModel.password = ""
            }
            
            
            // MARK: Navigation
            .navigationDestination(isPresented: $viewModel.isLoggedIn) {
                PermitScreenView()
                    .navigationBarBackButtonHidden(true)
            }

            // MARK: Debug Password Sheet
            .sheet(isPresented: $showPasswordPrompt) {
                DebugPasswordSheet(
                    password: $debugPasswordInput,
                    onCancel: {
                        debugPasswordInput = ""
                        showPasswordPrompt = false
                    },
                    onUnlock: handlePasswordUnlock
                )
                .presentationDetents([.fraction(0.35)])
            }

            // MARK: Debug Menu Sheet
            .sheet(isPresented: $showDebugMenu) {
                DebugMenuView(
                    onClose: { showDebugMenu = false },
                    onServerChange: { _ in
                        refreshDataAfterServerChange()
                    }
                )
                .presentationDetents([.medium, .large])
            }

        } else {
            Text("This app requires iOS 16 or newer.")
        }
    }

    // MARK: - Login
    private func login() {
        viewModel.login()
    }

    // MARK: - Debug Logic
    private func handlePasswordUnlock() {
        guard debugPasswordInput == secretPassword else {
            UINotificationFeedbackGenerator()
                .notificationOccurred(.error)
            return
        }

        isDebugUnlocked = true
        debugWindowExpiry = Date().addingTimeInterval(debugWindowSeconds)
        logoTapCount = 0
        debugPasswordInput = ""
        showPasswordPrompt = false

        UINotificationFeedbackGenerator()
            .notificationOccurred(.success)
    }

    private func handleLogoTap() {
        guard isDebugUnlocked,
              let expiry = debugWindowExpiry,
              Date() <= expiry else {
            isDebugUnlocked = false
            logoTapCount = 0
            return
        }

        logoTapCount += 1
        if logoTapCount == requiredTapCount {
            showDebugMenu = true
            isDebugUnlocked = false
            logoTapCount = 0
        }
    }

    private func refreshDataAfterServerChange() {
        if KeychainHelper.shared.getToken() != nil {
            PermitScreenViewModel.shared.fetchPermits()
        }
    }
}

//////////////////////////////////////////////////////////
// MARK: - Header View
//////////////////////////////////////////////////////////

private struct Header: View {

    var onLogoLongPress: () -> Void
    var onLogoTap: () -> Void

    var body: some View {
        ZStack(alignment: .top) {

            LinearGradient(
                colors: [Color(hex: 0x0B75F5), Color(hex: 0x1460C8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(edges: .top)

            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.06))
                .rotationEffect(.degrees(-30))
                .offset(x: 60, y: 20)

            VStack(spacing: 14) {

                ZStack {
                    Circle().fill(Color.white)

                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .padding(22)
                }
                .frame(width: 150, height: 150)
                .contentShape(Circle())
                .onTapGesture(perform: onLogoTap)
                .onLongPressGesture(
                    minimumDuration: 1.0,
                    perform: onLogoLongPress
                )

                Text("Welcome!")
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.white)

                Text("Please login to your account\nto continue")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(.top, 80)
        }
        .frame(height: 350)
    }
}

//////////////////////////////////////////////////////////
// MARK: - Color Extension
//////////////////////////////////////////////////////////

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}
