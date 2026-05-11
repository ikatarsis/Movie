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
    
    init(
        api: BioAuthAPIClient = BioAuthAPIClient(),
        keychain: BioRefreshTokenKeychain = BioRefreshTokenKeychain(),
        authRepository: AuthRepository)
    {
        self.api = api
        self.keychain = keychain
        self.authRepository = authRepository
    }
    
    /// После успешного email/password и включённого тумблера
        func enableQuickSignIn() async throws {
            _ = try BioAuthConfig.url(path: "mintBioRefreshToken") // проверка URL
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
            let oldRefresh = try keychain.readRefreshToken(reason: reason)
            let exchange = try await api.exchangeBioRefreshToken(refreshToken: oldRefresh)
            try keychain.saveRefreshToken(exchange.refreshToken)
            try await authRepository.signIn(withCustomToken: exchange.customToken)
        }
}
