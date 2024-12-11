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
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
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
                    uploadImageToCloudinary()
                }) {
                    Text("Upload and Save Image")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding()
                .disabled(isLoading)
            }
            .blur(radius: isLoading ? 3 : 0)

            if isLoading {
                LoadingScreenView()
            }
        }
        .navigationTitle("Edit Image")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(isLoading)
    }

    // MARK: - Upload Image to Cloudinary
    private func uploadImageToCloudinary() {
        isLoading = true
        uploadStatusMessage = "Uploading to Cloudinary..."

        Task {
            do {
                if let uploadedUrl = try await PhotoController().uploadImageToCloudinary(image: image) {
                    DispatchQueue.main.async {
                        uploadStatusMessage = "Upload successful!"
                    }
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                    DispatchQueue.main.async {
                        isLoading = false
                        onSave(uploadedUrl)
                        dismiss()
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
        image: UIImage(named: "logo") ?? UIImage(),
        onSave: { _ in
            print("Save action triggered in preview.")
        }
    )
}
