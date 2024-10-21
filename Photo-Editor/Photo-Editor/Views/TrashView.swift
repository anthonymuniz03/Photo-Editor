//
//  TrashView.swift
//  Photo-Editor
//
//  Created by Anthony Muñiz on 10/20/24.
//

import SwiftUI

struct TrashView: View {
    let columns = [
        GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(0..<18) { _ in
                        PlaceHolderImageView()
                    }
                }
                .padding()
            }
            .navigationTitle("Trash")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    TrashView()
}
