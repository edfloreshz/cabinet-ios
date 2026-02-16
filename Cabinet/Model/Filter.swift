//
//  Filter.swift
//  Cabinet
//
//  Created by Eduardo Flores on 15/02/26.
//

import SwiftUI

enum Filter: String, CaseIterable, Identifiable {
	case all, favorites
	var id: Self { self }
	
	var view: some View {
		switch self {
		case .all:
			Label("All", systemImage: "list.clipboard.fill")
				.tag(self)
		case .favorites:
			Label("Favorites", systemImage: "star.fill")
				.tag(self)
		}
	}
}
