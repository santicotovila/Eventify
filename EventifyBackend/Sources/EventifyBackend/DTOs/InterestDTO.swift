//
//  InterestDTO.swift
//  EventifyBackend
//
//  Created by Santiago Coto Vila on 21/9/25.
//

import Vapor

//DTO de  Intereses con sus respectivas validaciones.
struct InterestDTO {
    struct Create: Content, Validatable {
        let name: String
        static func validations(_ v: inout Validations) {
            v.add("name", as: String.self, is: .count(1...), required: true)
        }
    }


    struct Update: Content, Validatable {
        let name: String?
        static func validations(_ v: inout Validations) {
            v.add("name", as: String?.self, is: .nil || .count(1...))
        }
    }

    struct Response: Content {
        let id: UUID
        let name: String
        let nameClean: String
    }
}

extension Interest {
    func toResponseDTO() throws -> InterestDTO.Response {
        .init(id: try requireID(), name: name, nameClean: nameClean)
    }
}
