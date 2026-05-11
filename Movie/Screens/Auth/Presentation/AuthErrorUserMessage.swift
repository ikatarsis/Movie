//
//  AuthError.swift
//  Movie
//
//  Created by ekaterina.shevchenko on 09.05.2026.
//

import Foundation

extension AuthError {
    var userMessage: String {
        switch self {
        case .emptyEmail: return "Введите email"
        case .invalidEmail: return "Неверный формат email"
        case .emptyPassword: return "Введите пароль"
        case .weakPassword(let min): return "Пароль должен быть минимум \(min) символов"
        case .invalidCredentials: return "Неверный email или пароль"
        case .emailAlreadyExists: return "Этот email уже используется"
        case .network: return "Проверьте интернет-соединение"
        case .unknown(let message): return message
        case .bioAuthNotConfigured:
            return "Бекенд решил не настраиваться"
        case .bioAuthUnavailable:
            return "Face Id недоступен"
        case .bioAuthCanceled:
            return "Face Id отменен"
        case .bioAuthRemote(let message):
            return message
        }
    }
}
