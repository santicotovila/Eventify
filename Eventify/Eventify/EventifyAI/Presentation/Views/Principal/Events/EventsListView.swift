import SwiftUI

struct EventsListView: View {
    @Environment(AppStateVM.self) var appState
    @State var viewModel: EventsViewModel
    
    init(viewModel: EventsViewModel = EventsViewModel()) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
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
                        
                       
                        NavigationLink {
                            CreateEventView {
                                Task {
                                    await viewModel.getEvents()
                                }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "plus")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("Crea tu evento")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white.opacity(0.2))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
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
            .searchable(text: $viewModel.filterUI, prompt: "Buscar eventos por título")
            .onChange(of: viewModel.filterUI) { oldValue, newValue in
                if !newValue.isEmpty {
                    if newValue.count > 2 {
                        Task {
                            await viewModel.getEvents(newSearch: newValue)
                        }
                    }
                } else {
                    Task {
                        await viewModel.getEvents(newSearch: "")
                    }
                }
            }
            .task {
                await viewModel.getEvents()
            }
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
