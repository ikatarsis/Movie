//
//  HomeView.swift
//  Movie
//
//  Created by ekaterina.shevchenko on 18.04.2026.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @State private var viewModel = ViewModel()
    @State private var titleDetailPath = NavigationPath()
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject private var authSession: AuthSession
    
    var body: some View {
        NavigationStack(path: $titleDetailPath){
            GeometryReader {geo in
                ScrollView(.vertical) {
                    switch viewModel.homeStatus {
                    case .notStarted, .fetching:
                        ProgressView()
                            .frame(width: geo.size.width, height: geo.size.height)
                    case .success:
                        LazyVStack {
                            AsyncImage(url: URL(string: viewModel.heroTitle.posterPath ?? "")){ image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .overlay {
                                        LinearGradient(
                                            stops: [Gradient.Stop(color: .clear, location: 0.8), Gradient.Stop(color: .gradient, location: 1)],
                                            startPoint: .top,
                                            endPoint: .bottom)
                                    }
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: geo.size.width, height: geo.size.height * 0.85)
                            
                            HStack {
                                Button {
                                    titleDetailPath.append(viewModel.heroTitle)
                                } label: {
                                    Text(Constants.playString)
                                        .ghostButton()
                                }
                                Button {
                                    modelContext.insert(viewModel.heroTitle)
                                    try? modelContext.save()
                                } label: {
                                    Text(Constants.downloadString)
                                        .ghostButton()
                                }
                            }
                            HorizontalListView(header: Constants.trendingMoviesString, titles: viewModel.trendingMovies) {title in
                                    titleDetailPath.append(title)
                                }
                            HorizontalListView(header: Constants.trendingTVString, titles: viewModel.trendingTV) {title in
                                titleDetailPath.append(title)
                            }
                            HorizontalListView(header: Constants.topRatedMovieString, titles: viewModel.topRatedMovies) {title in
                                titleDetailPath.append(title)
                            }
                            HorizontalListView(header: Constants.topRatedTVString, titles: viewModel.topRatedTV) {title in
                                titleDetailPath.append(title)
                            }
                        }
                        
                    case .failed(let error):
                        Text("Error, \(error.localizedDescription)")
                    }
                    
                }
                .task {
                    await viewModel.getTitle()
                }
                .navigationDestination(for: Title.self){ title in
                    TitleDetailView(title: title)
                }
            }
            .profileToolbar(session: authSession)

        }
    }
}

#Preview {
    HomeView()
}
