//
//  Title.swift
//  Movie
//
//  Created by ekaterina.shevchenko on 19.04.2026.
//

import SwiftData

struct TMDBAPIObject: Decodable {
    var results: [Title] = [] 
}

@Model
class Title: Decodable, Identifiable, Hashable{
    var id: Int?
    var title: String?
    var name: String?
    var overview: String?
    var posterPath: String?
    var voteAverage: Double?
    var voteCount: Int?
    
    init(
        id: Int? = nil,
        title: String? = nil,
        name: String? = nil,
        overview: String? = nil,
        posterPath: String? = nil,
        voteAverage: Double? = nil,
        voteCount: Int? = nil
    ) {
        self.id = id
        self.title = title
        self.name = name
        self.overview = overview
        self.posterPath = posterPath
        self.voteAverage = voteAverage
        self.voteCount = voteCount
    }
    
    enum CodingKeys: CodingKey {
        case id
        case title
        case name
        case overview
        case posterPath
        case voteAverage
        case voteCount
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        overview = try container.decodeIfPresent(String.self, forKey: .overview)
        posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath)
        voteAverage = try container.decodeIfPresent(Double.self, forKey: .voteAverage)
        voteCount = try container.decodeIfPresent(Int.self, forKey: .voteCount)
    }
    
    static var previewTitles = [
        Title(id: 1, title: "BeetleJuice", name: "BeetleJuice", overview: "A movie about BeetleJuice", posterPath: Constants.testTilteUrl),
        Title(id: 2, title: "Pulp Fiction", name: "Pulp Fiction", overview: "A movie about Pulp Fiction", posterPath: Constants.testTitleURL2),
        Title(id: 3, title: "The Dark Knight", name: "The Dark Knight", overview: "A movie about the Dark Knight", posterPath: Constants.testTitleURL3)
    ]
}
