//
//  ConstansEvents.swift
//  EventifyBackend
//
//  Created by Santiago Coto Vila on 21/9/25.
//
import Vapor
import Fluent

struct ConstantsEvents {
    static let schemaEvents   = "events"
    static let nameEvent: FieldKey = "nameEvent"
    static let descriptionEvent: FieldKey = "descriptionEvent"
    static let userID: FieldKey = "userID"
    static let category: FieldKey = "category"
    static let createdAt: FieldKey = "created_at"
    static let updatedAt: FieldKey = "updated_at"
    static let dateEvent: FieldKey = "dateEvent"
    static let lat: FieldKey = "lat"
    static let lng: FieldKey = "lng"
    static let locationName: FieldKey = "locationName"
}
