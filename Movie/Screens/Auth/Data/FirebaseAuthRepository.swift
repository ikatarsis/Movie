//
//  FirebaseAuthRepository.swift
//  Movie
//
//  Created by ekaterina.shevchenko on 09.05.2026.
//

import Foundation
import FirebaseAuth

final class FirebaseAuthRepository: AuthRepository {
    func signIn(email: String, password: String) async throws {
        do {
            _ = try await Auth.auth().signIn(withEmail: email, password: password)
        } catch {
            throw map(error)
        }
    }
    
    func signIn(withCustomToken token: String) async throws {
        do {
            _ = try await Auth.auth().signIn(withCustomToken: token)
        } catch {
            throw map(error)
        }
    }
    
    func signUp(email: String, password: String) async throws{
        do {
            _ = try await Auth.auth().createUser(withEmail: email, password: password)
        } catch {
            throw map(error)
        }
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    private func map (_ error: Error) -> AuthError {
        let nsError = error as NSError
        let code = AuthErrorCode(rawValue: nsError.code)
        
        switch code {
        case .wrongPassword, .userNotFound:
            return .invalidCredentials
        case .invalidEmail:
            return .invalidEmail
        case .emailAlreadyInUse:
            return .emailAlreadyExists
        case .networkError:
            return .network
        default:
            return .unknown(message: error.localizedDescription)
        }
    }
}
