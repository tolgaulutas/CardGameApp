//
//  Tile.swift
//  CardGameApp
//
//  Created by Tolga Ulutaş on 3.01.2026.
//

import Foundation
import Combine

struct Tile: Identifiable, Equatable {
    let id = UUID()
    let imageName: String
    var isFlipped: Bool = false
}
