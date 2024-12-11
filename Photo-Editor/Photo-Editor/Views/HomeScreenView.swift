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
    
    private let photoController = PhotoController()
    
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
                                    print("Cloudinary URL received: \(urlString)")
                                    if let downloadedImage = await photoController.downloadImage(from: urlString) {
                                        await saveImageToLibrary(image: downloadedImage)
                                    }
                                } else if let image = imageOrUrl as? UIImage {
                                    await saveImageToLibrary(image: image)
                                }
                            }
                        }
                    )
                }
            }
            .onAppear {
                loadImages()
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
                photoController.saveRecentImagePaths(images: recentImages)
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
            photoController.saveRecentImagePaths(images: recentImages)
            photoController.saveRecentImagePaths(images: trashedImages, key: "trashedImagePaths")
            print("Moved image to trash. Current Trash count: \(trashedImages.count)")
        }
    }
    
    func loadImages() {
        recentImages = photoController.loadRecentImages()
        trashedImages = photoController.loadTrashedImages()
    }
}

#Preview {
    HomeScreenView(recentImages: .constant([]), trashedImages: .constant([]))
}
