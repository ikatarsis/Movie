//
//  BioAuthConfig.swift
//  Movie
//
//  Created by ekaterina.shevchenko on 10.05.2026.
//

import Foundation

enum BioAuthConfig {
    static var functionsBaseURL: String? {
            guard let raw = Bundle.main.object(forInfoDictionaryKey: "BioAuthFunctionsBaseURL") as? String else {
                return nil
            }
            
            let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else {
                return nil
            }
            
            return trimmed.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        }
    
    static func url(path: String) throws -> URL {
        guard let base = functionsBaseURL else {
            throw AuthError.bioAuthNotConfigured
        }
        let p = path.hasPrefix("/") ? String(path.dropFirst()) : path
        guard let url = URL(string: base + "/" + p) else {
            throw AuthError.bioAuthRemote(message: "Неверный URL функций")
        }
        return url
    }
}
