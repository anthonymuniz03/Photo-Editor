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
    @State private var refreshID = UUID()
    @State private var showDeleteAllAlert = false
    @State private var showDeleteSingleAlert = false
    @State private var imageToDelete: UIImage?

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
                        }
                        .id(refreshID)
                        .padding(.top, 20)
                    }
                }
            }
            .toolbarBackground(.hidden)
            .onAppear {
                loadTrashedImages()
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
                    }
                }
            } message: {
                Text("Are you sure you want to permanently delete this image?")
            }
        }
    }

    // MARK: - Functions

    func restoreImage(image: UIImage) {
        if let index = trashedImages.firstIndex(of: image) {
            trashedImages.remove(at: index)
            recentImages.append(image)
            refreshID = UUID()
            photoController.saveImagePaths(images: recentImages, key: "recentImagePaths")
            photoController.saveImagePaths(images: trashedImages, key: "trashedImagePaths")
            print("Restored image to recentImages. Current count: \(recentImages.count)")
            print("Updated trashedImages count: \(trashedImages.count)")
        }
    }

    func deleteSingleImage(image: UIImage) {
        if let index = trashedImages.firstIndex(of: image) {
            trashedImages.remove(at: index)
            refreshID = UUID()
            photoController.saveImagePaths(images: trashedImages, key: "trashedImagePaths")
            print("Deleted image from trash. Current trash count: \(trashedImages.count)")
        }
    }

    func deleteAllImages() {
        trashedImages.removeAll()
        refreshID = UUID()
        photoController.saveImagePaths(images: trashedImages, key: "trashedImagePaths")
        print("Emptied the trash. Current trash count: \(trashedImages.count)")
    }

    func loadTrashedImages() {
        photoController.loadTrashedImages { images in
            trashedImages = images
            refreshID = UUID()
        }
    }
}

#Preview {
    TrashView(trashedImages: .constant([]), recentImages: .constant([]))
}
