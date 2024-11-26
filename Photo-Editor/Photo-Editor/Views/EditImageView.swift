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
                uploadImageToCloudinary()
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

    private func uploadImageToCloudinary() {
        isLoading = true
        uploadStatusMessage = "Uploading to Cloudinary..."

        Task {
            do {
                if let uploadedUrl = try await uploadImage(image: image) {
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

    // MARK: - Helper Function for Cloudinary Upload
    private func uploadImage(image: UIImage) async throws -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "ImageError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create JPEG data"])
        }

        let boundary = UUID().uuidString
        let url = URL(string: "https://api.cloudinary.com/v1_1/dhmacf7uv/image/upload")!
        var request = URLRequest(url: url)

        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"upload_preset\"\r\n\r\n".data(using: .utf8)!)
        body.append("ml_default\r\n".data(using: .utf8)!)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "UploadError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid server response"])
        }

        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let urlString = json["secure_url"] as? String else {
            throw NSError(domain: "UploadError", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])
        }

        return urlString
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
