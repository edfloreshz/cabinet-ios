//
//  NavigationDestination.swift
//  Cabinet
//
//  Created by Eduardo Flores on 16/02/26.
//

enum NavigationDestination: Hashable {
	case drawer(Drawer)
	case filter(Filter)
	
	func hash(into hasher: inout Hasher) {
		switch self {
		case .drawer(let drawer):
			hasher.combine("drawer")
			hasher.combine(drawer.id)
		case .filter(let filter):
			hasher.combine("filter")
			hasher.combine(filter.rawValue)
		}
	}
	
	static func == (lhs: NavigationDestination, rhs: NavigationDestination) -> Bool {
		switch (lhs, rhs) {
		case (.drawer(let lDrawer), .drawer(let rDrawer)):
			return lDrawer.id == rDrawer.id
		case (.filter(let lFilter), .filter(let rFilter)):
			return lFilter == rFilter
		default:
			return false
		}
	}
}
