

import Fluent
import Vapor

//Modelo pivot que conecta usuarios con intereses.

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
