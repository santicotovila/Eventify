//
//  NetworkLogin.swift
//  EventifyAI
//
//  Created by Javier Gómez on 14/9/25.
//

import Foundation

protocol NetworkLoginProtocol {
    func signIn(email: String, password: String) async throws -> UserModel
    func signUp(email: String, password: String, name: String) async throws -> UserModel
    func signOut() async throws
    func refreshToken() async throws -> String
}

final class NetworkLogin: NetworkLoginProtocol {
    
    private let mockUsers: [UserModel] = [
        UserModel(
            id: "user-1",
            email: "demo@eventifyai.com",
            displayName: "Usuario Demo"
        ),
        UserModel(
            id: "user-2",
            email: "carlos@eventifyai.com",
            displayName: "Carlos Ruiz"
        ),
        UserModel(
            id: "user-3",
            email: "maria@eventifyai.com",
            displayName: "María López"
        )
    ]
    
    func signIn(email: String, password: String) async throws -> UserModel {
        try await Task.sleep(nanoseconds: 1_200_000_000)
        
        guard !email.isEmpty else {
            throw NetworkError.invalidURL
        }
        
        guard password.count >= ConstantsApp.Validation.minPasswordLength else {
            throw NetworkError.requestFailed(.badRequest)
        }
        
        if email == "demo@eventifyai.com" && password == "123456" {
            return mockUsers[0]
        } else if email == "carlos@eventifyai.com" && password == "password" {
            return mockUsers[1]
        } else if email == "maria@eventifyai.com" && password == "password" {
            return mockUsers[2]
        } else {
            throw NetworkError.unauthorized
        }
    }
    
    func signUp(email: String, password: String, name: String) async throws -> UserModel {
        try await Task.sleep(nanoseconds: 1_500_000_000)
        
        guard !email.isEmpty, email.contains("@") else {
            throw NetworkError.requestFailed(.badRequest)
        }
        
        guard password.count >= ConstantsApp.Validation.minPasswordLength else {
            throw NetworkError.requestFailed(.badRequest)
        }
        
        guard !name.isEmpty else {
            throw NetworkError.requestFailed(.badRequest)
        }
        
        if mockUsers.contains(where: { $0.email.lowercased() == email.lowercased() }) {
            throw NetworkError.conflict
        }
        
        let newUser = UserModel(
            id: "user-\(UUID().uuidString)",
            email: email,
            displayName: name
        )
        
        return newUser
    }
    
    func signOut() async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
    }
    
    func refreshToken() async throws -> String {
        try await Task.sleep(nanoseconds: 800_000_000)
        
        return "mock-jwt-token-\(UUID().uuidString)"
    }
}