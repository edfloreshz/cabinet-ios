//
//  ContentView.swift
//  Cabinet
//
//  Created by Eduardo Flores on 26/11/25.
//

internal import CoreData
import LocalAuthentication
import SwiftData
import SwiftUI

struct ContentView: View {
	@Environment(\.modelContext) private var modelContext
	@AppStorage("accentColor") private var accent: ThemeColor = .indigo

	@Query private var drawers: [Drawer]
	@Query private var pairs: [Pair]

	@State private var showingSettings: Bool = false
	@State private var showDrawerDeleteConfirmation = false
	@State private var isEditing = false
	@State private var showingAdd = false
	@State private var editingDrawer: Drawer? = nil
	@State private var drawerToDelete: Drawer? = nil
	@State private var selectedItems: Set<UUID> = []
	@State private var searchText: String = ""
	@State private var selectedDestination: NavigationDestination?

	@State private var allCount = 0
	@State private var favoritesCount = 0
	@State private var recentCount = 0

	let columns = [
		GridItem(.flexible(), spacing: 16),
		GridItem(.flexible(), spacing: 16),
	]

	var filteredDrawers: [Drawer] {
		if searchText.isEmpty {
			return drawers
		} else {
			return drawers.filter {
				$0.name.lowercased().contains(searchText.lowercased())
			}
		}
	}

	var body: some View {
		NavigationSplitView {
			VStack(spacing: 0) {
				List(selection: $selectedDestination) {
					Section {
						ForEach(Filter.allCases) { filter in
							NavigationLink(
								value: NavigationDestination.filter(filter)
							) {
								HStack {
									filter.label
									Spacer()
									Text(countForFilter(filter).formatted())
										.foregroundStyle(.secondary)
										.font(.subheadline)
								}
							}
							.tag(NavigationDestination.filter(filter))
						}
					}
					Section(
						header: Text("Drawers").font(.title3).fontWeight(.bold)
					) {
						if filteredDrawers.isEmpty {
							EmptyDrawersView(
								searching: !searchText.isEmpty,
								accentColor: accent.color
							)
						} else {
							ForEach(filteredDrawers) { drawer in
								NavigationLink(
									value: NavigationDestination.drawer(drawer)
								) {
									Label {
										Text(drawer.name)
									} icon: {
										Image(systemName: drawer.icon)
											.foregroundStyle(accent.color)
									}
								}
								.tag(NavigationDestination.drawer(drawer))
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
			.navigationTitle("Cabinet")
			#if os(iOS) || os(iPadOS) || os(visionOS)
				.navigationBarTitleDisplayMode(.inline)
				.searchable(
					text: $searchText,
					prompt: "Search"
				)
			#endif
			.toolbar {
				#if os(iOS) || os(iPadOS) || os(visionOS)
					ToolbarItem(placement: .topBarLeading) {
						Button("Settings", systemImage: "gearshape") {
							showingSettings.toggle()
						}
					}
					DefaultToolbarItem(kind: .search, placement: .bottomBar)
					ToolbarSpacer(placement: .bottomBar)
					ToolbarItem(placement: .automatic) {
						primaryAction
					}
				#else
					ToolbarItem(placement: .automatic) {
						Button("Settings", systemImage: "gearshape") {
							showingSettings.toggle()
						}
					}
					ToolbarItem(placement: .automatic) {
						primaryAction
					}
				#endif

			}
		} detail: {
			if let destination = selectedDestination {
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
			"Delete '\(drawerToDelete?.name ?? "")'?",
			isPresented: Binding(
				get: { drawerToDelete != nil },
				set: { if !$0 { drawerToDelete = nil } }
			),
			titleVisibility: .visible
		) {
			Button("Delete", role: .destructive) {
				if let drawer = drawerToDelete {
					modelContext.delete(drawer)
					drawerToDelete = nil
				}
			}
			Button("Cancel", role: .cancel) {
				drawerToDelete = nil
			}
		} message: {
			Text("This action cannot be undone.")
		}
		.sheet(isPresented: $showingSettings) {
			NavigationStack {
				SettingsView()
			}
			.tint(accent.color)
			.presentationDetents([.medium, .large])
		}
		.sheet(isPresented: $showingAdd) {
			NavigationStack {
				DrawerView(
					drawer: Drawer(name: ""),
				)
			}
			.presentationDetents([.large])
			.interactiveDismissDisabled()
		}
		.sheet(item: $editingDrawer) { drawer in
			NavigationStack {
				DrawerView(drawer: drawer)
			}
			.tint(accent.color)
			.interactiveDismissDisabled()
			.presentationDetents([.large])
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
			if isEditing {
				Button("Delete", systemImage: "trash", role: .destructive) {
					showDrawerDeleteConfirmation.toggle()
				}
				.tint(.red)
				.disabled(selectedItems.isEmpty)
			} else {
				Button("New", systemImage: "plus") {
					showingAdd.toggle()
				}
				#if os(iOS) || os(iPadOS) || os(visionOS)
					.buttonStyle(.glassProminent)
				#endif
				.tint(accent.color)
			}
		}
		.confirmationDialog(
			"Delete selected items?",
			isPresented: $showDrawerDeleteConfirmation,
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
		for id in selectedItems {
			if let item = drawers.first(where: { $0.id == id }) {
				modelContext.delete(item)
			}
		}

		withAnimation {
			selectedItems.removeAll()
			isEditing = false
		}
	}
}

#Preview {
	ContentView().modelContainer(SampleData.shared.modelContainer)
}
