//
//  PhotoController.swift
//  Photo-Editor
//
//  Created by Anthony Muñiz on 12/8/24.
//

import UIKit

class PhotoController {
    
    // MARK: - Save Image to Device
    func saveImageToDevice(image: UIImage) async throws -> URL {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .background).async {
                do {
                    let fileManager = FileManager.default
                    let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let fileName = UUID().uuidString + ".jpg"
                    let fileURL = documents.appendingPathComponent(fileName)
                    print("Documents directory: \(documents.path)")

                    // Ensure the image is compressed and converted to a standard JPEG
                    guard let data = image.jpegData(compressionQuality: 0.8) else {
                        throw NSError(domain: "ImageError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create JPEG data"])
                    }

                    try data.write(to: fileURL)
                    continuation.resume(returning: fileURL)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }



    // MARK: - Download Image from URL
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
    
    func saveImagePaths(images: [UIImage], key: String) {
        let fileManager = FileManager.default
        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let imagePaths = images.compactMap { image in
            let fileName = UUID().uuidString + ".jpg"
            let fileURL = documents.appendingPathComponent(fileName)

            if let data = image.jpegData(compressionQuality: 0.8) {
                do {
                    try data.write(to: fileURL)
                    return fileURL.path
                } catch {
                    print("Failed to write image data: \(error.localizedDescription)")
                }
            }
            return nil
        }

        UserDefaults.standard.set(imagePaths, forKey: key)
        print("Saved image paths for \(key): \(imagePaths)")
    }

    // MARK: - Load Images
    func loadImages(forKey key: String, completion: @escaping ([UIImage]) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let imagePaths = UserDefaults.standard.stringArray(forKey: key) ?? []
            let images = imagePaths.compactMap { path in
                let url = URL(fileURLWithPath: path)
                return UIImage(contentsOfFile: url.path)
            }
            DispatchQueue.main.async {
                completion(images)
            }
        }
    }

    // MARK: - Load Trashed Images
    func loadTrashedImages(completion: @escaping ([UIImage]) -> Void) {
        loadImages(forKey: "trashedImagePaths", completion: completion)
    }

    func convertToStandardFormat(image: UIImage) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: image.size)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: image.size))
        }
    }

    // MARK: - Upload Image to Cloudinary
    func uploadImageToCloudinary(image: UIImage, completion: @escaping (String?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
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

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to upload image: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let urlString = json["secure_url"] as? String else {
                print("Failed to parse upload response")
                completion(nil)
                return
            }

            // Save the URL to UserDefaults
            var savedURLs = UserDefaults.standard.stringArray(forKey: "cloudImageURLs") ?? []
            savedURLs.insert(urlString, at: 0)
            UserDefaults.standard.set(savedURLs, forKey: "cloudImageURLs")

            completion(urlString)
        }.resume()
    }



    // MARK: - Save Cloud Image URLs
    func saveCloudImageURLs(urls: [String]) {
        UserDefaults.standard.set(urls, forKey: "cloudImageURLs")
    }
    
    func resetCloudImageURLs() {
        UserDefaults.standard.removeObject(forKey: "cloudImageURLs")
        print("Cloud image URLs reset.")
    }

    // MARK: - Load Cloud Image URLs with Pagination
    func loadCloudImageURLs(page: Int, pageSize: Int) -> [String] {
        let allImageURLs = UserDefaults.standard.stringArray(forKey: "cloudImageURLs") ?? []
        let startIndex = (page - 1) * pageSize
        let endIndex = min(startIndex + pageSize, allImageURLs.count)

        return startIndex < endIndex ? Array(allImageURLs[startIndex..<endIndex]) : []
    }

}

// MARK: - UIImage Extension for Resizing

extension UIImage {
    func resized(to targetSize: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}

