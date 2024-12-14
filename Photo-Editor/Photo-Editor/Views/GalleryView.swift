//
//  GalleryView.swift
//  Photo-Editor
//
//  Created by Anthony Muñiz on 10/20/24.
//

import SwiftUI

struct GalleryView: View {
    @State private var cloudImageURLs: [String] = []
    @State private var selectedImage: UIImage?
    @State private var isEditImageViewActive = false

    private let photoController = PhotoController()

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(cloudImageURLs, id: \.self) { urlString in
                        NavigationLink(
                            destination: destinationView(for: urlString)
                        ) {
                            AsyncImage(url: URL(string: urlString)) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .cornerRadius(10)
                                        .clipped()
                                case .failure:
                                    Color.gray
                                        .frame(width: 100, height: 100)
                                        .cornerRadius(10)
                                        .clipped()
                                case .empty:
                                    ProgressView()
                                        .frame(width: 100, height: 100)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Cloud Gallery")
            .onAppear {
                loadCloudImages()
            }
        }
    }

    @ViewBuilder
    func destinationView(for urlString: String) -> some View {
        ZStack {
            ProgressView()
            AsyncDestinationView(urlString: urlString)
        }
    }

    struct AsyncDestinationView: View {
        let urlString: String
        @State private var loadedImage: UIImage?
        @State private var isLoading = true

        var body: some View {
            Group {
                if let image = loadedImage {
                    EditImageView(
                        image: image,
                        onSave: { _ in },
                        isLoading: .constant(false)
                    )
                } else if isLoading {
                    ProgressView("Loading Image...")
                } else {
                    Text("Failed to load image.")
                }
            }
            .onAppear {
                loadImage(from: urlString) { image in
                    loadedImage = image
                    isLoading = false
                }
            }
        }

        func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
            guard let url = URL(string: urlString) else {
                completion(nil)
                return
            }

            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        completion(image)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }.resume()
        }
    }

    func loadCloudImages() {
        cloudImageURLs = photoController.loadCloudImageURLs()
    }
}

#Preview {
    GalleryView()
}
