//
//  HomeScreenView.swift
//  Photo-Editor
//
//  Created by Anthony Muñiz on 10/20/24.
//

import SwiftUI

struct HomeScreenView: View {
    @Binding var recentImages: [UIImage]
    @Binding var trashedImages: [UIImage]
    @Binding var isLoading: Bool
    @State private var selectedImage: UIImage?
    @State private var isEditImageViewActive = false
    @State private var refreshID = UUID()

    private let photoController = PhotoController()

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    ScrollView {
                        MainButton(recentImages: $recentImages, onImageSelected: { image in
                            showLoadingAndNavigate(image: image)
                        })

                        Spacer()

                        HomeLibrary(
                            recentImages: recentImages,
                            onImageTap: { image in
                                selectedImage = image
                                isEditImageViewActive = true
                            },
                            onImageDelete: { image in
                                moveImageToTrash(image: image)
                            }
                        )
                        .id(refreshID)
                    }
                    .navigationTitle("Choose an image")
                    .navigationBarTitleDisplayMode(.inline)

                    NavigationLink(value: selectedImage) {
                        EmptyView()
                    }
                    .hidden()
                    .navigationDestination(isPresented: $isEditImageViewActive) {
                        EditImageView(
                            image: selectedImage ?? UIImage(),
                            onSave: { imageOrUrl in
                                Task {
                                    if let urlString = imageOrUrl as? String {
                                        if let downloadedImage = await photoController.downloadImage(from: urlString) {
                                            await saveImageToLibrary(image: downloadedImage)
                                        }
                                    } else if let image = imageOrUrl as? UIImage {
                                        await saveImageToLibrary(image: image)
                                    }
                                }
                            },
                            isLoading: $isLoading
                        )
                    }
                }
            }
            .onAppear {
                loadImages()
            }
        }
    }

    func showLoadingAndNavigate(image: UIImage) {
        isLoading = true
        Task {
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1-second delay for smoother transition
            await MainActor.run {
                selectedImage = image
                isEditImageViewActive = true
                isLoading = false
            }
        }
    }

    func saveImageToLibrary(image: UIImage) async {
        do {
            print("Starting to save image...")
            let savedPath = try await photoController.saveImageToDevice(image: image)
            print("Image saved at: \(savedPath)")

            await MainActor.run {
                recentImages.append(image)
                refreshID = UUID()
                photoController.saveImagePaths(images: recentImages, key: "recentImagePaths")
                print("Image saved and added to recentImages.")
                print("Current recentImages count: \(recentImages.count)")
            }
        } catch {
            print("Failed to save image: \(error.localizedDescription)")
        }
    }

    func moveImageToTrash(image: UIImage) {
        if let index = recentImages.firstIndex(of: image) {
            recentImages.remove(at: index)
            trashedImages.append(image)
            refreshID = UUID()
            photoController.saveImagePaths(images: recentImages, key: "recentImagePaths")
            photoController.saveImagePaths(images: trashedImages, key: "trashedImagePaths")
            print("Moved image to trash. Current Trash count: \(trashedImages.count)")
        }
    }

    func loadImages() {
        recentImages = photoController.loadImages(forKey: "recentImagePaths")
        trashedImages = photoController.loadImages(forKey: "trashedImagePaths")
    }
}

#Preview {
    HomeScreenView(
        recentImages: .constant([]),
        trashedImages: .constant([]),
        isLoading: .constant(false)
    )
}
