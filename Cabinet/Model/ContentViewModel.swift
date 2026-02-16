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
	var selectedFilter: String = "All"

	func filteredPairs(_ pairs: [Pair], drawer: Drawer) -> [Pair] {
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

		let filterFiltered: [Pair]
		switch selectedFilter {
		case "All":
			filterFiltered = searchFiltered
		case "Favorites":
			filterFiltered = searchFiltered.filter { $0.isFavorite }
		default:
			filterFiltered = searchFiltered
		}

		let drawerFiltered: [Pair]
		
		let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
		switch drawer.name {
		case "All":
			drawerFiltered = filterFiltered
		case "Recents":
			drawerFiltered = filterFiltered.filter { $0.lastUsedDate != nil && $0.lastUsedDate! >= sevenDaysAgo }
		default:
			drawerFiltered = filterFiltered.filter { pair in
				pair.drawers.contains(drawer.id)
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
