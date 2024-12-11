//
//  EditImageView.swift
//  Photo-Editor
//
//  Created by Anthony Muñiz on 11/3/24.
//

import SwiftUI

struct EditImageView: View {
    var image: UIImage
    var onSave: (Any) -> Void

    @State private var isLoading = false
    @State private var uploadStatusMessage: String?

    let photoController = PhotoController()

    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()

            if let uploadStatusMessage = uploadStatusMessage {
                Text(uploadStatusMessage)
                    .foregroundColor(.gray)
                    .padding()
            }

            Button(action: {
                uploadImage()
            }) {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                } else {
                    Text("Upload and Save Image")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
            .padding()
            .disabled(isLoading)
        }
        .navigationTitle("Edit Image")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func uploadImage() {
        isLoading = true
        uploadStatusMessage = "Uploading to Cloudinary..."

        Task {
            do {
                if let uploadedUrl = try await photoController.uploadImageToCloudinary(image: image) {
                    DispatchQueue.main.async {
                        isLoading = false
                        uploadStatusMessage = "Upload successful!"
                        onSave(uploadedUrl)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    isLoading = false
                    uploadStatusMessage = "Upload failed: \(error.localizedDescription)"
                }
            }
        }
    }
}

#Preview {
    EditImageView(
        image: UIImage(named: "placeholder") ?? UIImage(),
        onSave: { _ in
            print("Save action triggered in preview.")
        }
    )
}
