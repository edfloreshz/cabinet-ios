//
//  Filter.swift
//  Cabinet
//
//  Created by Eduardo Flores on 15/02/26.
//

import SwiftUI

enum Filter: String, CaseIterable, Identifiable {
	case all, favorites, recents
	var id: Self { self }

	var view: some View {
		switch self {
		case .all:
			Label("All", systemImage: "list.clipboard.fill")
				.tag(self)
		case .favorites:
			Label("Favorites", systemImage: "star.fill")
				.tag(self)
		case .recents:
			Label("Recents", systemImage: "calendar.badge.clock")
				.tag(self)
		}
	}

	var icon: String {
		switch self {
		case .all: return "list.clipboard.fill"
		case .favorites: return "star.fill"
		case .recents: return "calendar.badge.clock"
		}
	}

	var color: Color {
		switch self {
		case .all: return .blue
		case .favorites: return .yellow
		case .recents: return .red
		}
	}
}
