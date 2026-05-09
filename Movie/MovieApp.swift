//
//  MovieApp.swift
//  Movie
//
//  Created by ekaterina.shevchenko on 18.04.2026.
//

import SwiftUI
import SwiftData
import FirebaseCore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct MovieApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authSession = AuthSession()
    var body: some Scene {
        WindowGroup {
            Group {
                if authSession.user != nil {
                    ContentView()
                } else {
                    AuthView()
                }
            }
            .environmentObject(authSession)
        }
        .modelContainer(for: Title.self)
    }
}

