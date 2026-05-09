//
//  AuthError.swift
//  Movie
//
//  Created by ekaterina.shevchenko on 09.05.2026.
//

import Foundation

// Чтобы Presentation и Data говорили на одном “языке ошибок”, не протаскивая NSError/localizedDescription как архитектурную основу.

enum AuthError: Error, Equatable {
    case emptyEmail
    case invalidEmail
    case emptyPassword
    case weakPassword(min: Int)
    
    case invalidCredentials
    case emailAlreadyExists
    
    case network
    case unknown(message: String)
}
