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
                        }
                    }
                }
                .id(refreshID)
                .padding()
            }
            .navigationTitle("Trash")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    func restoreImage(image: UIImage) {
        if let index = trashedImages.firstIndex(of: image) {
            trashedImages.remove(at: index)
            recentImages.append(image)
            saveTrashedImagePaths()
            saveRecentImagePaths()
            refreshID = UUID()
            print("Restored image to recentImages. Current count: \(recentImages.count)")
            print("Updated trashedImages count: \(trashedImages.count)")
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
}


#Preview {
    TrashView(trashedImages: .constant([]), recentImages: .constant([]))
}
