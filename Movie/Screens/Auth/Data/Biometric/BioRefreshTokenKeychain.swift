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
            ]
            let status = SecItemAdd(query as CFDictionary, nil)
            guard status == errSecSuccess else {
                throw BioRefreshTokenKeychainError.unexpectedStatus(status)
            }
        }
    
    func readRefreshToken(reason: String) throws -> String {
            let context = LAContext()
            context.localizedCancelTitle = "Отмена"
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account,
                kSecReturnData as String: true,
                kSecMatchLimit as String: kSecMatchLimitOne,
                kSecUseAuthenticationContext as String: context,
                kSecUseOperationPrompt as String: reason,
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
            ]
            SecItemDelete(query as CFDictionary)
        }
}
