import SwiftUI

// Pantalla para crear eventos nuevos
struct CreateEventView: View {
    
    // Variables que necesita
    @StateObject private var viewModel: CreateEventViewModel
    @Environment(\.dismiss) var dismiss
    
    let onEventCreated: (() -> Void)?
    
    // Constructor
    init(onEventCreated: (() -> Void)? = nil) {
        let eventsRepository = DefaultEventsRepository()
        let loginRepository = DefaultLoginRepository()
        let eventsUseCase = EventsUseCase(repository: eventsRepository, loginRepository: loginRepository)
        
        self._viewModel = StateObject(wrappedValue: CreateEventViewModel(
            eventsUseCase: eventsUseCase
        ))
        self.onEventCreated = onEventCreated
    }
    
    // Lo que se ve en la pantalla
    var body: some View {
        ZStack {
            // Fondo con degradado igual al diseño
            LinearGradient(
                colors: [Color.blue.opacity(0.8), Color.purple.opacity(1.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header personalizado
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("Crea tu evento")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        Task {
                            await viewModel.createEvent()
                            if viewModel.isEventCreated {
                                onEventCreated?()
                                dismiss()
                            }
                        }
                    }) {
                        Image(systemName: "checkmark")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    .disabled(!viewModel.isFormValid)
                    .opacity(viewModel.isFormValid ? 1.0 : 0.5)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 30)
                
                // Formulario
                ScrollView {
                    VStack(spacing: 20) {
                        createFormField(
                            placeholder: "Título",
                            text: $viewModel.eventTitle
                        )
                        
                        createFormField(
                            placeholder: "Descripción",
                            text: $viewModel.eventDescription,
                            isMultiline: true
                        )
                        
                        createFormField(
                            placeholder: "Fecha",
                            text: $viewModel.dateString,
                            isDateField: true
                        )
                        
                        createFormField(
                            placeholder: "Hora",
                            text: $viewModel.timeString,
                            isTimeField: true
                        )
                        
                        createFormField(
                            placeholder: "Lugar",
                            text: $viewModel.eventLocation
                        )
                        
                        createFormField(
                            placeholder: "Invitar amigos",
                            text: $viewModel.inviteString
                        )
                        
                        Spacer(minLength: 40)
                        
                        // Botón crear evento
                        Button(action: {
                            Task {
                                await viewModel.createEvent()
                                if viewModel.isEventCreated {
                                    onEventCreated?()
                                    dismiss()
                                }
                            }
                        }) {
                            HStack {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text("Crear evento")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.black.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(!viewModel.isFormValid || viewModel.isLoading)
                        .opacity((viewModel.isFormValid && !viewModel.isLoading) ? 1.0 : 0.6)
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 20)
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
    }
    
    // MARK: - Helper Functions
    
    @ViewBuilder
    private func createFormField(
        placeholder: String,
        text: Binding<String>,
        isMultiline: Bool = false,
        isDateField: Bool = false,
        isTimeField: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if isDateField {
                Button(action: {
                    // TODO: Mostrar date picker
                }) {
                    HStack {
                        Text(text.wrappedValue.isEmpty ? placeholder : text.wrappedValue)
                            .foregroundColor(text.wrappedValue.isEmpty ? .white.opacity(0.7) : .white)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.1))
                            )
                    )
                }
            } else if isTimeField {
                Button(action: {
                    // TODO: Mostrar time picker
                }) {
                    HStack {
                        Text(text.wrappedValue.isEmpty ? placeholder : text.wrappedValue)
                            .foregroundColor(text.wrappedValue.isEmpty ? .white.opacity(0.7) : .white)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.1))
                            )
                    )
                }
            } else if isMultiline {
                TextField(
                    placeholder,
                    text: text,
                    axis: .vertical
                )
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.1))
                        )
                )
                .lineLimit(3...6)
            } else {
                TextField(placeholder, text: text)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.1))
                            )
                    )
            }
        }
    }
}

#Preview {
    CreateEventView(
        onEventCreated: {}
    )
}

