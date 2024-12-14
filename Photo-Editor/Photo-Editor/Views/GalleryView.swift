//
//  GalleryView.swift
//  Photo-Editor
//
//  Created by Anthony Muñiz on 10/20/24.
//

import SwiftUI

struct GalleryView: View {
    @Binding var recentImages: [UIImage]
    @State private var cloudImageURLs: [String] = []
    @State private var currentPage = 1
    @State private var isRefreshing = false
    @State private var selectedImage: UIImage?
    @State private var showEditView = false

    private let pageSize = 12
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
                        Text("Cloud Gallery")
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

                        Button(action: {
                            refreshGallery()
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.white)
                                .padding(10)
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.3))
                                )
                        }
                    }
                    .padding([.top, .horizontal], 20)

                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            ForEach(cloudImageURLs, id: \.self) { urlString in
                                CloudImageView(urlString: urlString) { image in
                                    if let resizedImage = image.resized(to: CGSize(width: 800, height: 800)) {
                                        selectedImage = resizedImage
                                        showEditView = true
                                    } else {
                                        print("Failed to resize image.")
                                    }
                                }
                            }
                        }
                        .padding()
                        .refreshable {
                            refreshGallery()
                        }
                    }
                }
                .navigationDestination(isPresented: $showEditView) {
                    if let image = selectedImage {
                        EditImageView(
                            image: image,
                            onSave: { imageOrUrl in
                                Task {
                                    if let urlString = imageOrUrl as? String {
                                        if let downloadedImage = await photoController.downloadImage(from: urlString) {
                                            await saveImageToLibrary(image: downloadedImage)
                                        }
                                    } else if let image = imageOrUrl as? UIImage {
                                        await saveImageToLibrary(image: image)
                                    }
                                    loadCloudImages()
                                }
                            },
                            isLoading: .constant(false)
                        )
                    }
                }
            }
            .onAppear {
                loadCloudImages()
            }
        }
    }

    // MARK: - Functions

    func loadCloudImages() {
        cloudImageURLs = photoController.loadCloudImageURLs(page: currentPage, pageSize: pageSize)
    }

    func refreshGallery() {
        isRefreshing = true
        Task {
            loadCloudImages()
            isRefreshing = false
        }
    }

    func saveImageToLibrary(image: UIImage) async {
        do {
            try await photoController.saveImageToDevice(image: image)
            await MainActor.run {
                recentImages.append(image)
                photoController.saveImagePaths(images: recentImages, key: "recentImagePaths")
            }
            print("Image saved to library and added to recent images.")
        } catch {
            print("Failed to save image: \(error.localizedDescription)")
        }
    }
}

struct CloudImageView: View {
    let urlString: String
    let onImageTap: (UIImage) -> Void

    @State private var imageData: Data?

    var body: some View {
        ZStack {
            if let data = imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .cornerRadius(10)
                    .clipped()
                    .onTapGesture {
                        onImageTap(uiImage)
                    }
            } else {
                ProgressView()
                    .frame(width: 100, height: 100)
                    .onAppear {
                        loadImage()
                    }
            }
        }
    }

    private func loadImage() {
        guard let url = URL(string: urlString) else { return }
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                await MainActor.run {
                    self.imageData = data
                }
            } catch {
                print("Error loading image: \(error)")
            }
        }
    }
}

// MARK: - Preview

#Preview {
    GalleryView(recentImages: .constant([]))
}
