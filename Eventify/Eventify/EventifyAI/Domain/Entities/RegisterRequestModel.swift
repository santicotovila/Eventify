//
//  RegisterRequestModel.swift
//  EventifyAI
//
//  Created by Javier Gómez on 6/9/25.
//

import Foundation
struct RegisterRequestModel: Codable {
    let name: String
    let email: String
    let password: String
    let interestIDs: [String] // UUIDs como strings
}

// Modelo de respuesta del registro (JWT Token)
struct RegisterResponseModel: Codable {
    let accessToken: String
    let refreshToken: String
}