//
//  SignUpViewModel.swift
//  Movie
//
//  Created by ekaterina.shevchenko on 09.05.2026.
//

import Foundation
import Combine

@MainActor
final class SignUpViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    
    @Published private(set) var isLoading = false
    @Published private(set) var error: AuthError?
    @Published private(set) var didComplete = false
    @Published var didTrySubmit = false
    
    private let signUp: SignUpUseCase
    
    init(signUp: SignUpUseCase) {
        self.signUp = signUp
    }
    
    var canSubmit: Bool {
        !isLoading
        && !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && !password.isEmpty
        && !confirmPassword.isEmpty
    }
    
    var errorMessage: String? { error?.userMessage }

    var emailFieldError: String? {
        guard didTrySubmit else { return nil }
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return AuthError.emptyEmail.userMessage }
        guard trimmed.contains("@"), trimmed.contains(".") else { return AuthError.invalidEmail.userMessage }
        return nil
    }

    var passwordFieldError: String? {
        guard didTrySubmit else { return nil }
        guard !password.isEmpty else { return AuthError.emptyPassword.userMessage }
        guard password.count >= 6 else { return AuthError.weakPassword(min: 6).userMessage }
        return nil
    }

    var confirmPasswordFieldError: String? {
        guard didTrySubmit else { return nil }
        guard !confirmPassword.isEmpty else { return "Введите пароль ещё раз" }
        guard password == confirmPassword else { return "Пароли не совпадают" }
        return nil
    }
    
    func submit() async {
        self.error = nil
        self.didComplete = false
        self.didTrySubmit = true

        // Если поля невалидны — показываем ошибки под полями и не идём в use case.
        guard emailFieldError == nil, passwordFieldError == nil, confirmPasswordFieldError == nil else {
            return
        }
        
        self.isLoading = true
        defer { self.isLoading = false }
        
        do {
            try await signUp.execute(email: email, password: password)
            self.didComplete = true
        } catch let authError as AuthError {
            self.error = authError
        } catch let err {
            self.error = .unknown(message: err.localizedDescription)
        }
    }
}
