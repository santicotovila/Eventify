//
//  UserInterests.swift
//  EventifyBackend
//
//  Created by Santiago Coto Vila on 21/9/25.
//

import Fluent
import Vapor

final class UserInterest: Model, @unchecked Sendable {
    static let schema = ConstantsUserInterests.schemaUserInterests
    
    @ID(key: .id) var id: UUID?
    @Parent(key: ConstantsUserInterests.userID) var user: Users
    @Parent(key: ConstantsUserInterests.interestID) var interest: Interest
    
    init() {}
    
    init(userID: UUID, interestID: UUID) {
        self.$user.id = userID
        self.$interest.id = interestID
    }
}
