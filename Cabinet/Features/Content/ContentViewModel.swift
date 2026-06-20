//
//  ContentViewModel.swift
//  Cabinet
//
//  Created by Eduardo Flores on 15/02/26.
//
import SwiftUI

@Observable
@MainActor
final class ContentViewModel {
	var isEditing = false
	var showingAdd = false
	var showItemDeleteConfirmation = false
	var editingPair: Pair?
	var selectedItems: Set<UUID> = []
	var searchText: String = ""
	var selectedFilter: Filter = .all
	var currentLayout: LayoutType = .list
	var showLayoutOptions: Bool = false
	
	func filteredPairs(_ pairs: [Pair], destination: Destination?) -> [Pair] {
		var result = pairs
		
		if let destination = destination {
			switch destination {
			case .drawer(let drawer):
				result = result.filter { pair in
					pair.drawers.contains(where: { $0.id == drawer.id })
				}
				result = apply(selectedFilter, to: result)
			case .filter(let filter):
				result = apply(filter, to: result)
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
	
	func selectedDrawers(for destination: Destination?) -> [Drawer] {
		if let destination = destination {
			switch destination {
			case .drawer(let drawer): return [drawer]
			case .filter: return []
			}
		} else {
			return []
		}
	}

	private func apply(_ filter: Filter, to pairs: [Pair]) -> [Pair] {
		switch filter {
		case .all:
			return pairs
		case .favorites:
			return pairs.filter(\.isFavorite)
		case .recents:
			return pairs.filter(isRecent)
		}
	}

	private func isRecent(_ pair: Pair) -> Bool {
		guard
			let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()),
			let lastUsedDate = pair.lastUsedDate
		else {
			return false
		}

		return lastUsedDate >= sevenDaysAgo
	}
}
