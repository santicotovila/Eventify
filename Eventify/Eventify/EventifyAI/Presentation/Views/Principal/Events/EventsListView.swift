import SwiftUI
import SwiftData

struct EventsListView: View {
    @Environment(AppStateVM.self) var appState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: EventsViewModel
    
    init(viewModel: EventsViewModel = EventsViewModel()) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
                
                LinearGradient(
                    stops: [
                        Gradient.Stop(color: Color(red: 0.08, green: 0.31, blue: 0.6), location: 0.00),
                        Gradient.Stop(color: Color(red: 0.31, green: 0.27, blue: 0.58), location: 0.40),
                        Gradient.Stop(color: Color(red: 0.45, green: 0.22, blue: 0.57), location: 1.00),
                    ],
                    startPoint: UnitPoint(x: 0.02, y: 0),
                    endPoint: UnitPoint(x: 1, y: 1)
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    HStack {
                        Text("Eventos")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                    
                  
                    if viewModel.eventsData.isEmpty {
                        VStack(spacing: 24) {
                            Spacer()
                            
                            
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(width: 120, height: 120)
                                
                                Image(systemName: "calendar.badge.plus")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            VStack(spacing: 12) {
                                Text("No hay eventos")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text("Crea tu primer evento y comienza\na organizar experiencias increíbles")
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(4)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 40)
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.eventsData) { event in
                                    NavigationLink {
                                        EventDetailView(eventId: event.id)
                                    } label: {
                                        EventCardView(event: event)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
            .onAppear {
                // Inyectar modelContext al ViewModel
                viewModel.setModelContext(modelContext)
            }
        }
    }


#Preview {
    let loginRepository = DefaultLoginRepository()
    let loginUseCase = LoginUseCase(loginRepository: loginRepository)
    let appState = AppStateVM(loginUseCase: loginUseCase)
    
    EventsListView(viewModel: EventsViewModel(useCase: EventsUseCaseFake()))
        .environment(appState)
}
