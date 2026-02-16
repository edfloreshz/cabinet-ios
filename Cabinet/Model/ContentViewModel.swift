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
	var selectedFilter: Filter = .all

	func filteredPairs(_ pairs: [Pair], destination: NavigationDestination) -> [Pair] {
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

		let destinationFiltered: [Pair]

		switch destination {
		case .drawer(let drawer):
			destinationFiltered = searchFiltered.filter { pair in
				pair.drawers.contains(drawer.id)
			}
		case .filter(let filter):
			selectedFilter = filter
			
			let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!

			switch selectedFilter {
			case .all:
				destinationFiltered = searchFiltered
			case .favorites:
				destinationFiltered = searchFiltered.filter { $0.isFavorite }
			case .recents:
				destinationFiltered = searchFiltered.filter { $0.lastUsedDate != nil && $0.lastUsedDate! >= sevenDaysAgo }
			}
		}

		return destinationFiltered.sorted { lhs, rhs in
			if lhs.isFavorite != rhs.isFavorite {
				return lhs.isFavorite && !rhs.isFavorite
			}
			return lhs.key.localizedCaseInsensitiveCompare(rhs.key)
				== .orderedAscending
		}
	}
}
