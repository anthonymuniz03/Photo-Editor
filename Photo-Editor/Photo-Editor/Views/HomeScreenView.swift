//
//  HomeScreenView.swift
//  Photo-Editor
//
//  Created by Anthony Muñiz on 10/20/24.
//

import SwiftUI

struct HomeScreenView: View {
    @State private var recentImages: [UIImage] = []
    @State private var selectedImage: UIImage?
    @State private var isEditImageViewActive = false

    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    MainButton(recentImages: $recentImages)
                    Spacer()
                    HomeLibrary(recentImages: recentImages, onImageTap: { image in
                        selectedImage = image
                        isEditImageViewActive = true
                    })
                }
                .navigationTitle("Choose an image")
                .navigationBarTitleDisplayMode(.inline)

                NavigationLink(
                    destination: EditImageView(image: selectedImage ?? UIImage()),
                    isActive: $isEditImageViewActive
                ) {
                    EmptyView()
                }
            }
        }
    }
}

#Preview {
    HomeScreenView()
}
