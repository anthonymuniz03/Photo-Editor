//
//  SplashScreenView.swift
//  Photo-Editor
//
//  Created by Anthony Muñiz on 12/14/24.
//

import SwiftUI

struct SplashScreenView: View {
    @Binding var isSplashScreenVisible: Bool
    @Binding var cloudImageURLs: [String]
    @Binding var trashedCloudImageURLs: [String]
    private let photoController = PhotoController()

    var body: some View {
        ZStack {
            Color(red: 61 / 255, green: 168 / 255, blue: 116 / 255)
                .edgesIgnoringSafeArea(.all)

            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 513, height: 367)
                .offset(y: -40)
        }
        .onAppear {
            Task {
                await loadCloudImages()
                isSplashScreenVisible = false
            }
        }
    }

    // MARK: - Load Cloud Images

    func loadCloudImages() async {
        let cloudImages = photoController.loadCloudImageURLs(page: 1, pageSize: 50)
        let trashedCloudImages = photoController.loadTrashedCloudImageURLs()
        
        await MainActor.run {
            cloudImageURLs = cloudImages
            trashedCloudImageURLs = trashedCloudImages
        }
    }
}

#Preview {
    SplashScreenView(
        isSplashScreenVisible: .constant(true),
        cloudImageURLs: .constant([]),
        trashedCloudImageURLs: .constant([])
    )
}
