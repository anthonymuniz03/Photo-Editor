//
//  EditImageView.swift
//  Photo-Editor
//
//  Created by Anthony Muñiz on 11/3/24.
//

import SwiftUI


struct EditImageView: View {
    var image: UIImage
    var onSave: (UIImage) -> Void
    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()

            Button(action: {
                print("Save button tapped.")

                onSave(image)
            }) {
                Text("Save Image")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding()
        }
        .navigationTitle("Edit Image")
        .navigationBarTitleDisplayMode(.inline)
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
