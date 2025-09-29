//
//  ConstantsUserInterest.swift
//  EventifyBackend
//
//  Created by Santiago Coto Vila on 21/9/25.
//


import Fluent

//Constantes utilizadass para dar mas seguridad y evitar confuciones con los nombres
struct ConstantsUserInterests {
    static let schemaUserInterests = "user_interests"
    static let userID: FieldKey = "userID"
    static let interestID: FieldKey = "interestID"
}
