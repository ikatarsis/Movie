//
//  SearchView.swift
//  Movie
//
//  Created by ekaterina.shevchenko on 02.05.2026.
//

import SwiftUI

enum SearchSort: Hashable, CaseIterable {
    case ratingDesc
    case voteDesc
}

struct SearchView: View {
    @State private var searchByMovies = true
    @State private var searchText = ""
    
    @State private var navigationPath = NavigationPath()
    
    @State private var sort: SearchSort = .ratingDesc
    @State private var minRating: Double = 0.0
    @State private var minVoteCount: Int = 0
    
    
    private let searchViewModel = SearchViewModel()
    private var filteredTitles: [Title] {
        let filtered = searchViewModel.searchTitles.filter { t in
            (t.voteAverage ?? 0) >= minRating &&
            (t.voteCount ?? 0) >= minVoteCount
        }
        switch sort {
        case .ratingDesc:
            return filtered.sorted { ($0.voteAverage ?? -1) > ($1.voteAverage ?? -1) }
        case .voteDesc:
            return filtered.sorted { ($0.voteCount ?? -1) > ($1.voteCount ?? -1) }
        }
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                if let error = searchViewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(.rect(cornerRadius: 10))
                }
                LazyVGrid(columns: [GridItem(), GridItem(),GridItem()]) {
                    ForEach(filteredTitles) { title in
                        AsyncImage(url: URL(string: title.posterPath ?? "")) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .clipShape(.rect(cornerRadius: 10))
                                .overlay(alignment: .topTrailing) {
                                    if let r = title.voteAverage, r > 0 {
                                    Text(String(format: "%.1f", r))
                                        .font(.caption.weight(.semibold))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 3)
                                        .background(.black.opacity(0.6))
                                        .foregroundStyle(.white)
                                        .clipShape(.capsule)
                                        .padding(6)
                                    }
                                }
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 120, height: 200)
                        .onTapGesture {
                            navigationPath.append(title)
                        }
                    }
                }
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                HStack {
                    Menu {
                        Picker("Sort", selection: $sort) {
                            Text("Rating").tag(SearchSort.ratingDesc)
                            Text("Votes").tag(SearchSort.voteDesc)
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                    .buttonStyle(.bordered)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(.bar)
            }
            .navigationTitle(searchByMovies ? Constants.movieSearchString : Constants.tvSearchString)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        searchByMovies.toggle()
                        
                        Task {
                            await searchViewModel.getSearchTitles(by: searchByMovies ? "movie" : "tv", for: searchText)
                        }
                    } label: {
                        Image(systemName: searchByMovies ? Constants.movieIconString : Constants.tvIconString)
                    }
                }
            }
            .searchable(text: $searchText, prompt: searchByMovies ? Constants.moviePlaceHolderString : Constants.tvPlaceHolderString)
            .task(id: searchText) {
                try? await Task.sleep(for: .milliseconds(500))
                
                if Task.isCancelled {
                    return
                }
                
                await searchViewModel.getSearchTitles(by: searchByMovies ? "movie" : "tv", for: searchText)
            }
            .navigationDestination(for: Title.self) {title in
                    TitleDetailView(title: title)
            }
        }
    }
}

#Preview {
    SearchView()
}
