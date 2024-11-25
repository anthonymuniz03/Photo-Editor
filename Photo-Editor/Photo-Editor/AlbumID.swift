//
//  AlbumID.swift
//  Photo-Editor
//
//  Created by Anthony Muñiz on 11/4/24.
//

import SwiftUI

struct AlbumID: Identifiable {
    let id = UUID()
    let name: String
    var images: [UIImage]
}
