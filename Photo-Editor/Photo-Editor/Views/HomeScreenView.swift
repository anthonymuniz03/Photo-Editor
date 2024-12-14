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
    @State private var refreshID = UUID()

    private let photoController = PhotoController()

    var body: some View {
        NavigationStack {
            ZStack {
                Image("background")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack {
                    HStack {
                        Text("Choose an image")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.3))
                            )

                        Spacer()
                    }
                    .padding([.top, .horizontal], 20)

                    ScrollView {
                        VStack {
                            MainButton(
                                recentImages: $recentImages,
                                selectedImage: $selectedImage,
                                isEditImageViewActive: .constant(false),
                                onImageSelected: { image in
                                    showLoadingAndNavigate(image: image)
                                }
                            )
                            .padding(.top, 40)
                        }

                        Spacer()

                        HomeLibrary(
                            recentImages: recentImages,
                            onImageTap: { image in
                                selectedImage = image
                            },
                            onImageDelete: { image in
                                moveImageToTrash(image: image)
                            }
                        )
                        .id(refreshID)
                    }
                }

                if isLoading {
                    LoadingScreenView()
                        .zIndex(1)
                }
            }
            .navigationDestination(isPresented: Binding(
                get: { selectedImage != nil },
                set: { isPresented in if !isPresented { selectedImage = nil } }
            )) {
                if let image = selectedImage {
                    EditImageView(
                        image: image,
                        onSave: { imageOrUrl in
                            Task {
                                if let urlString = imageOrUrl as? String {
                                    if let downloadedImage = await photoController.downloadImage(from: urlString) {
                                        await saveImageToLibrary(image: downloadedImage)
                                    }
                                    loadImages()
                                } else if let image = imageOrUrl as? UIImage {
                                    await saveImageToLibrary(image: image)
                                    loadImages()
                                }
                            }
                        },
                        isLoading: $isLoading
                    )
                }
            }
            .toolbarBackground(.clear, for: .navigationBar)
            .toolbarBackground(.hidden, for: .navigationBar)
            .onAppear {
                loadImages()
            }
        }
    }

    func showLoadingAndNavigate(image: UIImage) {
        isLoading = true
        Task {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            await MainActor.run {
                selectedImage = image
                print("Selected Image: \(selectedImage != nil ? "Image set" : "Image not set")")
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
        photoController.loadImages(forKey: "recentImagePaths") { images in
            recentImages = images
            refreshID = UUID()
        }

        photoController.loadTrashedImages { images in
            trashedImages = images
            refreshID = UUID()
        }
    }
}

// MARK: - Preview

#Preview {
    HomeScreenView(
        recentImages: .constant([]),
        trashedImages: .constant([]),
        isLoading: .constant(false)
    )
}
