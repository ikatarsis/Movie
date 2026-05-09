//
//  ViewModel.swift
//  Movie
//
//  Created by ekaterina.shevchenko on 19.04.2026.
//

import Foundation

@Observable
class ViewModel {
    enum FetchStatus {
        case notStarted
        case fetching
        case success
        case failed(underlyingError: Error)
    }
    
    private(set) var homeStatus: FetchStatus = .notStarted
    private(set) var videoIdStatus: FetchStatus = .notStarted
    private(set) var upcomingStatus: FetchStatus = .notStarted
    
    private let dataFecher = DataFetcher()
    var trendingMovies: [Title] = []
    var trendingTV: [Title] = []
    var topRatedMovies: [Title] = []
    var topRatedTV: [Title] = []
    var upcomingMovies: [Title] = []
    var heroTitle = Title.previewTitles[0]
    var videoId = ""
    
    func getTitle() async {
        homeStatus = .fetching
        if trendingMovies.isEmpty {
            
            do {
                async let tMovies = dataFecher.fetchTitles(for: "movie", by: "trending")
                async let tTV = dataFecher.fetchTitles(for: "tv", by: "trending")
                async let tRMoview = dataFecher.fetchTitles(for: "movie", by: "top_rated")
                async let tRTV = dataFecher.fetchTitles(for: "tv", by: "top_rated")
                
                trendingMovies = try await tMovies
                trendingTV = try await tTV
                topRatedMovies = try await tRMoview
                topRatedTV = try await tRTV
                
                if let title = trendingMovies.randomElement(){
                    heroTitle = title
                }
                
                homeStatus = .success
            } catch {
                print(error)
                homeStatus = .failed(underlyingError: error)
            }
        }else {
            homeStatus = .success
        }
    }
    
    func getVideoId(for title: String) async {
        videoIdStatus = .fetching
        
        do {
            videoId = try await dataFecher.fetchVideoId(for: title)
            videoIdStatus = .success
        } catch {
            print(error)
            videoIdStatus = .failed(underlyingError: error)
        }
    }
    
    func getUpcomingMovies() async {
        upcomingStatus = .fetching
        
        do {
            upcomingMovies = try await dataFecher.fetchTitles(for: "movie", by: "upcoming")
            upcomingStatus = .success
        } catch {
            print(error)
            upcomingStatus = .failed(underlyingError: error)
        }
    }
}
