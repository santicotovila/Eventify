import SwiftUI

struct RootView: View {
    
    @EnvironmentObject var appStateVM: AppStateVM
    
    var body: some View {
        Group {
            if appStateVM.isUserAuthenticated {
                HomeView()
            } else {
                LoginView()
            }
        }
        .onAppear {
            appStateVM.checkAuthenticationState()
        }
    }
}

#Preview {
    RootView()
}