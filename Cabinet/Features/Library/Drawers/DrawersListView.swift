//
//  DrawersListView.swift
//  Cabinet
//
//  Created by Eduardo Flores on 11/06/26.
//

//
//  Drawers.swift
//  Cabinet
//
//  Created by Eduardo Flores on 09/06/26.
//
import SwiftUI

struct DrawersListView: View {
	@AppStorage("accentColor") var accent: AppColor = .indigo
	
	@Binding var searchText: String
	@Binding var editingDrawer: Drawer?
	@Binding var drawerToDelete: Drawer?
	var filteredDrawers: [Drawer]
	
	var body: some View {
		Section(header: Text("Drawers").fontWeight(.bold)) {
			if filteredDrawers.isEmpty {
				emptyState
			} else {
				drawerList
			}
		}
	}
	
	// MARK: - Subviews
	
	private var emptyState: some View {
		VStack(spacing: 16) {
			Image(systemName: !searchText.isEmpty ? "magnifyingglass" : "archivebox")
				.font(.system(size: 48))
				.foregroundStyle(.secondary)
			Text(!searchText.isEmpty ? "No matches" : "No drawers yet")
				.font(.title3)
				.bold()
			Text(!searchText.isEmpty ? "Try a different search term." : "Add your first drawer.")
				.foregroundStyle(.secondary)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.multilineTextAlignment(.center)
		.padding()
	}
	
	private var drawerList: some View {
		ForEach(filteredDrawers) { drawer in
			NavigationLink(value: Destination.drawer(drawer)) {
				Label {
					Text(drawer.name)
				} icon: {
					Image(systemName: drawer.icon)
						.foregroundStyle(accent.color)
				}
			}
			.tag(Destination.drawer(drawer))
			.contextMenu {
				Button("Edit", systemImage: "pencil") {
					editingDrawer = drawer
				}
				Button("Delete", systemImage: "trash") {
					drawerToDelete = drawer
				}
			}
			.swipeActions(edge: .trailing, allowsFullSwipe: true) {
				Button("Delete", systemImage: "trash") {
					drawerToDelete = drawer
				}
				.tint(.red)
				
				Button("Edit", systemImage: "pencil") {
					editingDrawer = drawer
				}
				.tint(.blue)
			}
		}
	}
}
