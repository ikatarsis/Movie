//
//  SignInUseCase.swift
//  Movie
//
//  Created by ekaterina.shevchenko on 09.05.2026.
//

import Foundation

// место для правил, перед обращением к репозиторию

struct SignInUseCase {
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
        
        try await repository.signIn(email: trimed, password: password)
    }
}
