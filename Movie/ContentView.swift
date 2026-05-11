//
//  ContentView.swift
//  Movie
//
//  Created by ekaterina.shevchenko on 18.04.2026.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @State private var showProfile = false
    @EnvironmentObject private var authSession: AuthSession
    
    var body: some View {
        ZStack{
            TabView{
                Tab(Constants.homeString, systemImage: Constants.homeIconString){
                    HomeView()
                }
                Tab(Constants.upcomingString, systemImage: Constants.upcomingIconString){
                    UpcomingView()
                }
                Tab(Constants.searchString, systemImage: Constants.searchIconString){
                    SearchView()
                }
                Tab(Constants.downloadString, systemImage: Constants.downloadIconString){
                    DownloadView()
                }
            }
        }
    }
}

extension View {
    func profileToolbar(session: AuthSession) -> some View {
        toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Section {
                        Text(session.user?.email ?? "—")
                    }
                    Button("Выйти", role: .destructive) {
                        session.signOut()
                    }
                } label: {
                    Image(systemName: "person.circle.fill")
                }
            }
        }
    }
}


#Preview {
    ContentView()
}
