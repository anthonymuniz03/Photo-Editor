//
//  PlaceHolderImageView.swift
//  Photo-Editor
//
//  Created by Anthony Muñiz on 10/20/24.
//

import SwiftUI

struct PlaceHolderImageView: View {
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
    PlaceHolderImageView()
}
