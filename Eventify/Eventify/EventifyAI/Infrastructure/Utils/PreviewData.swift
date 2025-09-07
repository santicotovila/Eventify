import Foundation
import SwiftUI

/// Datos de ejemplo para previews de SwiftUI
struct PreviewData {
    
    // MARK: - Sample Users
    static let sampleUser = User(
        id: "preview_user_1",
        email: "usuario@ejemplo.com",
        displayName: "Usuario de Prueba"
    )
    
    // MARK: - Sample Events
    static let upcomingEvent = Event(
        title: "Cena de Cumpleaños de Ana",
        description: "Celebremos el cumpleaños de Ana en su restaurante favorito. Será una noche especial con buena comida y mejor compañía.",
        creatorId: "user1",
        creatorEmail: "ana@ejemplo.com",
        dateTime: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
        location: "Restaurante El Buen Gusto, Centro de la Ciudad"
    )
    
    static let pastEvent = Event(
        title: "Reunión de Trabajo",
        description: "Revisión mensual del proyecto y planificación de objetivos para el próximo mes.",
        creatorId: "user2",
        creatorEmail: "manager@ejemplo.com",
        dateTime: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
        location: "Oficina Central, Sala de Juntas A"
    )
    
    static let sampleEvents = [upcomingEvent, pastEvent]
    
    // MARK: - Sample Attendances
    static let sampleAttendances = [
        Attendance(eventId: upcomingEvent.id, userId: "user1", userEmail: "juan@ejemplo.com", status: .yes),
        Attendance(eventId: upcomingEvent.id, userId: "user2", userEmail: "maria@ejemplo.com", status: .maybe),
        Attendance(eventId: upcomingEvent.id, userId: "user3", userEmail: "pedro@ejemplo.com", status: .no),
        Attendance(eventId: upcomingEvent.id, userId: "user4", userEmail: "lucia@ejemplo.com", status: .yes)
    ]
}

// MARK: - Preview Providers
#Preview("Event Row - Upcoming") {
    EventRowView(event: PreviewData.upcomingEvent)
        .padding()
        .previewLayout(.sizeThatFits)
}

#Preview("Event Row - Past") {
    EventRowView(event: PreviewData.pastEvent)
        .padding()
        .previewLayout(.sizeThatFits)
}

#Preview("Attendance Rows") {
    VStack(spacing: 8) {
        ForEach(PreviewData.sampleAttendances) { attendance in
            AttendanceRowView(attendance: attendance)
        }
    }
    .padding()
    .previewLayout(.sizeThatFits)
}

#Preview("Event Header") {
    EventHeaderView(event: PreviewData.upcomingEvent)
        .padding()
        .previewLayout(.sizeThatFits)
}

#Preview("Event Details") {
    EventDetailsView(event: PreviewData.upcomingEvent)
        .padding()
        .previewLayout(.sizeThatFits)
}

#Preview("Attendance Voting") {
    AttendanceVotingView(
        userAttendance: PreviewData.sampleAttendances.first,
        isLoading: false,
        onVote: { _ in }
    )
    .padding()
    .previewLayout(.sizeThatFits)
}

#Preview("Vote Buttons") {
    HStack(spacing: 12) {
        ForEach(AttendanceStatus.allCases, id: \.self) { status in
            VoteButton(
                status: status,
                isSelected: status == .yes,
                isLoading: false,
                onTap: {}
            )
        }
    }
    .padding()
    .previewLayout(.sizeThatFits)
}