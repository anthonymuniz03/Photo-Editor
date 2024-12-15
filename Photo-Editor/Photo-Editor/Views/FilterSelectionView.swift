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

    var body: some View {
        VStack {
            Text("Select a Filter")
                .font(.headline)
                .padding()

            HStack(spacing: 20) {
                filterButton(for: .original, label: "Original", color: Color.gray)
                filterButton(for: .cold, label: "Cold", color: Color.blue)
                filterButton(for: .warm, label: "Warm", color: Color.orange)
            }
            .padding()
        }
    }

    func filterButton(for filter: FilterType, label: String, color: Color) -> some View {
        VStack {
            color
                .frame(width: selectedFilter == filter ? 100 : 80, height: selectedFilter == filter ? 100 : 80)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(selectedFilter == filter ? Color.white : Color.clear, lineWidth: 3)
                )
            Text(label)
                .font(.caption)
                .foregroundColor(.white)
        }
        .onTapGesture {
            selectedFilter = filter
            onSelect(filter)
        }
    }
}

struct FilterPreview: View {
    let image: UIImage
    let label: String
    let applyFilter: (UIImage) -> UIImage

    var body: some View {
        VStack {
            Image(uiImage: applyFilter(image))
                .resizable()
                .frame(width: 80, height: 80)
                .cornerRadius(8)
            Text(label)
        }
    }
}

enum FilterType {
    case original, cold, warm
}
