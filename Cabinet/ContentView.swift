//
//  ContentView.swift
//  Cabinet
//
//  Created by Eduardo Flores on 26/11/25.
//

import LocalAuthentication
import SwiftData
import SwiftUI
internal import CoreData

struct ContentView: View {
	@Environment(\.modelContext) private var modelContext
	@AppStorage("accentColor") private var accent: ThemeColor = .indigo

	@Query private var drawers: [Drawer]
	
	@State private var showingSettings: Bool = false
	@State private var showDrawerDeleteConfirmation = false
	@State private var isEditing = false
	@State private var showingAdd = false
	@State private var editingDrawer: Drawer? = nil
	@State private var drawerToDelete: Drawer? = nil
	@State private var selectedItems: Set<UUID> = []
	@State private var searchText: String = ""
	
	@State private var allCount = 0
	@State private var recentCount = 0
	
	var categories: [Category] {
		[
			Category(title: "All", icon: "list.clipboard.fill", color: .blue, count: allCount),
			Category(title: "Recents", icon: "calendar.badge.clock", color: .red, count: recentCount),
		]
	}
	
	let columns = [
		GridItem(.flexible(), spacing: 16),
		GridItem(.flexible(), spacing: 16)
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
		NavigationStack {
			LazyVGrid(columns: columns, spacing: 16) {
				ForEach(Filter.allCases) { filter in
					FilterCard(filter: filter)
				}
			}
			.padding()
			List {
				Section(header: Text("Drawers").font(.title3).fontWeight(.bold)) {
					if filteredDrawers.isEmpty {
						EmptyDrawersView(
							searching: !searchText.isEmpty,
							accentColor: accent.color
						)
					} else {
						ForEach(filteredDrawers) { drawer in
							NavigationLink(value: NavigationDestination.drawer(drawer)) {
								Label {
									Text(drawer.name)
								} icon: {
									Image(systemName: drawer.icon)
										.foregroundStyle(accent.color)
								}
							}
							.swipeActions(edge: .trailing, allowsFullSwipe: true) {
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
			.navigationDestination(for: NavigationDestination.self) { destination in
				DetailView(destination: destination)
			}
			.navigationTitle("Cabinet")
			.navigationBarTitleDisplayMode(.inline)
			.searchable(
				text: $searchText,
				prompt: "Search"
			)
			.toolbar {
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
			.task {
				await updateCounts()
			}
		}
	}
	
	func updateCounts() async {
		let allDescriptor = FetchDescriptor<Pair>()
		allCount = (try? modelContext.fetchCount(allDescriptor)) ?? 0
		
		let now = Date()
		let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: now)!
		
		// Fetch and filter manually instead of using predicate
		let allPairsDescriptor = FetchDescriptor<Pair>()
		if let allPairs = try? modelContext.fetch(allPairsDescriptor) {
			recentCount = allPairs.filter { pair in
				pair.lastUsedDate != nil && pair.lastUsedDate! >= sevenDaysAgo
			}.count
		} else {
			recentCount = 0
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
				.buttonStyle(.glassProminent)
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
			Text("This action cannot be undone. Items in this drawer will not be deleted, but will no longer be categorized.")
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
