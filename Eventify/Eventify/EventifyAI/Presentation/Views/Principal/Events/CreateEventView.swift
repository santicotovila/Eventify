import SwiftUI

// Pantalla para crear eventos nuevos
struct CreateEventView: View {
    
    // Variables que necesita
    @State private var viewModel: CreateEventViewModel
    @Environment(\.dismiss) var dismiss
    
    let onEventCreated: (() -> Void)?
    
    // Constructor
    init(onEventCreated: (() -> Void)? = nil) {
        let eventsRepository = DefaultEventsRepository()
        let loginRepository = DefaultLoginRepository()
        let eventsUseCase = EventsUseCase(repository: eventsRepository, loginRepository: loginRepository)
        
        self._viewModel = State(wrappedValue: CreateEventViewModel(
            eventsUseCase: eventsUseCase
        ))
        self.onEventCreated = onEventCreated
    }
    
    // Lo que se ve en la pantalla
    var body: some View {
        NavigationView {
            Form {
                eventInfoSection
                dateTimeSection
                previewSection
            }
            .navigationTitle("Nuevo Evento")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        onEventCreated?()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Crear") {
                        Task {
                            await viewModel.createEvent()
                        }
                    }
                    .disabled(!viewModel.isFormValid)
                }
            }
        }
        .alert("Error", isPresented: $viewModel.showAlert) {
            Button("OK") {
                viewModel.dismissAlert()
            }
        } message: {
            Text(viewModel.alertMessage)
        }
        .onChange(of: viewModel.isEventCreated) { created in
            if created {
                onEventCreated?()
            }
        }
    }
    
    // MARK: - Secciones del formulario
    
    private var eventInfoSection: some View {
        Section(header: Text("Información del Evento")) {
            titleField
            descriptionField
            locationField
        }
    }
    
    private var titleField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Título *")
                .font(.subheadline)
                .foregroundColor(.secondary)
            TextField("Ej: Cena de cumpleaños", text: $viewModel.eventTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
    
    private var descriptionField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Descripción *")
                .font(.subheadline)
                .foregroundColor(.secondary)
            TextField("Describe tu evento...", text: $viewModel.eventDescription, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .lineLimit(3...6)
        }
    }
    
    private var locationField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ubicación *")
                .font(.subheadline)
                .foregroundColor(.secondary)
            TextField("Ej: Restaurante El Buen Gusto", text: $viewModel.eventLocation)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
    
    private var dateTimeSection: some View {
        Section(header: Text("Fecha y Hora")) {
            DatePicker(
                "Fecha del evento",
                selection: $viewModel.eventDate,
                in: Date()...,
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.compact)
        }
    }
    
    private var previewSection: some View {
        Section(header: Text("Vista Previa")) {
            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.eventTitle.isEmpty ? "Título del evento" : viewModel.eventTitle)
                    .font(.headline)
                    .foregroundColor(viewModel.eventTitle.isEmpty ? .secondary : .primary)
                
                Text(viewModel.eventLocation.isEmpty ? "Ubicación" : viewModel.eventLocation)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(viewModel.eventDate, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.blue)
                
                if !viewModel.eventDescription.isEmpty {
                    Text(viewModel.eventDescription)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    CreateEventView(
        onEventCreated: {}
    )
}

