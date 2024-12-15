//
//  HomeLibrary.swift
//  Photo-Editor
//
//  Created by Anthony Muñiz on 10/20/24.
//

import SwiftUI

struct HomeLibrary: View {
    let columns = [
        GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
    ]
    var recentImages: [UIImage]
    var onImageTap: (UIImage) -> Void
    var onImageDelete: (UIImage) -> Void

    var body: some View {
        if recentImages.isEmpty {
            VStack(spacing: 10) {
                Spacer()

                Text("Let's get started")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white.opacity(0.9))

                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text("•")
                        Text("Tap the large button")
                    }
                    HStack {
                        Text("•")
                        Text("Pick a picture")
                    }
                    HStack {
                        Text("•")
                        Text("Create")
                    }
                }
                .font(.headline)
                .foregroundColor(.white.opacity(0.7))
                .padding(.top, 5)

                Spacer()
            }
        } else {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(recentImages, id: \.self) { image in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .cornerRadius(10)
                        .clipped()
                        .onTapGesture {
                            onImageTap(image)
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                onImageDelete(image)
                            } label: {
                                Label("Move to Trash", systemImage: "trash")
                            }
                        }
                }
            }
            .padding()
        }
    }
}

#Preview {
    HomeLibrary(
        recentImages: [],
        onImageTap: { _ in },
        onImageDelete: { _ in }
    )
}
