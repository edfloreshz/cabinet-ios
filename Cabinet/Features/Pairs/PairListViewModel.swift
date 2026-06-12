//
//  PairListViewModel.swift
//  Cabinet
//
//  Created by Eduardo Flores on 15/02/26.
//
import SwiftUI

@Observable
class PairListViewModel {
	var isEditing = false
	var showingAdd = false
	var showItemDeleteConfirmation = false
	var editingPair: Pair?
	var selectedItems: Set<UUID> = []
	var searchText: String = ""
	var selectedFilter: Filter = .all

	func filteredPairs(_ pairs: [Pair], destination: Destination) -> [Pair] {
		var result = pairs
		
		switch destination {
		case .drawer(let drawer):
			result = result.filter { $0.drawers.contains(drawer.id) }
			switch selectedFilter {
			case .all: break
			case .favorites:
				result = result.filter { $0.isFavorite }
			case .recents:
				let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
				result = result.filter { $0.lastUsedDate != nil && $0.lastUsedDate! >= sevenDaysAgo }
			}
		case .filter(let filter):
			switch filter {
			case .all: break
			case .favorites:
				result = result.filter { $0.isFavorite }
			case .recents:
				let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
				result = result.filter { $0.lastUsedDate != nil && $0.lastUsedDate! >= sevenDaysAgo }
			}
		}
		
		if !searchText.isEmpty {
			result = result.filter {
				$0.key.lowercased().contains(searchText.lowercased())
			}
		}
		
		return result
	}
	
	func navigationTitle(for destination: Destination) -> String {
		switch destination {
		case .drawer(let drawer): return drawer.name.capitalized
		case .filter(let filter):
			switch filter {
			case .all: return "All"
			case .favorites: return "Favorites"
			case .recents: return "Recents"
			}
		}
	}
	
	func navigationSubtitle(for destination: Destination) -> String {
		switch destination {
		case .drawer(let drawer): return drawer.purpose
		case .filter(let filter):
			switch filter {
			case .all: return "All your items"
			case .favorites: return "Your favorites"
			case .recents: return "Recently copied"
			}
		}
	}
	
	func selectedDrawers(for destination: Destination) -> [UUID] {
		switch destination {
		case .drawer(let drawer): return [drawer.id]
		case .filter: return []
		}
	}
}
