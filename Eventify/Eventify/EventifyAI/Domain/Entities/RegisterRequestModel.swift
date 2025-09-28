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
    
    // Función para extraer el userID del JWT sin verificar la firma
    var userID: String? {
        guard let payload = JWTHelper.extractPayload(from: accessToken),
              let userIDString = payload["userID"] as? String else {
            return nil
        }
        return userIDString
    }
}

// Helper para extraer payload del JWT sin verificar firma
struct JWTHelper {
    static func extractPayload(from token: String) -> [String: Any]? {
        let segments = token.components(separatedBy: ".")
        guard segments.count == 3 else { return nil }
        
        let payloadSegment = segments[1]
        guard let payloadData = base64UrlDecode(payloadSegment) else { return nil }
        
        do {
            let json = try JSONSerialization.jsonObject(with: payloadData, options: [])
            return json as? [String: Any]
        } catch {
            return nil
        }
    }
    
    private static func base64UrlDecode(_ value: String) -> Data? {
        var base64 = value
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        let padding = base64.count % 4
        if padding > 0 {
            base64 += String(repeating: "=", count: 4 - padding)
        }
        
        return Data(base64Encoded: base64)
    }
}