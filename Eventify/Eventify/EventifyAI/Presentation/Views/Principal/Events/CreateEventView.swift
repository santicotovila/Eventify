import SwiftUI
import SwiftData

struct CreateEventView: View {
    
    @State private var viewModel: CreateEventViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let onEventCreated: (() -> Void)?
    
    init(onEventCreated: (() -> Void)? = nil) {
        self._viewModel = State(wrappedValue: CreateEventViewModel())
        self.onEventCreated = onEventCreated
    }
    
    var body: some View {
        ZStack {
                // Fondo púrpura como en las imágenes
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
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header con estilo de los mocks
                        VStack(spacing: 20) {
                            // Icono más grande y estilizado
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.15))
                                    .frame(width: 100, height: 100)
                                
                                Circle()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 45))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(spacing: 8) {
                                Text("Crear Evento")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text("Completa la información del evento")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(.top, 30)
                        
                        // Formulario con estilo mejorado
                        VStack(spacing: 20) {
                            // Título
                            CreateEventField(
                                icon: "text.cursor",
                                placeholder: "Título",
                                text: $viewModel.eventTitle
                            )
                            
                            // Descripción
                            CreateEventField(
                                icon: "text.alignleft",
                                placeholder: "Descripción",
                                text: $viewModel.eventDescription
                            )
                            
                            // Fecha y Hora
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 8) {
                                    Image(systemName: "calendar")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white.opacity(0.9))
                                        .frame(width: 20)
                                    
                                    Text("Fecha")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white.opacity(0.9))
                                    
                                    Spacer()
                                }
                                
                                DatePicker("", selection: $viewModel.eventDate, displayedComponents: [.date, .hourAndMinute])
                                    .datePickerStyle(.compact)
                                    .accentColor(.white)
                                    .colorScheme(.dark)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(
                                                LinearGradient(
                                                    colors: [
                                                        Color.white.opacity(0.12),
                                                        Color.white.opacity(0.08)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                            )
                                    )
                            }
                            
                            // Hora
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 8) {
                                    Image(systemName: "clock")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white.opacity(0.9))
                                        .frame(width: 20)
                                    
                                    Text("Hora")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white.opacity(0.9))
                                    
                                    Spacer()
                                }
                                
                                Text(DateFormatter.timeFormatter.string(from: viewModel.eventDate))
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(
                                                LinearGradient(
                                                    colors: [
                                                        Color.white.opacity(0.12),
                                                        Color.white.opacity(0.08)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                            )
                                    )
                            }
                            
                            // Lugar
                            CreateEventField(
                                icon: "location.fill",
                                placeholder: "Lugar",
                                text: $viewModel.eventLocation
                            )
                        }
                        .padding(.horizontal, 24)
                        
                        VStack(spacing: 16) {
                            Button(action: {
                                Task {
                                    await viewModel.createEvent()
                                }
                            }) {
                                HStack(spacing: 12) {
                                    if viewModel.isLoading {
                                        ProgressView()
                                            .scaleEffect(0.9)
                                            .tint(.white)
                                    } else {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 18, weight: .semibold))
                                    }
                                    
                                    Text(viewModel.isLoading ? "Creando evento..." : "Crear evento")
                                        .font(.system(size: 17, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    RoundedRectangle(cornerRadius: 28)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color(red: 0.5, green: 0.3, blue: 0.9),
                                                    Color(red: 0.4, green: 0.2, blue: 0.8)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 28)
                                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                        )
                                )
                                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                            }
                            .disabled(!viewModel.isFormValid || viewModel.isLoading)
                            .opacity((!viewModel.isFormValid || viewModel.isLoading) ? 0.6 : 1.0)
                            .scaleEffect((!viewModel.isFormValid || viewModel.isLoading) ? 0.98 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: viewModel.isFormValid)
                            
                            // Botón de invitar amigos (como en los mocks)
                            Button(action: {
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "person.2.fill")
                                        .font(.system(size: 16, weight: .medium))
                                    
                                    Text("Invitar amigos")
                                        .font(.system(size: 16, weight: .medium))
                                }
                                .foregroundColor(.white.opacity(0.9))
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(Color.white.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 24)
                                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                        )
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 32)
                    }
                    .padding(.bottom, 40)
                }
            }
            .onChange(of: viewModel.isEventCreated) { _, created in
                if created {
                    onEventCreated?()
                    dismiss()
                }
            }
            .onAppear {
                // Inyectar modelContext al ViewModel
                viewModel.setModelContext(modelContext)
            }
        }
    }


// Vista auxiliar para los campos del formulario con estilo de los mocks
struct CreateEventField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Label con icono
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .frame(width: 20)
                
                Text(placeholder)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                
                Spacer()
            }
            
            // Campo de texto estilizado
            TextField(placeholder, text: $text)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .textInputAutocapitalization(placeholder == "Lugar" ? .words : .sentences)
                .submitLabel(placeholder == "Lugar" ? .done : .next)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.12),
                                    Color.white.opacity(0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.2),
                                            Color.white.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                )
        }
    }
}

// Estilo personalizado para los campos de texto
struct CustomCreateEventTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .foregroundColor(.white)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
    }
}

#Preview {
    CreateEventView()
}
