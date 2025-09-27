//
//  LoginRepositoryProtocol.swift
//  EventifyAI
//
//  Created by Javier Gómez on 7/9/25.
//

import Foundation

protocol LoginRepositoryProtocol {
    func signIn(email: String, password: String) async throws -> UserModel
    func signUp(email: String, password: String) async throws -> UserModel
    func signOut() async throws
    func getCurrentUser() -> UserModel?
    func refreshToken() async throws -> String
    func isUserAuthenticated() -> Bool
    func getUserToken() -> String?
}