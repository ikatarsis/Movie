//
//  VerticalListView.swift
//  Movie
//
//  Created by ekaterina.shevchenko on 02.05.2026.
//

import SwiftUI
import SwiftData

struct VerticalListView: View {
    var titles: [Title]
    var canDelete: Bool
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        List(titles) { title in
            NavigationLink {
                TitleDetailView(title: title)
            } label: {
                AsyncImage(url: URL(string: title.posterPath ?? "")) { image in
                    HStack {
                        image
                            .resizable()
                            .scaledToFit()
                            .clipShape(.rect(cornerRadius: 10))
                            .padding(5)
                        
                        Text((title.name ?? title.title) ?? "")
                            .font(.system(size: 14))
                            .bold()
                    }
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 150)
            }
            .swipeActions(edge: .leading) {
                if canDelete {
                    Button {
                        modelContext.delete(title)
                        try? modelContext.save()
                    } label: {
                        Image(systemName: "trash")
                            .tint(.red)
                    }
                }
            }
        }
    }
}

#Preview {
    VerticalListView(titles: Title.previewTitles, canDelete: true)
}
