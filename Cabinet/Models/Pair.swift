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

    init(id: UUID = UUID(), key: String, value: String, isFavorite: Bool = false) {
        self.id = id
        self.key = key
        self.value = value
        self.isFavorite = isFavorite
    }
}
