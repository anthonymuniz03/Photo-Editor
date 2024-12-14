//
//  GalleryView.swift
//  Photo-Editor
//
//  Created by Anthony Muñiz on 10/20/24.
//

import SwiftUI

struct GalleryView: View {
    @State private var cloudImageURLs: [String] = []
    @State private var currentPage = 1
    @State private var isLoading = false
    @State private var hasMorePages = true

    private let pageSize = 12
    private let photoController = PhotoController()

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(cloudImageURLs, id: \.self) { urlString in
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

                    if isLoading {
                        ProgressView("Loading more images...")
                            .padding()
                    }
                }
                .padding()
                .onAppear {
                    loadCloudImages()
                }
                .onScrollToEnd {
                    loadMoreImages()
                }
            }
            .navigationTitle("Cloud Gallery")
        }
    }

    func loadCloudImages() {
        guard !isLoading && hasMorePages else { return }
        isLoading = true

        DispatchQueue.global(qos: .background).async {
            let newImageURLs = photoController.loadCloudImageURLs(page: currentPage, pageSize: pageSize)
            DispatchQueue.main.async {
                if newImageURLs.isEmpty {
                    hasMorePages = false
                } else {
                    cloudImageURLs.append(contentsOf: newImageURLs)
                    currentPage += 1
                }
                isLoading = false
            }
        }
    }

    func loadMoreImages() {
        loadCloudImages()
    }
}

extension View {
    func onScrollToEnd(perform action: @escaping () -> Void) -> some View {
        GeometryReader { geometry in
            VStack {
                self
                Spacer(minLength: 0).onAppear {
                    let contentHeight = geometry.size.height
                    let screenHeight = UIScreen.main.bounds.height
                    if contentHeight <= screenHeight {
                        action()
                    }
                }
            }
        }
    }
}

#Preview {
    GalleryView()
}
