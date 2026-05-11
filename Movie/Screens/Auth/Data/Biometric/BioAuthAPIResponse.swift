//
//  BioAuthAPIResponse.swift
//  Movie
//
//  Created by ekaterina.shevchenko on 10.05.2026.
//

import Foundation

struct MintBioRefreshResponse: Decodable {
    let refreshToken: String
}

struct ExchangeBioResponse: Decodable {
    let customToken: String
    let refreshToken: String
}

struct BioAuthErrorBody: Decodable {
    let error: String?
}
