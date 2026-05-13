//
//  BioRefreshTokenKeychain.swift
//  Movie
//
//  Created by ekaterina.shevchenko on 10.05.2026.
//

import Foundation
import LocalAuthentication
import Security

enum BioRefreshTokenKeychainError: Error {
    case unexpectedStatus(OSStatus)
}

final class BioRefreshTokenKeychain {
    private let service = "com.MovieBuild.Movie.bioRefresh"
    private let account = "primary"
    
    // токен хранится не в UserDefaults, а в системном защищенном хранилище
    // он привзан к текущему набору биометрии .biometryCurrentSet
    func saveRefreshToken(_ token: String) throws {
        deleteRefreshToken()
        
        var error: Unmanaged<CFError>?
        
        guard let access = SecAccessControlCreateWithFlags(
            nil,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            [.biometryCurrentSet],
            &error
        ) else {
            throw AuthError.bioAuthUnavailable
        }
        
        guard let data = token.data(using: .utf8) else {
            throw AuthError.bioAuthRemote(message: "Неверный токен")
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessControl as String: access,
            kSecAttrSynchronizable as String: kCFBooleanFalse as Any,
        ]
        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw BioRefreshTokenKeychainError.unexpectedStatus(status)
        }
    }
    
    func readRefreshToken(reason: String) throws -> String {
            let context = LAContext()
            context.localizedCancelTitle = "Отмена"
            context.localizedReason = reason
        
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account,
                kSecReturnData as String: true,
                kSecMatchLimit as String: kSecMatchLimitOne,
                kSecUseAuthenticationContext as String: context,
                kSecAttrSynchronizable as String: kCFBooleanFalse as Any,
            ]
            var item: CFTypeRef?
            let status = SecItemCopyMatching(query as CFDictionary, &item)
            if status == errSecUserCanceled || status == errSecAuthFailed {
                throw AuthError.bioAuthCanceled
            }
            guard status == errSecSuccess, let data = item as? Data,
                  let string = String(data: data, encoding: .utf8) else {
                if status == errSecItemNotFound {
                    throw AuthError.bioAuthRemote(message: "Сохранённый вход не найден")
                }
                throw BioRefreshTokenKeychainError.unexpectedStatus(status)
            }
            return string
        }
    
    
    func deleteRefreshToken() {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account,
                kSecAttrSynchronizable as String: kCFBooleanFalse as Any,
            ]
            SecItemDelete(query as CFDictionary)
        }
}
