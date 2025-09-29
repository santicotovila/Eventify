//
//  ConstantsEventsAttendees.swift
//  EventifyBackend
//
//  Created by Santiago Coto Vila on 21/9/25.
//

import Fluent

//Constantes utilizadass para dar mas seguridad y evitar confuciones con los nombres
struct ConstantsEventAttendees {
    static let schema = "event_attendees"
    static let eventID: FieldKey = "eventID"
    static let userID: FieldKey  = "userID"
    static let status: FieldKey  = "status"
    static let joinedAt: FieldKey = "joined_at"
    static let updatedAt: FieldKey = "updated_at"
}
