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

    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(0..<15, id: \.self) { index in
                if index < recentImages.count {
                    Image(uiImage: recentImages[index])
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .cornerRadius(10)
                        .clipped()
                } else {
                    PlaceHolderImageView()
                }
            }
        }
        .padding()
    }
}

#Preview {
    HomeLibrary(recentImages: [UIImage(named: "placeholder")!])
}
