import SwiftUI

struct ContinueRegistrationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var firstName: String
    @State private var lastName = ""
    
    init(userName: String = "") {
        _firstName = State(initialValue: userName)
    }
    @State private var birthDate = Date()
    @State private var location = ""
    @State private var selectedPreferences: Set<String> = []
    @State private var showDatePicker = false
    @State private var showHomeView = false
    
    // Preferencias disponibles según el mockup
    let availablePreferences = [
        "Deportes", "Juegos", "Ferias", "Bienestar", 
        "Música", "Cine", "Baile", "Comida", "Aprendizaje",
        "Aventura", "Entretenimiento", "Espectáculos", 
        "Tapas y bares", "Relajación", "Discotecas"
    ]
    
    let preferenceColors: [String: Color] = [
        "Deportes": .blue, "Juegos": .green, "Ferias": .orange,
        "Bienestar": .purple, "Música": .red, "Cine": .yellow,
        "Baile": .pink, "Comida": .brown, "Aprendizaje": .cyan,
        "Aventura": .mint, "Entretenimiento": .indigo, "Espectáculos": .teal,
        "Tapas y bares": .orange, "Relajación": .green, "Discotecas": .purple
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.8), Color.purple.opacity(1.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header con botón de retroceso
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Imagen de perfil
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                                    )
                                
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        
                        // Datos Usuario
                        VStack(spacing: 20) {
                            // Campo de nombre
                            HStack {
                                Image(systemName: "person")
                                    .foregroundColor(.gray)
                                    .frame(width: 20)
                                TextField("Nombre", text: $firstName)
    
                            }
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(15)
                            
                            // Campo de apellido
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundColor(.gray)
                                    .frame(width: 20)
                                TextField("Apellido", text: $lastName)
                                Text("*")
                                    .foregroundColor(.red)
                            }
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(15)
                            // Campo de fecha de nacimiento
                            Button(action: {
                                showDatePicker.toggle()
                            }) {
                                HStack {
                                    Image(systemName: "calendar")
                                        .foregroundColor(.gray)
                                        .frame(width: 20)
                                    Text(birthDate == Date() ? "" : DateFormatter.shortDate.string(from: birthDate))
                                        .foregroundColor(birthDate == Date() ? .gray : .black)
                                    Spacer()
                                    Text("*")
                                        .foregroundColor(.red)
                                }
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(15)
                            }
                            
                            // Campo de localidad
                            HStack {
                                Image(systemName: "location")
                                    .foregroundColor(.gray)
                                    .frame(width: 20)
                                TextField("Localidad", text: $location)
                                Text("*")
                                    .foregroundColor(.red)
                            }
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(15)
                            
                            // Texto de campos obligatorios
                            HStack {
                                Spacer()
                                Text("* Campos Obligatorios")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        .padding(.horizontal, 32)
                        
                        // Sección de preferencias
                        VStack(spacing: 16) {
                            HStack {
                                Text("❤️ Preferencias")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                Text("(Elige al menos 3)")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.8))
                                Spacer()
                            }
                            .padding(.horizontal, 32)
                            
                            // Grid de preferencias
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                                ForEach(availablePreferences, id: \.self) { preference in
                                    Button(action: {
                                        if selectedPreferences.contains(preference) {
                                            selectedPreferences.remove(preference)
                                        } else {
                                            selectedPreferences.insert(preference)
                                        }
                                    }) {
                                        Text(preference)
                                            .font(.caption2)
                                            .fontWeight(.medium)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(
                                                selectedPreferences.contains(preference) ? 
                                                (preferenceColors[preference] ?? .blue) : 
                                                Color.white.opacity(0.3)
                                            )
                                            .foregroundColor(
                                                selectedPreferences.contains(preference) ? .white : .white.opacity(0.9)
                                            )
                                            .cornerRadius(20)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(Color.white.opacity(0.3), lineWidth: selectedPreferences.contains(preference) ? 0 : 1)
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal, 32)
                        }
                        
                        // Botones de acción
                        VStack(spacing: 16) {
                            Button(action: {
                                showHomeView = true
                            }) {
                                Text("Crear cuenta")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color.white.opacity(0.3))
                                    .foregroundColor(.white)
                                    .cornerRadius(25)
                            }
                            .disabled(!isFormValid)
                            .padding(.horizontal, 32)
                            
                        }
                
                    }
                }
            }
        }
        .sheet(isPresented: $showDatePicker) {
            VStack {
                DatePicker("Fecha de nacimiento", selection: $birthDate, displayedComponents: .date)
                    .datePickerStyle(WheelDatePickerStyle())
                    .padding()
                
                Button("Confirmar") {
                    showDatePicker = false
                }
                .padding()
            }
        }
        .fullScreenCover(isPresented: $showHomeView) {
            HomeView()
        }
    }
    
    private var isFormValid: Bool {
        !firstName.isEmpty && 
        !lastName.isEmpty && 
        !location.isEmpty &&
        selectedPreferences.count >= 3
    }
}

// Extensión para DateFormatter
extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
}

#Preview {
    ContinueRegistrationView(userName: "Usuario de prueba")
}
