//
//  DebugPasswordSheet.swift
//  Lloyds
//
//  Created by Manisha on 24/12/25.
//


import SwiftUI

struct DebugPasswordSheet: View {
    @Binding var password: String
    @State private var isPasswordVisible = false   // 👈 Toggle state
    
    var onCancel: () -> Void
    var onUnlock: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Capsule()
                .frame(width: 40, height: 5)
                .foregroundStyle(.secondary.opacity(0.5))
            
            Text("Developer Access")
                .font(.headline)
            
            // MARK: - Password Field With Eye Button
            HStack {
                Group {
                    if isPasswordVisible {
                        TextField("Enter secret password", text: $password)
                    } else {
                        SecureField("Enter secret password", text: $password)
                    }
                }
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                
                Button(action: {
                    isPasswordVisible.toggle()
                }) {
                    Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
            )
            
            // MARK: - Buttons
            HStack {
                Button("Cancel", action: onCancel)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(.secondary)
                    )
                
                Button("Unlock", action: onUnlock)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.accentColor)
                    )
                    .foregroundColor(.white)
            }
        }
        .padding(20)
    }
}

struct DebugPasswordSheet_Previews: PreviewProvider {
    static var previews: some View {
        DebugPasswordSheet(
            password: .constant(""),
            onCancel: {},
            onUnlock: {}
        )
    }
}

