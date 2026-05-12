//
//  BioAuthAPIClient.swift
//  Movie
//
//  Created by ekaterina.shevchenko on 10.05.2026.
//

import Foundation

final class BioAuthAPIClient {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func mintBioRefreshToken(idToken: String) async throws -> String {
        let url = try BioAuthConfig.url(path: "mintBioRefreshToken")
        print("[FaceID] POST:", url.absoluteString)
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        req.httpBody = Data("{}".utf8)
        let (data, resp) = try await session.data(for: req)
        if let http = resp as? HTTPURLResponse {
            print("[FaceID] response status:", http.statusCode)
            print("[FaceID] response body:", String(data: data, encoding: .utf8) ?? "<empty>")
        }
        try throwIfHTTPError(data: data, response: resp)
        let decoded = try JSONDecoder().decode(MintBioRefreshResponse.self, from: data)
        return decoded.refreshToken
    }
    
    func exchangeBioRefreshToken(refreshToken: String) async throws -> ExchangeBioResponse {
        let url = try BioAuthConfig.url(path: "exchangeBioRefreshToken")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["refreshToken": refreshToken]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, resp) = try await session.data(for: req)
        try throwIfHTTPError(data: data, response: resp)
        return try JSONDecoder().decode(ExchangeBioResponse.self, from: data)
    }
    
    // 2. Вспомогательная функция (устраняет ошибку "Cannot find 'throwIfHTTPError'")
    private func throwIfHTTPError(data: Data, response: URLResponse) throws {
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthError.bioAuthRemote(message: "Неизвестный тип ответа сервера")
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let serverMessage = String(data: data, encoding: .utf8) ?? ""
                throw AuthError.bioAuthRemote(message: "Ошибка сервера (\(httpResponse.statusCode)): \(serverMessage)")
            }
        }
}
