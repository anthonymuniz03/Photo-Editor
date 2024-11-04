//
//  HomeScreenView.swift
//  Photo-Editor
//
//  Created by Anthony Muñiz on 10/20/24.
//

import SwiftUI

struct HomeScreenView: View {
    @State private var recentImages: [UIImage] = []

    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    MainButton(recentImages: $recentImages)
                    Spacer()
                    HomeLibrary(recentImages: recentImages)
                }
                .navigationTitle("Choose an image")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .onChange(of: recentImages) { newImages in
            print("Recent images updated, total count: \(newImages.count)")
            newImages.enumerated().forEach { index, image in
                print("Image at index \(index): \(image)")
            }
        }
    }
}

#Preview {
    HomeScreenView()
}
