//
//  PrimaryButtonStyle.swift
//  Lloyds
//
//  Created by Manisha on 24/12/25.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(Color.blue) // Apni theme color lagao
            .foregroundColor(.white)
            .font(.headline)
            .cornerRadius(10)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
