//
//  PairListView.swift
//  Cabinet
//
//  Created by Eduardo Flores on 15/02/26.
//

import SwiftData
import SwiftUI

struct PairListView: View {
	@Environment(\.modelContext) private var modelContext

	#if os(macOS)
		@Environment(\.openSettings) private var openSettings
	#endif

	@AppStorage("accentColor") private var accent: AppColor = .indigo
	@State private var viewModel = PairListViewModel()
	@State private var isEditing = false
	@State private var showingAdd = false
	@State private var showItemDeleteConfirmation = false
	@State private var selectedItems: Set<UUID> = []
	@State private var showingSettings: Bool = false
	@State var editingPair: Pair?
	
	@Query private var pairs: [Pair]
	

	var destination: Destination
	var displayedPairs: [Pair] {
		viewModel.filteredPairs(pairs, destination: destination)
	}

	var navigationTitle: Text {
		switch destination {
		case .drawer(let drawer):
			Text(drawer.name.capitalized)
		case .filter(let filterCategory):
			switch filterCategory {
			case .all:
				Text("All")
			case .favorites:
				Text("Favorites")
			case .recents:
				Text("Recents")
			}
		}
	}
	var navigationSubtitle: Text {
		switch destination {
		case .drawer(let drawer):
			Text(drawer.purpose)
		case .filter(let filterCategory):
			switch filterCategory {
			case .all:
				Text("All your items")
			case .favorites:
				Text("Your favorites")
			case .recents:
				Text("Recently copied")
			}
		}
	}

	var body: some View {
		Group {
			if displayedPairs.isEmpty {
				VStack(spacing: 16) {
					Image(systemName: !viewModel.searchText.isEmpty ? "magnifyingglass" : "archivebox")
						.font(.system(size: 48))
						.foregroundStyle(.secondary)
					Text(!viewModel.searchText.isEmpty ? "No matches" : "No items yet")
						.font(.title3)
						.bold()
					Text(
						!viewModel.searchText.isEmpty
						? "Try a different search term." : "Add your first item."
					)
					.foregroundStyle(.secondary)
				}
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.multilineTextAlignment(.center)
				.padding()
			} else {
				List(selection: $selectedItems) {
					ForEach(displayedPairs) { pair in
						PairListItemView(pair: pair, editingPair: $editingPair)
							.onTapGesture {
								editingPair = pair
							}
					}
				}
			}
		}
		.navigationTitle(navigationTitle)
		.navigationSubtitle(navigationSubtitle)
		#if !os(macOS)
			.navigationBarTitleDisplayMode(.inline)
			.environment(
				\.editMode,
				.constant(isEditing ? .active : .inactive)
			)
		#endif
		.searchable(
			text: $viewModel.searchText,
			prompt: "Search"
		)
		.toolbar {
			#if !os(macOS)
				ToolbarItemGroup(placement: .topBarTrailing) {
					editButton
				}
				if case .drawer(_) = destination {
					ToolbarItem(placement: .bottomBar) {
						filterPickerMenu
					}
					ToolbarSpacer(placement: .bottomBar)
				}
				DefaultToolbarItem(kind: .search, placement: .bottomBar)
				ToolbarSpacer(placement: .bottomBar)
				ToolbarItem(placement: .bottomBar) {
					primaryAction
				}
			#else
				ToolbarItem(placement: .automatic) {
					Button("Settings", systemImage: "gearshape") {
						openSettings()
					}
				}
				ToolbarSpacer()
				if case .drawer(_) = destination {
					ToolbarItem(placement: .automatic) {
						filterPickerMenu
					}
				}
				ToolbarItem(placement: .automatic) {
					primaryAction
				}
			#endif
		}
		.sheet(item: $editingPair) { pair in
			NavigationStack {
				PairFormView(mode: .edit, pair: pair, onSave: {})
			}
			.tint(accent.color)
			.interactiveDismissDisabled()
			.presentationDetents([.large])
		}
		.sheet(isPresented: $showingAdd) {
			addSheet
		}
		.sheet(isPresented: $showingSettings) {
			NavigationStack {
				SettingsView()
			}
			.tint(accent.color)
			.presentationDetents([.medium, .large])
		}
		.onChange(of: destination) {
			if case .drawer(_) = destination {
				viewModel.selectedFilter = .all
			}
		}
	}

	var selectedDrawers: [UUID] {
		switch destination {
		case .drawer(let drawer):
			return [drawer.id]
		case .filter:
			return []
		}
	}

	fileprivate var addSheet: some View {
		let pair = Pair(key: "", value: "", drawers: selectedDrawers)

		if viewModel.selectedFilter == .favorites {
			pair.isFavorite = true
		}

		return NavigationStack {
			PairFormView(
				mode: .new,
				pair: pair,
				onSave: {
					viewModel.selectedFilter = .all
				}
			)
		}
		.presentationDetents([.large])
		.interactiveDismissDisabled()
	}

	fileprivate var filterPickerMenu: some View {
		Menu {
			Picker("Filter", selection: $viewModel.selectedFilter) {
				ForEach(Filter.allCases, id: \.self) { filter in
					filter.label
				}
			}.pickerStyle(.inline)
		} label: {
			Label(
				viewModel.selectedFilter.rawValue.capitalized,
				systemImage: "line.3.horizontal.decrease"
			)
		}
	}

	fileprivate var primaryAction: some View {
		Group {
			if isEditing {
				Button("Delete", systemImage: "trash", role: .destructive) {
					showItemDeleteConfirmation.toggle()
				}
				.tint(.red)
				.disabled(selectedItems.isEmpty)
			} else {
				Button("New", systemImage: "plus") {
					showingAdd.toggle()
				}
				#if !os(macOS)
					.buttonStyle(.glassProminent)
				#endif
				.tint(accent.color)
			}
		}
		.confirmationDialog(
			"Delete selected items?",
			isPresented: $showItemDeleteConfirmation,
			titleVisibility: .visible
		) {
			Button("Delete", role: .destructive) {
				deleteSelected()
			}
		} message: {
			Text("This action cannot be undone.")
		}
	}

	fileprivate var editButton: some View {
		return Group {
			if isEditing {
				Button(
					selectedItems.count == displayedPairs.count
						? "Deselect All" : "Select All"
				) {
					if selectedItems.count == displayedPairs.count {
						selectedItems.removeAll()
					} else {
						selectedItems = Set(displayedPairs.map { $0.id })
					}
				}
			}
			if !displayedPairs.isEmpty {
				Button(
					"Edit",
					systemImage: isEditing ? "checkmark" : "pencil",
					role: isEditing ? .confirm : .close
				) {
					withAnimation {
						isEditing.toggle()
						if !isEditing {
							selectedItems.removeAll()
						}
					}
				}.tint(isEditing ? accent.color : nil)
			}
		}
	}

	fileprivate func deleteSelected() {
		for id in selectedItems {
			if let item = pairs.first(where: { $0.id == id }) {
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
	PairListView(
		destination: Destination.drawer(Drawer.sampleData.first!)
	)
	.modelContainer(SampleData.shared.modelContainer)
}

