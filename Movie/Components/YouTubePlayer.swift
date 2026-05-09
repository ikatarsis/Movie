//
//  YouTubePlayer.swift
//  Movie
//
//  Created by ekaterina.shevchenko on 02.05.2026.
//

import SwiftUI
import WebKit

struct YouTubePlayer: UIViewRepresentable {
    let webView = WKWebView()
    let videoId: String
    let youtubeBaseURL = APIConfig.shared?.youtubeBaseURL
    
    func makeUIView(context: Context) -> some UIView {
        webView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        guard let baseURLString = youtubeBaseURL,
              let baseURL = URL(string: baseURLString) else {return}
        let fullURL = baseURL.appending(path: videoId)
        webView.load(URLRequest(url: fullURL))
    }
}
