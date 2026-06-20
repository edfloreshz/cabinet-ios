//
//  SidebarViewModel.swift
//  Cabinet
//
//  Created by Eduardo Flores on 09/06/26.
//

import SwiftUI

@Observable
@MainActor
final class SidebarViewModel {
	var isEditing = false
	var showingAdd = false
	var showingSettings = false
	var showDrawerDeleteConfirmation = false
	var selectedItems: Set<UUID> = []
	var searchText: String = ""

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
			guard let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) else {
				return 0
			}

			return pairs.filter {
				guard let lastUsedDate = $0.lastUsedDate else { return false }
				return lastUsedDate >= sevenDaysAgo
			}.count
		}
	}
}
