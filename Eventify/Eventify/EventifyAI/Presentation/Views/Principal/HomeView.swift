import SwiftUI

struct HomeView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            EventsHomeView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Eventos")
                }
                .tag(0)
            
            Text("Búsqueda")
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Buscar")
                }
                .tag(1)
            
            Text("Favoritos")
                .tabItem {
                    Image(systemName: "heart")
                    Text("Favoritos")
                }
                .tag(2)
            
            Text("Perfil")
                .tabItem {
                    Image(systemName: "person")
                    Text("Perfil")
                }
                .tag(3)
        }
        .accentColor(.purple)
    }
}

struct EventsHomeView: View {
    
    // Datos de ejemplo según el mockup
    let events = [
        EventCard(title: "Cine", date: "Sábado, 6 de Septiembre", image: "🎬", color: .orange),
        EventCard(title: "Paseo por el parque", date: "Domingo, 7 de Septiembre", image: "🌳", color: .green),
        EventCard(title: "Picnic", date: "Sábado, 13 de Septiembre", image: "🧺", color: .yellow),
        EventCard(title: "Scape Room", date: "Lunes, 15 de Septiembre", image: "🔐", color: .purple),
        EventCard(title: "Salir de cañas", date: "Sábado, 27 de Septiembre", image: "🍺", color: .orange),
        EventCard(title: "Fiesta en Fabrik", date: "Sábado, 25 de Octubre", image: "🎭", color: .blue)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo con degradado
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header personalizado
                    HStack {
                        // Botón de agregar
                        Button(action: {}) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color.purple)
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        // Título
                        Text("Eventos")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        // Avatares de usuario (ejemplo)
                        HStack(spacing: -10) {
                            Circle()
                                .fill(Color.yellow)
                                .frame(width: 35, height: 35)
                                .overlay(
                                    Text("S")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                )
                            
                            Circle()
                                .fill(Color.purple)
                                .frame(width: 35, height: 35)
                                .overlay(
                                    Text("J")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                )
                        }
                        .background(
                            Circle()
                                .fill(Color.white)
                                .frame(width: 40, height: 40)
                        )
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Lista de eventos
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(events, id: \.title) { event in
                                EventRowView(event: event)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                    }
                }
            }
        }
    }
}

struct EventCard {
    let title: String
    let date: String
    let image: String
    let color: Color
}

struct EventRowView: View {
    let event: EventCard
    
    var body: some View {
        HStack(spacing: 16) {
            // Imagen del evento
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(event.color.opacity(0.8))
                    .frame(width: 60, height: 60)
                
                Text(event.image)
                    .font(.title2)
            }
            
            // Información del evento
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(event.date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Indicador o botón de acción
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

#Preview {
    HomeView()
}