//
//  KVPair.swift
//  Cabinet
//
//  Created by Eduardo Flores on 26/11/25.
//

import Foundation
import SwiftData

@Model
final class Pair {
    @Attribute(.unique) var id: UUID
    var key: String
    var value: String
    var isFavorite: Bool
    var isHidden: Bool

    init(id: UUID = UUID(), key: String, value: String, isFavorite: Bool = false, isHidden: Bool = false) {
        self.id = id
        self.key = key
        self.value = value
        self.isFavorite = isFavorite
        self.isHidden = isHidden
    }
    
    static let sampleData = [
        Pair(key: "RFC", value: "DHRF990011Y3D", isFavorite: true),
        Pair(key: "Email", value: "eduardo@gmail.com"),
        Pair(key: "Bank Account", value: "12390520234", isHidden: true)
    ]
}
