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
    @State private var selectedImage: UIImage?
    @State private var isEditImageViewActive = false
    @State private var refreshID = UUID()
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    MainButton(recentImages: $recentImages)

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

                NavigationLink(
                    destination: EditImageView(
                        image: selectedImage ?? UIImage(),
                        onSave: { image in
                            Task {
                                await saveImageAndAddToLibrary(image: image)
                            }
                        }
                    ),
                    isActive: $isEditImageViewActive
                ) {
                    EmptyView()
                }
            }
            .onAppear {
                loadRecentImages()
                loadTrashedImages()
            }
        }
    }

    func saveImageAndAddToLibrary(image: UIImage) async {
        print("saveImageAndAddToLibrary function called...")

        do {
            print("Starting to save image...")
            let savedPath = try await saveImageToDevice(image: image)
            print("Image saved at: \(savedPath)")

            await MainActor.run {
                recentImages.append(image)
                refreshID = UUID()
                print("Image saved and added to recentImages.")
                print("Current recentImages count: \(recentImages.count)")
                saveRecentImagePaths()
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
            saveRecentImagePaths()
            saveTrashedImagePaths()
            print("Moved image to trash. Current Trash count: \(trashedImages.count)")
        }
    }

    func saveRecentImagePaths() {
        let imagePaths = recentImages.compactMap { image in
            let fileName = UUID().uuidString + ".jpg"
            let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documents.appendingPathComponent(fileName)

            if let data = image.jpegData(compressionQuality: 0.8) {
                try? data.write(to: fileURL)
                return fileURL.path
            }
            return nil
        }

        UserDefaults.standard.set(imagePaths, forKey: "recentImagePaths")
        print("Saved recent image paths: \(imagePaths)")
    }

    func saveTrashedImagePaths() {
        let imagePaths = trashedImages.compactMap { image in
            let fileName = UUID().uuidString + ".jpg"
            let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documents.appendingPathComponent(fileName)

            if let data = image.jpegData(compressionQuality: 0.8) {
                try? data.write(to: fileURL)
                return fileURL.path
            }
            return nil
        }

        UserDefaults.standard.set(imagePaths, forKey: "trashedImagePaths")
        print("Saved trashed image paths: \(imagePaths)")
    }

    func saveImageToDevice(image: UIImage) async throws -> URL {
        print("saveImageToDevice function called...")

        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .background).async {
                do {
                    print("Attempting to save image to device...")

                    let fileManager = FileManager.default
                    let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                    print("Document directory: \(documents.path)")

                    let fileName = UUID().uuidString + ".jpg"
                    let fileURL = documents.appendingPathComponent(fileName)

                    if let data = image.jpegData(compressionQuality: 0.8) {
                        print("JPEG data generated successfully.")
                        try data.write(to: fileURL)
                        print("Image successfully written to file: \(fileURL.path)")
                        continuation.resume(returning: fileURL)
                    } else {
                        print("Failed to generate JPEG data for image.")
                        throw NSError(domain: "ImageError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create image data"])
                    }
                } catch {
                    print("Error during saveImageToDevice: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func loadRecentImages() {
        let imagePaths = UserDefaults.standard.stringArray(forKey: "recentImagePaths") ?? []
        let loadedImages = imagePaths.compactMap { path -> UIImage? in
            let url = URL(fileURLWithPath: path)
            return UIImage(contentsOfFile: url.path)
        }
        recentImages = loadedImages
        refreshID = UUID()
        print("Loaded recentImages: \(recentImages.count)")
    }

    func loadTrashedImages() {
        let imagePaths = UserDefaults.standard.stringArray(forKey: "trashedImagePaths") ?? []
        let loadedImages = imagePaths.compactMap { path -> UIImage? in
            let url = URL(fileURLWithPath: path)
            return UIImage(contentsOfFile: url.path)
        }
        trashedImages = loadedImages
        print("Loaded trashedImages: \(trashedImages.count)")
    }
}


#Preview {
    HomeScreenView(recentImages: .constant([]), trashedImages: .constant([]))
}
