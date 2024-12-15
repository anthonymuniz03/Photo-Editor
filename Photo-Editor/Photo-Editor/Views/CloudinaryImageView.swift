//
//  CloudinaryImageView.swift
//  Photo-Editor
//
//  Created by Anthony Muñiz on 12/15/24.
//

import SwiftUI
import Photos

struct CloudinaryImageView: View {
    @State private var imageUrls: [String] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showSaveConfirmation = false
    @State private var saveErrorMessage: String?

    private let cloudName = "dhmacf7uv"
    private let apiKey = "815842555732666"
    private let apiSecret = "xJ-94IdYGL99MxOSSzPnkBH7Ywo"
    private let pageSize = 20

    var body: some View {
        NavigationStack {
            ZStack {
                Image("background")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack {
                    headerView

                    if isLoading {
                        ProgressView("Loading Images...")
                            .progressViewStyle(.circular)
                            .padding()
                    } else if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                    } else if imageUrls.isEmpty {
                        Text("No images found.")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.7))
                            .padding()
                    } else {
                        galleryGridView
                    }
                }
            }
            .alert("Image Saved", isPresented: $showSaveConfirmation) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("The image has been saved to your Photo Library.")
            }
            .alert("Save Error", isPresented: Binding<Bool>(
                get: { saveErrorMessage != nil },
                set: { _ in saveErrorMessage = nil }
            )) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(saveErrorMessage ?? "Failed to save the image.")
            }
            .onAppear {
                fetchImageUrls()
            }
        }
    }

    private var headerView: some View {
        HStack {
            Text("Cloudinary Images")
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

            Button(action: refreshImages) {
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

    private var galleryGridView: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(imageUrls, id: \.self) { urlString in
                    AsyncImage(url: URL(string: urlString)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipped()
                                .cornerRadius(8)
                                .contextMenu {
                                    Button {
                                        saveImageToLibrary(from: urlString)
                                    } label: {
                                        Label("Save to Device", systemImage: "arrow.down.to.line")
                                    }
                                }
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
            }
            .padding()
        }
        .refreshable {
            refreshImages()
        }
    }

    func saveImageToLibrary(from urlString: String) {
        guard let url = URL(string: urlString) else {
            saveErrorMessage = "Invalid image URL."
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                DispatchQueue.main.async {
                    saveErrorMessage = "Download error: \(error.localizedDescription)"
                }
                return
            }

            guard let data = data, let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    saveErrorMessage = "Failed to load image data."
                }
                return
            }

            let imageSaver = ImageSaver()
            imageSaver.onSuccess = {
                DispatchQueue.main.async {
                    showSaveConfirmation = true
                }
            }
            imageSaver.onError = { error in
                DispatchQueue.main.async {
                    saveErrorMessage = "Save error: \(error.localizedDescription)"
                }
            }
            imageSaver.saveImage(image)
        }.resume()
    }



    private func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        DispatchQueue.main.async {
            if let error = error {
                saveErrorMessage = "Save error: \(error.localizedDescription)"
            } else {
                showSaveConfirmation = true
            }
        }
    }

    func fetchImageUrls() {
        isLoading = true
        errorMessage = nil

        let urlString = "https://api.cloudinary.com/v1_1/\(cloudName)/resources/image?max_results=\(pageSize)"
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL."
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        let credentials = "\(apiKey):\(apiSecret)"
        guard let encodedCredentials = credentials.data(using: .utf8)?.base64EncodedString() else {
            errorMessage = "Failed to encode credentials."
            isLoading = false
            return
        }

        request.setValue("Basic \(encodedCredentials)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    errorMessage = "Error fetching images: \(error.localizedDescription)"
                    return
                }

                guard let data = data else {
                    errorMessage = "No data received."
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let resources = json["resources"] as? [[String: Any]] {
                        imageUrls = resources.compactMap { resource in
                            resource["secure_url"] as? String
                        }
                    } else {
                        errorMessage = "Invalid JSON format."
                    }
                } catch {
                    errorMessage = "Failed to parse JSON: \(error.localizedDescription)"
                }
            }
        }.resume()
    }

    func refreshImages() {
        imageUrls.removeAll()
        fetchImageUrls()
    }
}

#Preview {
    CloudinaryImageView()
}
