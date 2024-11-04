//
//  AlbumView.swift
//  Photo-Editor
//
//  Created by Anthony Muñiz on 11/4/24.
//

import SwiftUI

struct AlbumView: View {
    let album: AlbumID

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(album.images, id: \.self) { image in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .navigationTitle(album.name)
    }
}

#Preview {
    AlbumView(album: AlbumID(name: "Example Album", images: []))
}
