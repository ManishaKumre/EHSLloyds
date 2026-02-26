//
//  LloydsApp.swift
//  Lloyds
//
//  Created by Manisha on 23/12/25.
//


#if canImport(Wormholy)
import Wormholy
#endif

import SwiftUI
@main
struct LloydsApp: App {
    @StateObject private var appState = AppStateManager()
    
    @State private var showSplash = true
    
    init() {
        #if DEBUG && canImport(Wormholy)
        Wormholy.setEnabled(true)
        #endif
    }
    
//    var body: some Scene {
//        WindowGroup {
//            if #available(iOS 16.0, *) {
//                NavigationStack {
//                    LoginWrapper()
//                }
//                .environmentObject(appState)
//            } else {
//                // Fallback on earlier versions
//            }
//        }
//    }
//}


    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashView()
                } else {
                    if #available(iOS 16.0, *) {
                        NavigationStack {
                            LoginWrapper()
                        }
                        .environmentObject(appState)
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showSplash = false
                }
            }
        }
    }
}
