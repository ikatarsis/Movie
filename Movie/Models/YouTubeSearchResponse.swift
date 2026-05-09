//
//  YouTubeSearchResponse.swift
//  Movie
//
//  Created by ekaterina.shevchenko on 02.05.2026.
//

import Foundation

struct YouTubeSearchResponse: Codable {
    let items: [ItemProperties]?
}

struct ItemProperties: Codable {
    let id: IdProperties?
}

struct IdProperties: Codable {
    let videoId: String?
}
