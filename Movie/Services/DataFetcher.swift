//
//  DataFetcher.swift
//  Movie
//
//  Created by ekaterina.shevchenko on 19.04.2026.
//

import Foundation

struct DataFetcher {
    
    let tmdbBaseUrl = APIConfig.shared?.tmdbBaseURL
    let tmdbAPIKey = APIConfig.shared?.tmdbAPIKey
    let youtubeSearchUrl = APIConfig.shared?.youtubeSearchURL
    let youtubeAPIKey = APIConfig.shared?.youtubeAPIKey
    
    func fetchTitles(for media:String, by type:String, with title:String? = nil) async throws -> [Title] {
        let fetchTitlesURL = try buildURL(media: media, type: type, searchPhrase: title)
        guard let fetchTitlesURL = fetchTitlesURL else {
            throw NetforkError.urlBuildFailed
        }
        
        var titles = try await fetchAndDecode(url: fetchTitlesURL, type: TMDBAPIObject.self).results
        
        Constants.addPosterPath(to: &titles)
        return titles
    }
    
    func fetchVideoId(for title: String) async throws -> String {
        guard let baseSearchURL = youtubeSearchUrl else {
            throw NetforkError.missingConfig
        }
        
        guard let searchAPIKey = youtubeAPIKey else {
            throw NetforkError.missingConfig
        }
        
        let trailerSearch = title + YoutubeURLString.space.rawValue + YoutubeURLString.trailer.rawValue
        
        guard let fetchVideoURL = URL(string: baseSearchURL)?.appending(queryItems: [
            URLQueryItem(name: YoutubeURLString.queryShorten.rawValue, value: trailerSearch),
            URLQueryItem(name: YoutubeURLString.key.rawValue, value: searchAPIKey)
        ]) else {
            throw NetforkError.urlBuildFailed
        }
                
        return try await fetchAndDecode(url: fetchVideoURL, type: YouTubeSearchResponse.self).items?.first?.id?.videoId ?? ""
    }
    
    func fetchAndDecode<T: Decodable>(url: URL, type: T.Type) async throws -> T {
        let(data,urlResponse) = try await URLSession.shared.data(from: url)
        
        guard let response = urlResponse as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetforkError.badURLResponse(underlyingError: NSError(
                domain: "DataFetcher", code: (urlResponse as? HTTPURLResponse)?.statusCode ?? -1, userInfo: [NSLocalizedDescriptionKey: "Invalid HTTP Response"]
            ))
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try decoder.decode(type, from: data)
    }
    
    private func buildURL(media:String, type:String, searchPhrase: String? = nil) throws -> URL? {
        guard let baseURL = tmdbBaseUrl else {
            throw NetforkError.missingConfig
        }
        guard let apiKey = tmdbAPIKey else {
            throw NetforkError.missingConfig
        }
        
        var path:String
        if type == "trending" {
            path = "3/\(type)/\(media)/day"
        } else if type == "top_rated" || type == "upcoming" {
            path = "3/\(media)/\(type)"
        } else if type == "search" {
            path = "3/\(type)/\(media)"
        } else {
            throw NetforkError.urlBuildFailed
        }
        
        var urlQueryItems = [
            URLQueryItem(name: "api_key", value: apiKey)
        ]
        
        if let searchPhrase {
            urlQueryItems.append(URLQueryItem(name: "query", value: searchPhrase))
        }
        
        guard let url = URL(string: baseURL)?
            .appending(path: path)
            .appending(queryItems: urlQueryItems) else {
            throw NetforkError.urlBuildFailed
        }
        
        return url
    }
}
