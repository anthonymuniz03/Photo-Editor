//
//  TrashView.swift
//  Photo-Editor
//
//  Created by Anthony Muñiz on 10/20/24.
//

import SwiftUI

struct TrashView: View {
    @Binding var trashedImages: [UIImage]
    @Binding var recentImages: [UIImage]
    @Binding var trashedCloudImageURLs: [String]
    @State private var refreshID = UUID()
    @State private var showDeleteAllAlert = false
    @State private var showDeleteSingleAlert = false
    @State private var imageToDelete: UIImage?
    @State private var cloudImageURLToDelete: String?

    private let photoController = PhotoController()

    let columns = [
        GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Image("background")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack {
                    HStack {
                        Text("Trash")
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
                            showDeleteAllAlert = true
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Empty Trash")
                            }
                            .font(.headline)
                            .foregroundColor(.red)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.3))
                            )
                        }
                    }
                    .padding([.top, .horizontal], 20)

                    if trashedImages.isEmpty && trashedCloudImageURLs.isEmpty {
                        Spacer()
                        Text("No images in Trash")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.7))
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(trashedImages.indices, id: \.self) { index in
                                    Image(uiImage: trashedImages[index])
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .cornerRadius(10)
                                        .clipped()
                                        .contextMenu {
                                            Button {
                                                restoreImage(image: trashedImages[index])
                                            } label: {
                                                Label("Restore", systemImage: "arrow.uturn.left")
                                            }

                                            Button(role: .destructive) {
                                                imageToDelete = trashedImages[index]
                                                showDeleteSingleAlert = true
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                }

                                ForEach(trashedCloudImageURLs, id: \.self) { urlString in
                                    CloudImageView(urlString: urlString) { _ in }
                                        .frame(width: 100, height: 100)
                                        .cornerRadius(10)
                                        .clipped()
                                        .contextMenu {
                                            Button {
                                                restoreCloudImage(urlString: urlString)
                                            } label: {
                                                Label("Restore", systemImage: "arrow.uturn.left")
                                            }

                                            Button(role: .destructive) {
                                                cloudImageURLToDelete = urlString
                                                showDeleteSingleAlert = true
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .toolbarBackground(.hidden)
            .onAppear {
                loadTrashedImages()
                loadTrashedCloudImages()
            }
            .alert("Empty Trash", isPresented: $showDeleteAllAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete All", role: .destructive) {
                    deleteAllImages()
                }
            } message: {
                Text("Are you sure you want to permanently delete all items in the trash?")
            }
            .alert("Delete Image", isPresented: $showDeleteSingleAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let image = imageToDelete {
                        deleteSingleImage(image: image)
                    } else if let urlString = cloudImageURLToDelete {
                        deleteSingleCloudImage(urlString: urlString)
                    }
                }
            } message: {
                Text("Are you sure you want to permanently delete this image?")
            }
        }
    }

    func restoreImage(image: UIImage) {
        if let index = trashedImages.firstIndex(of: image) {
            trashedImages.remove(at: index)
            recentImages.append(image)
            refreshID = UUID()
            photoController.saveImagePaths(images: recentImages, key: "recentImagePaths")
            photoController.saveImagePaths(images: trashedImages, key: "trashedImagePaths")
        }
    }

    func restoreCloudImage(urlString: String) {
        if let index = trashedCloudImageURLs.firstIndex(of: urlString) {
            trashedCloudImageURLs.remove(at: index)
            photoController.addCloudImageURL(urlString: urlString)
            refreshID = UUID()
            photoController.saveTrashedCloudImageURLs(urls: trashedCloudImageURLs)
        }
    }

    func deleteSingleImage(image: UIImage) {
        if let index = trashedImages.firstIndex(of: image) {
            trashedImages.remove(at: index)
            refreshID = UUID()
            photoController.saveImagePaths(images: trashedImages, key: "trashedImagePaths")
        }
    }

    func deleteSingleCloudImage(urlString: String) {
        if let index = trashedCloudImageURLs.firstIndex(of: urlString) {
            trashedCloudImageURLs.remove(at: index)
            refreshID = UUID()
            photoController.saveTrashedCloudImageURLs(urls: trashedCloudImageURLs)
        }
    }

    func deleteAllImages() {
        trashedImages.removeAll()
        trashedCloudImageURLs.removeAll()
        refreshID = UUID()
        photoController.saveImagePaths(images: trashedImages, key: "trashedImagePaths")
        photoController.saveTrashedCloudImageURLs(urls: trashedCloudImageURLs)
    }

    func loadTrashedImages() {
        photoController.loadTrashedImages { images in
            trashedImages = images
            refreshID = UUID()
        }
    }

    func loadTrashedCloudImages() {
        trashedCloudImageURLs = photoController.loadTrashedCloudImageURLs()
        refreshID = UUID()
    }
}

#Preview {
    TrashView(trashedImages: .constant([]), recentImages: .constant([]), trashedCloudImageURLs: .constant([]))
}
