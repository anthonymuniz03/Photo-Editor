//
//  MemorabiliaView.swift
//  Photo-Editor
//
//  Created by Anthony Muñiz on 10/20/24.
//

import SwiftUI

struct MemorabiliaView: View {
    var body: some View {
        VStack {
            Text("Memorabilia Gallery")
                .font(.largeTitle)
                .padding()
            Spacer()
        }
        .navigationTitle("Memorabilia")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    MemorabiliaView()
}

