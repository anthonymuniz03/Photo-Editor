//
//  EditImageView.swift
//  Photo-Editor
//
//  Created by Anthony Muñiz on 11/3/24.
//

import SwiftUI


struct EditImageView: View {
    var image: UIImage
    
    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
        }
        .navigationTitle("Edit Image")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    EditImageView(image: UIImage(named: "placeholder") ?? UIImage())
}
