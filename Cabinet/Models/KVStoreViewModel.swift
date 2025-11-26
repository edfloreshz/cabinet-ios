//
//  KVStoreViewModel.swift
//  Cabinet
//
//  Created by Eduardo Flores on 26/11/25.
//

import Foundation
import Observation

@Observable
final class KVStoreViewModel {
    var pairs: [KVPair] = [
        KVPair(key: "Username", value: "eflores", isFavorite: true),
        KVPair(key: "API Token", value: "••••••••"),
        KVPair(key: "Environment", value: "Production")
    ]

    var searchText: String = ""

    var filteredPairs: [KVPair] {
        let base = pairs
        let filtered: [KVPair]
        if searchText.isEmpty {
            filtered = base
        } else {
            let term = searchText.lowercased()
            filtered = base.filter { $0.key.lowercased().contains(term) || $0.value.lowercased().contains(term) }
        }
        // Favorites first, then by key
        return filtered.sorted { lhs, rhs in
            if lhs.isFavorite != rhs.isFavorite { return lhs.isFavorite && !rhs.isFavorite }
            return lhs.key.localizedCaseInsensitiveCompare(rhs.key) == .orderedAscending
        }
    }

    func addPair(key: String, value: String) {
        let trimmedKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedKey.isEmpty else { return }
        pairs.append(KVPair(key: trimmedKey, value: trimmedValue))
    }

    func updatePair(_ pair: KVPair, key: String, value: String) {
        guard let idx = pairs.firstIndex(where: { $0.id == pair.id }) else { return }
        pairs[idx].key = key
        pairs[idx].value = value
    }

    func delete(_ pair: KVPair) {
        pairs.removeAll { $0.id == pair.id }
    }

    func delete(at offsets: IndexSet) {
        // Note: Offsets refer to the currently displayed (filtered/sorted) list.
        // Map them back to the underlying array by id.
        let items = offsets.compactMap { index in
            filteredPairs[safe: index]
        }
        for item in items {
            delete(item)
        }
    }

    func toggleFavorite(_ pair: KVPair) {
        guard let idx = pairs.firstIndex(where: { $0.id == pair.id }) else { return }
        pairs[idx].isFavorite.toggle()
    }
}

// MARK: - Safe index helper
private extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

