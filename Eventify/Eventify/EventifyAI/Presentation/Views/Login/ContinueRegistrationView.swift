import SwiftUI

struct ContinueRegistrationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var firstName: String
    @State private var lastName = ""
    
    // Datos del registro anterior
    private let userEmail: String
    private let userPassword: String
    
    init(userName: String = "", email: String = "", password: String = "") {
        _firstName = State(initialValue: userName)
        self.userEmail = email
        self.userPassword = password
    }
    @State private var birthDate = Date()
    @State private var location = ""
    @State private var selectedPreferences: Set<InterestModel> = []
    @State private var availableInterests: [InterestModel] = []
    @State private var showDatePicker = false
    @State private var showHomeView = false
    @State private var isLoadingInterests = false
    @State private var isRegistering = false
    @State private var errorMessage: String?
    
    private let networkUser = NetworkUser()
    
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
                            
                            // Grid de preferencias - dinámico desde backend
                            if isLoadingInterests {
                                ProgressView()
                                    .scaleEffect(1.5)
                                    .tint(.white)
                                    .padding()
                            } else {
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                                    ForEach(availableInterests) { interest in
                                        Button(action: {
                                            if selectedPreferences.contains(interest) {
                                                selectedPreferences.remove(interest)
                                            } else {
                                                selectedPreferences.insert(interest)
                                            }
                                        }) {
                                            Text(interest.name)
                                                .font(.caption2)
                                                .fontWeight(.medium)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 8)
                                                .background(
                                                    selectedPreferences.contains(interest) ? 
                                                    (preferenceColors[interest.name] ?? .blue) : 
                                                    Color.white.opacity(0.3)
                                                )
                                                .foregroundColor(
                                                    selectedPreferences.contains(interest) ? .white : .white.opacity(0.9)
                                                )
                                                .cornerRadius(20)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .stroke(Color.white.opacity(0.3), lineWidth: selectedPreferences.contains(interest) ? 0 : 1)
                                                )
                                        }
                                    }
                                }
                                .padding(.horizontal, 32)
                            }
                        }
                        
                        // Botones de acción
                        VStack(spacing: 16) {
                            Button(action: {
                                Task {
                                    await registerUser()
                                }
                            }) {
                                HStack {
                                    if isRegistering {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                            .tint(.white)
                                    }
                                    Text(isRegistering ? "Registrando..." : "Crear cuenta")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.white.opacity(isFormValid ? 0.3 : 0.1))
                                .foregroundColor(.white)
                                .cornerRadius(25)
                            }
                            .disabled(!isFormValid || isRegistering)
                            .padding(.horizontal, 32)
                            
                            // Mostrar error si existe
                            if let errorMessage = errorMessage {
                                Text(errorMessage)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .padding(.horizontal, 32)
                                    .multilineTextAlignment(.center)
                            }
                            
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
        .onAppear {
            loadInterests()
        }
    }
    
    private var isFormValid: Bool {
        !firstName.isEmpty && 
        !lastName.isEmpty && 
        !location.isEmpty &&
        selectedPreferences.count >= 3 &&
        !availableInterests.isEmpty
    }
    
    // MARK: - Backend Functions
    private func loadInterests() {
        isLoadingInterests = true
        errorMessage = nil
        
        Task {
            do {
                let interests = try await networkUser.getInterests()
                await MainActor.run {
                    self.availableInterests = interests
                    self.isLoadingInterests = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Error cargando intereses: \(error.localizedDescription)"
                    self.isLoadingInterests = false
                    // Fallback a intereses mock
                    self.availableInterests = InterestModel.mockInterests
                }
            }
        }
    }
    
    private func registerUser() async {
        isRegistering = true
        errorMessage = nil
        
        // Preparar datos del registro
        let fullName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
        let selectedInterestIDs = Array(selectedPreferences).map { $0.id }
        
        // Usar los datos reales del RegisterView
        let email = userEmail
        let password = userPassword
        
        do {
            let response = try await networkUser.register(
                name: fullName,
                email: email,
                password: password,
                interestIDs: selectedInterestIDs
            )
            
            await MainActor.run {
                print("Registro exitoso - Access Token: \(response.accessToken)")
                
                self.isRegistering = false
                self.showHomeView = true
            }
            
        } catch {
            await MainActor.run {
                self.errorMessage = "Error en registro: \(error.localizedDescription)"
                self.isRegistering = false
            }
        }
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
