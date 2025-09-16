import SwiftUI

struct EventsView: View {
    
    @State private var viewModel: EventsViewModel
    @State private var showCreateEvent = false
    
    init() {
        let eventsRepository = DefaultEventsRepository()
        let loginRepository = DefaultLoginRepository()
        let eventsUseCase = EventsUseCase(repository: eventsRepository, loginRepository: loginRepository)
        let loginUseCase = LoginUseCase(loginRepository: loginRepository)
        
        self._viewModel = State(wrappedValue: EventsViewModel(eventsUseCase: eventsUseCase, loginUseCase: loginUseCase))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading && viewModel.events.isEmpty {
                    LoaderView(message: "Cargando eventos...")
                } else if viewModel.events.isEmpty {
                    EmptyEventsView {
                        showCreateEvent = true
                    }
                } else {
                    EventsContentView(viewModel: viewModel)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text("Eventos")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button {
                            showCreateEvent = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .refreshable {
                await viewModel.refreshEvents()
            }
            .sheet(isPresented: $showCreateEvent) {
                CreateEventView()
            }
            .alert("Error", isPresented: $viewModel.showAlert) {
                Button("OK") {
                    viewModel.dismissAlert()
                }
            } message: {
                Text(viewModel.alertMessage)
            }
            .task {
                await viewModel.loadEvents()
            }
        }
    }
}

struct EventsContentView: View {
    let viewModel: EventsViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if !viewModel.upcomingEvents.isEmpty {
                    EventSection(
                        title: "Próximos Eventos",
                        events: viewModel.upcomingEvents,
                        icon: "calendar"
                    )
                }
                
                if !viewModel.pastEvents.isEmpty {
                    EventSection(
                        title: "Eventos Pasados", 
                        events: viewModel.pastEvents,
                        icon: "calendar.badge.checkmark"
                    )
                }
            }
            .padding()
        }
    }
}

struct EmptyEventsView: View {
    let onCreateEvent: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("No tienes eventos")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Crea tu primer evento para empezar a organizar")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("Crear Evento") {
                onCreateEvent()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
    }
}

struct EventSection: View {
    let title: String
    let events: [EventModel]
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.horizontal)
            
            LazyVStack(spacing: 8) {
                ForEach(events) { event in
                    NavigationLink(destination: EventDetailView(eventId: event.id)) {
                        EventsRowView(event: event)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

#Preview {
    EventsView()
}