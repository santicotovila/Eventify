//
//  EvenStatus.swift
//  EventifyBackend
//
//  Created by Santiago Coto Vila on 21/9/25.
//
import Foundation

// Estado de asistencia de usuarios.

enum EventStatus: String, Codable, CaseIterable {
    case going, maybe, declined
}
