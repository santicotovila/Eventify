import Fluent
import Vapor

import Fluent
import Vapor

struct UsersDTO: Content {
    struct Create: Content {
        let name: String
        let email: String
        let password: String
        let interestIDs: [UUID]

        func toModel(withHashedPassword hashed: String) -> Users {
            Users(
                name: self.name,
                email: self.email,
                password: hashed,
                interests: [] //Comienza vacío pero se rellena tras adjuntar los intereses del  usuario.
            )
        }
    }

    struct Public: Content {
        let id: UUID
        let name: String
        let email: String
    }

    struct Detail: Content {
        let id: UUID
        let name: String
        let email: String
        let interests: [String]
    }
}
//MARK: - Validations
extension UsersDTO.Create: Validatable {
    static func validations(_ v: inout Vapor.Validations) {
        v.add("name", as: String.self, is: .count(3...30), required: true)
        v.add("email", as: String.self, is: .count(5...80) && .email, required: true)
        v.add("password", as: String.self, is: .count(8...64), required: true)
        v.add("interestIDs", as: [UUID].self, is: .count(3...6), required: true)
    }
}


extension Users {
    func toPublicDTO() throws -> UsersDTO.Public {
        .init(
            id: try requireID(),
            name: name,
            email: email
        )
    }

    func toDetailDTO() throws -> UsersDTO.Detail {
        .init(
            id: try requireID(),
            name: name,
            email: email,
            interests: interests 
        )
    }
}
