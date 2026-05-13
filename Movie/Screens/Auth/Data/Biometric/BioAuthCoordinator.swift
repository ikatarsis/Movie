//
//  BioAuthCoordinator.swift
//  Movie
//
//  Created by ekaterina.shevchenko on 10.05.2026.
//

import Foundation
import FirebaseAuth

@MainActor
final class BioAuthCoordinator {
    private let api: BioAuthAPIClient
    private let keychain: BioRefreshTokenKeychain
    private let authRepository: AuthRepository
    private let biometrics: BiometricAuthService
    
    init(
        api: BioAuthAPIClient = BioAuthAPIClient(),
        keychain: BioRefreshTokenKeychain = BioRefreshTokenKeychain(),
        biometrics: BiometricAuthService = BiometricAuthService(),
        authRepository: AuthRepository)
    {
        self.api = api
        self.keychain = keychain
        self.biometrics = biometrics
        self.authRepository = authRepository
    }
    
    // 3. Берется текущий Firebase.currentUser
    // - вытаскиваем idToken
    // - idToken уходит на бек в mintBioRefreshToken
    // - бек проверяет, что пользак настоящий
    // - бек создает специальный токен
    // - возвращает нам. Мы сохраняем в Keychaim
    // - BioQuickDignInStorage.isEnabled = true
    func enableQuickSignIn() async throws {
        
        let url = try BioAuthConfig.url(path: "mintBioRefreshToken")
        
        guard let user = Auth.auth().currentUser else {
            throw AuthError.bioAuthRemote(message: "Нет активной сессии")
        }
        
        let idToken = try await user.idTokenForcingRefresh(false)
        let refresh = try await api.mintBioRefreshToken(idToken: idToken)
        
        try keychain.saveRefreshToken(refresh)
        BioQuickSignInStorage.isEnabled = true
    }
    
    func disableQuickSignIn() {
            keychain.deleteRefreshToken()
            BioQuickSignInStorage.clear()
        }
        /// Экран входа: есть сохранённый refresh
        func signInWithStoredBio(reason: String = "Войдите для доступа к аккаунту") async throws {
            guard BioQuickSignInStorage.isEnabled else {
                throw AuthError.bioAuthRemote(message: "Быстрый вход не включён")
            }
            _ = try BioAuthConfig.url(path: "exchangeBioRefreshToken")

            // Явный biometric challenge: гарантирует системный prompt (в т.ч. в симуляторе).
            switch await biometrics.authenticate(reason: reason) {
            case .success:
                break
            case .notAvailable:
                throw AuthError.bioAuthUnavailable
            case .userCancel:
                throw AuthError.bioAuthCanceled
            case .failed(let error):
                throw AuthError.bioAuthRemote(message: error.localizedDescription)
            }

            let oldRefresh = try keychain.readRefreshToken(reason: reason)
            let exchange = try await api.exchangeBioRefreshToken(refreshToken: oldRefresh)
            try keychain.saveRefreshToken(exchange.refreshToken)
            try await authRepository.signIn(withCustomToken: exchange.customToken)
        }
}
