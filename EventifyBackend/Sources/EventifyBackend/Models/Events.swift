//
//  Interests.swift
//  EventifyBackend
//
//  Created by Santiago Coto Vila on 21/9/25.
//

import Fluent
import Vapor

final class Events: Model, @unchecked Sendable {
    static let schema = ConstantsEvents.schemaEvents
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: ConstantsEvents.nameEvent)
    var name: String
    
    @Field(key: ConstantsEvents.category)
    var category: String
    
    @Field(key: ConstantsEvents.lat)
    var lat: Double?
    
    @Field(key: ConstantsEvents.lng)
    var lng: Double?
    
    @Parent(key: ConstantsEvents.userID)
    var user: Users
    
    @Field(key: ConstantsEvents.dateEvent)
    var dateEvent: Date?
    
    @Field(key: ConstantsEvents.locationName)
    var locationName: String?
    
    @Timestamp(key: ConstantsEvents.createdAt, on: .create)
    var createdAt: Date?
    
    @Timestamp(key: ConstantsEvents.updatedAt, on: .update)
    var updatedAt: Date?
    
    init() {}
    
    
    init(name:String, category:String,userID:UUID,lat:Double? = nil ,lng:Double? = nil, dateEvent: Date? = nil, locationName: String? = nil) {
        self.name = name
        self.category = category
        self.$user.id = userID
        self.dateEvent = dateEvent
        self.locationName = locationName
        self.lat = lat
        self.lng = lng
    }
}





