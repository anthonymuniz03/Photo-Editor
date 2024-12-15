//
//  FilterSelectionView.swift
//  Photo-Editor
//
//  Created by Anthony Muñiz on 12/14/24.
//

import SwiftUI

struct FilterSelectionView: View {
    let currentImage: UIImage
    @Binding var selectedFilter: FilterType
    var onSelect: (FilterType) -> Void

    let filters: [(type: FilterType, label: String, color: Color)] = [
        (.original, "Original", Color.gray),
        (.cold, "Cold", Color.blue),
        (.warm, "Warm", Color.orange),
        (.red, "Red", Color.red),
        (.purple, "Purple", Color.purple)
    ]

    var body: some View {
        VStack {
            Text("Select a Filter")
                .font(.headline)
                .padding(.bottom, 10)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(filters, id: \.type) { filter in
                        filterButton(for: filter.type, label: filter.label, color: filter.color)
                    }
                }
                .padding(.horizontal, 16)
            }
            .frame(height: 120)
        }
    }

    func filterButton(for filter: FilterType, label: String, color: Color) -> some View {
        VStack {
            color
                .frame(width: selectedFilter == filter ? 80 : 70, height: selectedFilter == filter ? 80 : 70)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(selectedFilter == filter ? Color.white : Color.clear, lineWidth: 3)
                )
            Text(label)
                .font(.caption)
                .foregroundColor(.black)
        }
        .onTapGesture {
            selectedFilter = filter
            onSelect(filter)
        }
    }
}

enum FilterType {
    case original, cold, warm, red, purple
}

#Preview {
    FilterSelectionView(
        currentImage: UIImage(named: "sampleImage") ?? UIImage(),
        selectedFilter: .constant(.original),
        onSelect: { _ in }
    )
}
