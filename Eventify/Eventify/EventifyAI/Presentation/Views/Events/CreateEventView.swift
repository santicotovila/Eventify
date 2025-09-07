import SwiftUI

// Pantalla para crear eventos nuevos
struct CreateEventView: View {
    
    // Variables que necesita
    @StateObject private var viewModel: CreateEventViewModel
    @Environment(\.presentationMode) var presentationMode
    
    let onEventCreated: () -> Void
    
    // Constructor
    init(onEventCreated: @escaping () -> Void) {
        self._viewModel = StateObject(wrappedValue: CreateEventViewModel(
            createEventUseCase: AppFactory.shared.makeCreateEventUseCase()
        ))
        self.onEventCreated = onEventCreated
    }
    
    // Lo que se ve en la pantalla
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Información del Evento")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Título *")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        TextField("Ej: Cena de cumpleaños", text: $viewModel.title)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Descripción *")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        TextField("Describe tu evento...", text: $viewModel.description, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3...6)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ubicación *")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        TextField("Ej: Restaurante El Buen Gusto", text: $viewModel.location)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                
                Section(header: Text("Fecha y Hora")) {
                    DatePicker(
                        "Fecha del evento",
                        selection: $viewModel.selectedDate,
                        in: viewModel.minimumDate...,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.compact)
                }
                
                Section(header: Text("Vista Previa")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(viewModel.title.isEmpty ? "Título del evento" : viewModel.title)
                            .font(.headline)
                            .foregroundColor(viewModel.title.isEmpty ? .secondary : .primary)
                        
                        Text(viewModel.location.isEmpty ? "Ubicación" : viewModel.location)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(DateFormatter.dateTimeFormatter.string(from: viewModel.selectedDate))
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        
                        if !viewModel.description.isEmpty {
                            Text(viewModel.description)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Nuevo Evento")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(viewModel.createState.isLoading)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Crear") {
                        Task {
                            await viewModel.createEvent()
                        }
                    }
                    .disabled(!viewModel.isFormValid || viewModel.createState.isLoading)
                    .fontWeight(.semibold)
                }
            }
        }
        .alert("Error", isPresented: $viewModel.showAlert) {
            Button("OK") { }
        } message: {
            Text(viewModel.alertMessage)
        }
        .overlay {
            if viewModel.createState.isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.2)
                    Text("Creando evento...")
                        .foregroundColor(.white)
                        .padding(.top, 8)
                }
            }
        }
        .onChange(of: viewModel.createState) { state in
            if case .success = state {
                onEventCreated()
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

#Preview {
    CreateEventView(
        onEventCreated: {}
    )
}

// MARK: - Mock para Preview
final class MockCreateEventUseCase: CreateEventUseCaseProtocol {
    func execute(title: String, description: String, dateTime: Date, location: String) async throws -> Event {
        return Event(
            title: title,
            description: description,
            creatorId: "preview",
            creatorEmail: "usuario@ejemplo.com",
            dateTime: dateTime,
            location: location
        )
    }
}