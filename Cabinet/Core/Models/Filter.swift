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

	var label: some View {
		switch self {
		case .all:
			Label {
				Text("All")
			} icon: {
				Image(systemName: self.icon)
					#if os(iOS) || os(iPadOS) || os(visionOS)
						.foregroundStyle(self.color)
					#endif
			}.tag(self)
		case .favorites:
			Label {
				Text("Favorites")
			} icon: {
				Image(systemName: self.icon)
					#if os(iOS) || os(iPadOS) || os(visionOS)
						.foregroundStyle(self.color)
					#endif
			}.tag(self)
		case .recents:
			Label {
				Text("Recents")
			} icon: {
				Image(systemName: self.icon)
					#if os(iOS) || os(iPadOS) || os(visionOS)
						.foregroundStyle(self.color)
					#endif
			}.tag(self)
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
