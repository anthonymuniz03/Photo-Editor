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
            .fill(Color.white.opacity(0.3))
            .frame(height: 100)
            .cornerRadius(10)
    }
}

#Preview {
    PlaceHolderImageView()
}
