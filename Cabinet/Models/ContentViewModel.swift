//
//  ContentViewModel.swift
//  Cabinet
//
//  Created by Eduardo Flores on 11/02/26.
//

import Foundation
import Observation
import SwiftData

@Observable
class ContentViewModel {
	var searchText: String = ""
	var selectedCategory: String = "All"

	// This logic is moved from the ContentView to here
	func filteredPairs(_ pairs: [Pair]) -> [Pair] {
		let base = pairs
		let searchFiltered: [Pair]

		if searchText.isEmpty {
			searchFiltered = base
		} else {
			let term = searchText.lowercased()
			searchFiltered = base.filter {
				$0.key.lowercased().contains(term)
					|| $0.value.lowercased().contains(term)
					|| $0.notes.lowercased().contains(term)
			}
		}

		let categoryFiltered: [Pair]
		switch selectedCategory {
		case "All":
			categoryFiltered = searchFiltered
		case "Favorites":
			categoryFiltered = searchFiltered.filter { $0.isFavorite }
		default:
			categoryFiltered = searchFiltered.filter { pair in
				pair.categories.contains {
					$0.name.caseInsensitiveCompare(selectedCategory)
						== .orderedSame
				}
			}
		}

		return categoryFiltered.sorted { lhs, rhs in
			if lhs.isFavorite != rhs.isFavorite {
				return lhs.isFavorite && !rhs.isFavorite
			}
			return lhs.key.localizedCaseInsensitiveCompare(rhs.key)
				== .orderedAscending
		}
	}
}
