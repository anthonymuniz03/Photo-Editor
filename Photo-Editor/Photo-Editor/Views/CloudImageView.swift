//
//  CloudImageView.swift
//  Photo-Editor
//
//  Created by Anthony Muñiz on 12/15/24.
//

import SwiftUI

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

    func generateThumbnail(from image: UIImage, targetSize: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
