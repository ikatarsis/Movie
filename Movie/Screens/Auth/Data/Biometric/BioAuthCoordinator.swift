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
    
    /// После успешного email/password и включённого тумблера
    func enableQuickSignIn() async throws {
        print("[FaceID] enableQuickSignIn start")
        let url = try BioAuthConfig.url(path: "mintBioRefreshToken")
        print("[FaceID] mint URL:", url.absoluteString)
        guard let user = Auth.auth().currentUser else {
            print("[FaceID] currentUser is nil")
            throw AuthError.bioAuthRemote(message: "Нет активной сессии")
        }
        print("[FaceID] currentUser uid:", user.uid)
        let idToken = try await user.idTokenForcingRefresh(false)
        print("[FaceID] idToken received, length:", idToken.count)
        let refresh = try await api.mintBioRefreshToken(idToken: idToken)
        print("[FaceID] refresh token received, length:", refresh.count)
        try keychain.saveRefreshToken(refresh)
        print("[FaceID] keychain save success")
        BioQuickSignInStorage.isEnabled = true
        print("[FaceID] BioQuickSignInStorage set to true")
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
