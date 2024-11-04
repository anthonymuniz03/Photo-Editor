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
    var lastViewedImage: UIImage?

    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            if let lastImage = lastViewedImage {
                Image(uiImage: lastImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .cornerRadius(10)
            }
            
            ForEach(0..<15) { _ in
                PlaceHolderImageView()
            }
        }
        .padding()
    }
}

#Preview {
    HomeLibrary(lastViewedImage: UIImage(named: "placeholder"))
}

