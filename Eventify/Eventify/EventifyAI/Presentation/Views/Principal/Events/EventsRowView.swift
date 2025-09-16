import SwiftUI

struct EventsRowView: View {
    let event: EventModel
    
    var body: some View {
        HStack(spacing: 12) {
            // Imagen del evento
            RoundedRectangle(cornerRadius: 12)
                .fill(getEventColor(for: event.title))
                .frame(width: 60, height: 60)
                .overlay(
                    getEventIcon(for: event.title)
                        .font(.title2)
                        .foregroundColor(.white)
                )
            
            // Información del evento
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(event.formattedDate)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    // Función para obtener color basado en el tipo de evento
    private func getEventColor(for title: String) -> Color {
        let lowercased = title.lowercased()
        if lowercased.contains("cine") { return .blue }
        if lowercased.contains("parque") || lowercased.contains("paseo") { return .green }
        if lowercased.contains("picnic") { return .orange }
        if lowercased.contains("room") || lowercased.contains("escape") { return .yellow }
        if lowercased.contains("cañas") || lowercased.contains("bar") { return .red }
        if lowercased.contains("fiesta") || lowercased.contains("party") { return .purple }
        return .blue
    }
    
    // Función para obtener icono basado en el tipo de evento
    private func getEventIcon(for title: String) -> Image {
        let lowercased = title.lowercased()
        if lowercased.contains("cine") { return Image(systemName: "film") }
        if lowercased.contains("parque") || lowercased.contains("paseo") { return Image(systemName: "tree") }
        if lowercased.contains("picnic") { return Image(systemName: "basket") }
        if lowercased.contains("room") || lowercased.contains("escape") { return Image(systemName: "key") }
        if lowercased.contains("cañas") || lowercased.contains("bar") { return Image(systemName: "wineglass") }
        if lowercased.contains("fiesta") || lowercased.contains("party") { return Image(systemName: "party.popper") }
        return Image(systemName: "calendar")
    }
}

#Preview {
    VStack(spacing: 16) {
        EventsRowView(event: EventModel.preview)
        EventsRowView(event: EventModel.previewPast)
    }
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}