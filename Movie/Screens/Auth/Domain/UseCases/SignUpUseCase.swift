//
//  SignUpUseCase.swift
//  Movie
//
//  Created by ekaterina.shevchenko on 09.05.2026.
//

import Foundation

struct SignUpUseCase {
    let repository: AuthRepository
    
    func execute(email: String, password: String) async throws {
        let trimed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimed.isEmpty else {
            throw AuthError.emptyEmail
        }
        
        guard trimed.contains("@"), trimed.contains(".") else {
            throw AuthError.invalidEmail
        }
        
        guard !password.isEmpty else {
            throw AuthError.emptyPassword
        }
        
        guard password.count >= 6 else {
            throw AuthError.weakPassword(min: 6)
        }
        
        try await repository.signUp(email: trimed, password: password)
    }
}
