import Fluent
import Vapor

import Fluent
import Vapor

struct UsersDTO: Content {
    struct Create: Content {
        let name: String
        let email: String
        let password: String
        // 👇 ahora IDs de intereses (de la lista fija de la UI)
        let interestIDs: [UUID]

        // OJO: no metemos los IDs en el array de Strings del modelo.
        // Creamos el usuario "vacío" y luego adjuntamos por pivot.
        func toModel(withHashedPassword hashed: String) -> Users {
            Users(
                name: self.name,
                email: self.email,
                password: hashed,
                interests: [] // caché vacía; la rellenamos tras adjuntar
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
        let interests: [String] // tu caché, si la mantienes
    }
}

extension UsersDTO.Create: Validatable {
    static func validations(_ v: inout Vapor.Validations) {
        v.add("name", as: String.self, is: .count(3...30), required: true)
        v.add("email", as: String.self, is: .count(5...80) && .email, required: true)
        // 🔐 mejor sin .alphanumeric para permitir símbolos en la pass
        v.add("password", as: String.self, is: .count(8...64), required: true)
        // 👇 ahora validamos UUIDs (y mínimo 3)
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
            interests: interests   // tu caché [String]
        )
    }
}
