//
//  Errors.swift
//  Movie
//
//  Created by ekaterina.shevchenko on 19.04.2026.
//

import Foundation

enum APIConfigError: Error, LocalizedError {
    case fileNotFound
    case dataLoadingFailed(underlyingError: Error)
    case daecodingFailed(underlyingError: Error)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "API configuration file not found"
        case .dataLoadingFailed(underlyingError: let error):
            return "Failed to load data from API configuration file \(error.localizedDescription)"
        case .daecodingFailed(underlyingError: let error):
            return "Failed to decode API configaration: \(error.localizedDescription)"
        }
    }
}

enum NetforkError: Error, LocalizedError {
    case badURLResponse(underlyingError: Error)
    case missingConfig
    case urlBuildFailed
    
    var errorDescription: String? {
        switch self {
        case .badURLResponse(underlyingError: let error):
            return "Failed to parse URL response: \(error.localizedDescription)"
        case .missingConfig:
            return "Missing API configuration"
        case .urlBuildFailed:
            return "Failed to build URL"
        }
    }
}
