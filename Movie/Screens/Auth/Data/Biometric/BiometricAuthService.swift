//
//  BiometricAuthService.swift
//  Movie
//
//  Created by ekaterina.shevchenko on 09.05.2026.
//

import Foundation
import LocalAuthentication

enum BiometricAuthResult {
    case success
    case failed(Error)
    case notAvailable
    case userCancel
}

final class BiometricAuthService {
    func authenticate(reason: String) async -> BiometricAuthResult {
        let context = LAContext()
        context.localizedCancelTitle = "Отмена"
        
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .notAvailable
        }
        
        do {
            let ok = try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
            return ok ? .success : .failed(NSError(domain: "Bio", code: -1))
        } catch let err as LAError {
            if err.code == .userCancel || err.code == .authenticationFailed {
                return .userCancel
            }
            return .failed(err)
        } catch {
            return .failed(error)
        }
    }
}
