//
//  EmptyView.swift
//  Cabinet
//
//  Created by Eduardo Flores on 26/11/25.
//

import SwiftUI

struct EmptyDrawersView: View {
	var searching: Bool
	var accentColor: Color

	var body: some View {
		VStack(spacing: 16) {
			Image(systemName: searching ? "magnifyingglass" : "archivebox")
				.font(.system(size: 48))
				.foregroundStyle(.secondary)
			Text(searching ? "No matches" : "No drawers yet")
				.font(.title3)
				.bold()
			Text(
				searching
					? "Try a different search term." : "Add your first drawer."
			)
			.foregroundStyle(.secondary)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.multilineTextAlignment(.center)
		.padding()
	}
}

#Preview {
	EmptyItemsView(searching: false, accentColor: .indigo)
}
