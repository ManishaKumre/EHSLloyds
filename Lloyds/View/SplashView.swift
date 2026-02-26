//
//  SplashView.swift
//  Lloyds
//
//  Created by Manisha on 07/04/26.
//

import SwiftUI


struct SplashView: View {
    
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.5
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.10, green: 0.50, blue: 0.85)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                Spacer()
                
                // Logo
                Image("logo") //  image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140, height: 140)
                    .background(
                            Circle()
                                .fill(Color(red: 0.10, green: 0.50, blue: 0.85))
                        )
                        .clipShape(Circle())
                        
                        .scaleEffect(scale)
                        .opacity(opacity)
                
                // App Name
                Text("Deltafour® EHS One")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
                    .opacity(opacity)
                
                Spacer()
                
                
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}
