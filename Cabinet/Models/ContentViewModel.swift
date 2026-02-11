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
	var selectedDrawer: String = "All"

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

		let drawerFiltered: [Pair]
		switch selectedDrawer {
		case "All":
			drawerFiltered = searchFiltered
		case "Favorites":
			drawerFiltered = searchFiltered.filter { $0.isFavorite }
		default:
			drawerFiltered = searchFiltered.filter { pair in
				pair.drawers.contains {
					$0.name.caseInsensitiveCompare(selectedDrawer)
						== .orderedSame
				}
			}
		}

		return drawerFiltered.sorted { lhs, rhs in
			if lhs.isFavorite != rhs.isFavorite {
				return lhs.isFavorite && !rhs.isFavorite
			}
			return lhs.key.localizedCaseInsensitiveCompare(rhs.key)
				== .orderedAscending
		}
	}
}
