
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
    


