//
//  LibraryView.swift
//  Cabinet
//
//  Created by Eduardo Flores on 26/11/25.
//

import SwiftUI
import SwiftData

struct LibraryView: View {
	@Environment(\.modelContext) private var modelContext
	@AppStorage("accentColor") private var accent: AppColor = .indigo
	
	@Query var drawers: [Drawer]
	@Query var pairs: [Pair]
	
	@State private var viewModel = LibraryViewModel()
	
	var body: some View {
		NavigationSplitView {
			List(selection: $viewModel.selectedDestination) {
				SmartFilters()
				Drawers(
					searchText: $viewModel.searchText,
					editingDrawer: $viewModel.editingDrawer,
					drawerToDelete: $viewModel.drawerToDelete,
					filteredDrawers: filteredDrawers)
			}
			.navigationTitle("Cabinet")
#if !os(macOS)
			.navigationBarTitleDisplayMode(.inline)
			.searchable(
				text: $viewModel.searchText,
				prompt: "Search"
			)
			.navigationSplitViewColumnWidth(min: 310, ideal: 310)
#else
			.navigationSplitViewColumnWidth(min: 230, ideal: 230)
#endif
			.toolbar {
#if !os(macOS)
				ToolbarItem(placement: .topBarLeading) {
					Button("Settings", systemImage: "gearshape") {
						viewModel.showingSettings.toggle()
					}
				}
				ToolbarItem(placement: .automatic) {
					primaryAction
				}
#else
				ToolbarItem(placement: .primaryAction) {
					primaryAction
				}
#endif
			}
		} detail: {
			if let destination = viewModel.selectedDestination {
				DetailView(destination: destination)
			} else {
				ContentUnavailableView(
					"Select a drawer",
					systemImage: "archivebox",
					description: Text(
						"Choose a drawer from the sidebar to view its contents"
					)
				)
			}
		}
		.confirmationDialog(
			"Delete '\(viewModel.drawerToDelete?.name ?? "")'?",
			isPresented: Binding(
				get: { viewModel.drawerToDelete != nil },
				set: { if !$0 { viewModel.drawerToDelete = nil } }
			),
			titleVisibility: .visible
		) {
			Button("Delete", role: .destructive) {
				if let drawer = viewModel.drawerToDelete {
					modelContext.delete(drawer)
					viewModel.drawerToDelete = nil
				}
			}
			Button("Cancel", role: .cancel) {
				viewModel.drawerToDelete = nil
			}
		} message: {
			Text("This action cannot be undone.")
		}
		.sheet(isPresented: $viewModel.showingSettings) {
			SettingsView()
				.tint(accent.color)
				.presentationDetents([.medium, .large])
		}
		.sheet(isPresented: $viewModel.showingAdd) {
			NavigationStack {
				DrawerDetailView(drawer: Drawer(name: ""))
					.presentationSizing(.fitted)
			}
			.presentationDetents([.large])
			.interactiveDismissDisabled()
		}
		.sheet(item: $viewModel.editingDrawer) { drawer in
			NavigationStack {
				DrawerDetailView(drawer: drawer)
					.presentationSizing(.fitted)
			}
			.presentationDetents([.large])
			.interactiveDismissDisabled()
		}
	}
	
	var filteredDrawers: [Drawer] {
		if viewModel.searchText.isEmpty {
			return drawers
		}
		
		return drawers.filter {
			$0.name.lowercased().contains(viewModel.searchText.lowercased())
		}
	}
	
	func countForFilter(_ filter: Filter) -> Int {
		switch filter {
		case .all:
			return pairs.count
		case .favorites:
			return pairs.filter { $0.isFavorite }.count
		case .recents:
			let sevenDaysAgo = Calendar.current.date(
				byAdding: .day,
				value: -7,
				to: Date()
			)!
			return pairs.filter {
				$0.lastUsedDate != nil && $0.lastUsedDate! >= sevenDaysAgo
			}.count
			
		}
	}
	
	fileprivate var primaryAction: some View {
		Group {
			if viewModel.isEditing {
				Button("Delete", systemImage: "trash", role: .destructive) {
					viewModel.showDrawerDeleteConfirmation.toggle()
				}
				.tint(.red)
				.disabled(viewModel.selectedItems.isEmpty)
			} else {
				Button("New", systemImage: "plus") {
					viewModel.showingAdd.toggle()
				}
#if !os(macOS)
				.buttonStyle(.glassProminent)
#endif
				.tint(accent.color)
			}
		}
		.confirmationDialog(
			"Delete selected items?",
			isPresented: $viewModel.showDrawerDeleteConfirmation,
			titleVisibility: .visible
		) {
			Button("Delete", role: .destructive) {
				deleteSelected()
			}
		} message: {
			Text(
				"This action cannot be undone. Items in this drawer will not be deleted, but will no longer be categorized."
			)
		}
	}
	
	fileprivate func deleteSelected() {
		for id in viewModel.selectedItems {
			if let item = drawers.first(where: { $0.id == id }) {
				modelContext.delete(item)
			}
		}
		
		withAnimation {
			viewModel.selectedItems.removeAll()
			viewModel.isEditing = false
		}
	}
}

struct SmartFilters: View {
	var body: some View {
		Section {
			ForEach(Filter.allCases) { filter in
				NavigationLink(value: Destination.filter(filter)) {
					HStack { filter.label }
				}
				.tag(Destination.filter(filter))
			}
		}
	}
}

struct Drawers: View {
	@AppStorage("accentColor") var accent: AppColor = .indigo
	@Query var drawers: [Drawer]
	@Binding var searchText: String
	@Binding var editingDrawer: Drawer?
	@Binding var drawerToDelete: Drawer?
	var filteredDrawers: [Drawer]
	
	var body: some View {
		Section(header: Text("Drawers").fontWeight(.bold)) {
			if filteredDrawers.isEmpty {
				EmptyDrawersView(
					searching: !searchText.isEmpty,
					accentColor: accent.color
				)
			} else {
				ForEach(filteredDrawers) { drawer in
					NavigationLink(
						value: Destination.drawer(drawer)
					) {
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
					.swipeActions(
						edge: .trailing,
						allowsFullSwipe: true
					) {
						Button("Delete", systemImage: "trash") {
							drawerToDelete = drawer
						}.tint(.red)
						
						Button("Edit", systemImage: "pencil") {
							editingDrawer = drawer
						}.tint(.blue)
					}
				}
			}
		}
	}
}

#Preview {
	LibraryView().modelContainer(SampleData.shared.modelContainer)
}
