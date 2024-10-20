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
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(0..<15) { _ in
                PlaceholderImageView()
            }
        }
        .padding()
    }
}

struct PlaceholderImageView: View {
    var body: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .frame(height: 100)
            .overlay(
                Text("Image")
                    .foregroundColor(.black)
                    .font(.caption)
            )
            .cornerRadius(10)
    }
}

#Preview {
    HomeLibrary()
}
