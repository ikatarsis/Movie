//
//  SignInViewModel.swift
//  Movie
//
//  Created by ekaterina.shevchenko on 09.05.2026.
//

import Foundation
import Combine

// @MainActor: чтобы безопасно обновлять @Published из async.
@MainActor
final class SignInViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    
    @Published private(set) var isLoading = false
    @Published private(set) var error: AuthError?
    
    private let signIn: SignInUseCase
    
    init(signIn: SignInUseCase){
        self.signIn = signIn
    }
    
    var canSubmit: Bool {
        !isLoading
        && !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && !password.isEmpty
    }
    
    var errorMessage: String? { error?.userMessage }
    
    func submit() async {
        self.error = nil
        self.isLoading = true
        defer { self.isLoading = false }
        
        do {
            try await signIn.execute(email: email, password: password)
        } catch let authError as AuthError {
            self.error = authError
        } catch let err {
            self.error = .unknown(message: err.localizedDescription)
        }
    }
}
