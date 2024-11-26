//
//  MainButton.swift
//  Photo-Editor
//
//  Created by Anthony Muñiz on 10/10/24.
//

import SwiftUI

struct MainButton: View {
    @Binding var recentImages: [UIImage]
    @State private var isPickerPresented = false
    @State private var selectedImage: UIImage?
    @State private var isEditImageViewActive = false

    var body: some View {
        NavigationStack {
            VStack {
                Button(action: {
                    isPickerPresented = true
                    print("Picker presented")
                }, label: {
                    Image(systemName: "plus.circle")
                        .resizable()
                        .frame(width: 70, height: 70)
                        .foregroundStyle(Color.gray)
                        .padding(120)
                })
                .buttonStyle(.bordered)
                .accessibilityLabel("selectLibraryImage")
                .sheet(isPresented: $isPickerPresented) {
                    PhotoPicker(selectedImage: $selectedImage)
                }

                NavigationLink(
                    destination: EditImageView(
                        image: selectedImage ?? UIImage(),
                        onSave: { savedImageOrUrl in
                            print("onSave closure called in NavigationLink.")

                            Task {
                                if let savedImage = savedImageOrUrl as? UIImage {
                                    print("UIImage received, starting Task to save...")
                                    await saveImageAndAddToLibrary(image: savedImage)
                                    print("Finished Task to save image.")
                                } else if let imageUrlString = savedImageOrUrl as? String {
                                    print("Cloudinary URL received: \(imageUrlString)")
                                    if let downloadedImage = await downloadImage(from: imageUrlString) {
                                        await saveImageAndAddToLibrary(image: downloadedImage)
                                        print("Image downloaded and saved to photo library.")
                                    } else {
                                        print("Failed to download image from Cloudinary URL.")
                                    }
                                } else {
                                    print("Unknown type received from onSave closure.")
                                }
                            }
                        }
                    ),
                    isActive: $isEditImageViewActive
                ) {
                    EmptyView()
                }
                .hidden()

                .hidden()

                .onChange(of: selectedImage) { newImage in
                    if let newImage = newImage {
                        print("New image selected")
                        isEditImageViewActive = true
                    } else {
                        print("No image selected")
                    }
                }
            }
        }
    }

    func downloadImage(from urlString: String) async -> UIImage? {
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return nil
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            print("Failed to download image: \(error.localizedDescription)")
            return nil
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
                print("Image saved and added to recentImages.")
                print("Current recentImages count: \(recentImages.count)")
                saveRecentImagePaths()
            }
        } catch {
            print("Failed to save image: \(error.localizedDescription)")
        }
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
                        print("Image written to: \(fileURL.path)")
                        continuation.resume(returning: fileURL)
                    } else {
                        print("Failed to generate JPEG data.")
                        throw NSError(domain: "ImageError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create image data"])
                    }
                } catch {
                    print("Error during saveImageToDevice: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func saveRecentImagePaths() {
        let imagePaths = recentImages.compactMap { image -> String? in
            let fileManager = FileManager.default
            let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileName = UUID().uuidString + ".jpg"
            let fileURL = documents.appendingPathComponent(fileName)

            if let data = image.jpegData(compressionQuality: 0.8) {
                do {
                    try data.write(to: fileURL)
                    return fileURL.path
                } catch {
                    print("Error saving image to file: \(error.localizedDescription)")
                    return nil
                }
            }
            return nil
        }

        print("Saving recent image paths to UserDefaults: \(imagePaths)")
        UserDefaults.standard.set(imagePaths, forKey: "recentImagePaths")
    }
}


#Preview {
    MainButton(recentImages: .constant([]))
}
