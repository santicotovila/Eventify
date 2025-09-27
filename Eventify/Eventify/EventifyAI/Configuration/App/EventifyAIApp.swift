//
//  EventifyAIApp.swift
//  EventifyAI
//
//  Created by Javier Gómez on 5/9/25.
//

import SwiftUI
import SwiftData


@main
struct EventifyAIApp: App {
    
    @State private var isInitialized = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if isInitialized {
                    RootView()
                } else {
                    SplashView(isInitialized: $isInitialized)
                }
            }
        }
        .modelContainer(for: [EventDataModel.self])
    }
}
    


