//
//  LibraryViewModel.swift
//  Cabinet
//
//  Created by Eduardo Flores on 09/06/26.
//

import SwiftUI

@Observable
class LibraryViewModel {
	var isEditing = false
	var showingAdd = false
	var showingSettings = false
	var showDrawerDeleteConfirmation = false
	var editingDrawer: Drawer?
	var drawerToDelete: Drawer?
	var selectedItems: Set<UUID> = []
	var searchText: String = ""
	var selectedDestination: Destination? = .filter(.all)

	func filteredDrawers(_ drawers: [Drawer]) -> [Drawer] {
		guard !searchText.isEmpty else { return drawers }
		return drawers.filter {
			$0.name.lowercased().contains(searchText.lowercased())
		}
	}

	func countForFilter(_ filter: Filter, pairs: [Pair]) -> Int {
		switch filter {
		case .all:
			return pairs.count
		case .favorites:
			return pairs.filter { $0.isFavorite }.count
		case .recents:
			let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
			return pairs.filter {
				$0.lastUsedDate != nil && $0.lastUsedDate! >= sevenDaysAgo
			}.count
		}
	}
}
