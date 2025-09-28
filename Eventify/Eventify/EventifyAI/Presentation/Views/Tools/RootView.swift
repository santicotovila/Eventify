import SwiftUI
import SwiftData

struct RootView: View {
    
    @State private var appStateVM: AppStateVM
    @Environment(\.modelContext) private var modelContext
     
    init() {
        let loginRepository = DefaultLoginRepository()
        let loginUseCase = LoginUseCase(loginRepository: loginRepository)
        self._appStateVM = State(wrappedValue: AppStateVM(loginUseCase: loginUseCase))
    }
    
    var body: some View {
        Group {
            if appStateVM.isUserAuthenticated {
                HomeView()
                    .environment(appStateVM)
                    .environment(\.modelContext, modelContext)
            } else {
                LoginView()
                    .environment(appStateVM)
                    .environment(\.modelContext, modelContext)
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
