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
    private let photoController = PhotoController()

    let columns = [
        GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(0..<15, id: \.self) { index in
                        if index < trashedImages.count {
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
                                }
                        } else {
                            PlaceHolderImageView()
                                .frame(width: 100, height: 100)
                        }
                    }
                }
                .id(refreshID)
                .padding()
            }
            .navigationTitle("Trash")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadTrashedImages()
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
            print("Restored image to recentImages. Current count: \(recentImages.count)")
            print("Updated trashedImages count: \(trashedImages.count)")
        }
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
