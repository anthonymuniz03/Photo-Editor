//
//  GalleryView.swift
//  Photo-Editor
//
//  Created by Anthony Muñiz on 10/20/24.
//

import SwiftUI

struct GalleryView: View {
    @Binding var recentImages: [UIImage]
    @Binding var trashedCloudImageURLs: [String]
    @State private var cloudImageURLs: [String] = []
    @State private var currentPage = 1
    @State private var isRefreshing = false
    @State private var selectedImage: UIImage?
    @State private var showEditView = false
    @State private var isLoading = false
    @State private var error: ErrorWrapper?

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
                    headerView

                    if cloudImageURLs.isEmpty {
                        emptyStateView
                    } else {
                        galleryGridView
                    }
                }
                .navigationDestination(isPresented: $showEditView) {
                    if let image = selectedImage {
                        EditImageView(
                            image: image,
                            onSave: { imageOrUrl in
                                handleSave(imageOrUrl: imageOrUrl)
                            },
                            isLoading: $isLoading
                        )
                    }
                }

                if isLoading {
                    ProgressView("Loading...")
                        .progressViewStyle(.circular)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(12)
                }
            }
            .onAppear {
                loadCloudImages()
            }
            .alert(item: $error) { error in
                Alert(title: Text("Error"), message: Text(error.message), dismissButton: .default(Text("OK")))
            }
        }
    }

    private var headerView: some View {
        HStack {
            Text("Cloud Save")
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

            Button(action: refreshGallery) {
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
    }

    private var emptyStateView: some View {
        VStack(spacing: 10) {
            Spacer()
            Text("Don't worry!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white.opacity(0.9))
            Text("If you ever accidentally delete an image or clear your cache, a copy will be saved here in the cloud!")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal, 30)
            Spacer()
        }
    }

    private var galleryGridView: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(cloudImageURLs, id: \.self) { urlString in
                    CloudImageView(urlString: urlString) { thumbnail in
                        Task {
                            if let fullImage = await photoController.downloadImage(from: urlString) {
                                selectedImage = fullImage
                                showEditView = true
                            } else {
                                error = ErrorWrapper(message: "Failed to download full-size image.")
                            }
                        }
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            deleteCloudImage(urlString: urlString)
                        } label: {
                            Label("Delete", systemImage: "trash")
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

    func deleteCloudImage(urlString: String) {
        isLoading = true
        Task {
            photoController.deleteCloudImage(urlString: urlString)
            cloudImageURLs.removeAll { $0 == urlString }
            trashedCloudImageURLs.append(urlString)
            photoController.saveCloudImageURLs(urls: cloudImageURLs)
            photoController.saveTrashedCloudImageURLs(urls: trashedCloudImageURLs)
            isLoading = false
        }
    }

    func handleSave(imageOrUrl: Any) {
        if let urlString = imageOrUrl as? String {
            Task {
                if let downloadedImage = await photoController.downloadImage(from: urlString) {
                    await saveImageToLibrary(image: downloadedImage)
                } else {
                    error = ErrorWrapper(message: "Failed to download image.")
                }
            }
        } else if let image = imageOrUrl as? UIImage {
            Task {
                await saveImageToLibrary(image: image)
            }
        }

        loadCloudImages()
        isLoading = false
    }

    func saveImageToLibrary(image: UIImage) async {
        photoController.saveImageToDevice(image: image) { saveError in
            if let saveError = saveError {
                error = ErrorWrapper(message: "Failed to save image: \(saveError.localizedDescription)")
            } else {
                Task {
                    await MainActor.run {
                        recentImages.append(image)
                        photoController.saveImagePaths(images: recentImages, key: "recentImagePaths")
                        print("Image saved to library and added to recent images.")
                    }
                }
            }
        }
    }

}

struct CloudImageView: View {
    let urlString: String
    let onImageTap: (UIImage) -> Void

    @State private var thumbnailData: Data?
    @State private var fullImage: UIImage?

    var body: some View {
        ZStack {
            if let data = thumbnailData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .cornerRadius(10)
                    .clipped()
                    .onTapGesture {
                        if let fullImage = fullImage {
                            onImageTap(fullImage)
                        }
                    }
            } else {
                PlaceHolderImageView()
                    .frame(width: 100, height: 100)
                    .cornerRadius(10)
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
                if let image = UIImage(data: data) {
                    let thumbnail = generateThumbnail(from: image, targetSize: CGSize(width: 100, height: 100))
                    await MainActor.run {
                        self.thumbnailData = thumbnail?.jpegData(compressionQuality: 0.7)
                        self.fullImage = image
                    }
                }
            } catch {
                print("Error loading image: \(error)")
            }
        }
    }

    // Helper function to generate a thumbnail
    func generateThumbnail(from image: UIImage, targetSize: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}


struct ErrorWrapper: Identifiable {
    let id = UUID()
    let message: String
}

#Preview {
    GalleryView(recentImages: .constant([]), trashedCloudImageURLs: .constant([]))
}
