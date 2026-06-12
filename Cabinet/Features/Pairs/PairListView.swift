//
//  PairListView.swift
//  Cabinet
//
//  Created by Eduardo Flores on 15/02/26.
//
import SwiftData
import SwiftUI

struct PairListView: View {
#if os(macOS)
	@Environment(\.openSettings) private var openSettings
#endif
	@Environment(\.modelContext) private var modelContext
	@AppStorage("accentColor") private var accent: AppColor = .indigo
	@State private var viewModel = PairListViewModel()
	
	@Query private var pairs: [Pair]
	
	var destination: Destination
	
	var displayedPairs: [Pair] {
		viewModel.filteredPairs(pairs, destination: destination)
	}
	
	var body: some View {
		Group {
			if displayedPairs.isEmpty {
				emptyState
			} else {
				pairList
			}
		}
		.navigationTitle(viewModel.navigationTitle(for: destination))
		.navigationSubtitle(viewModel.navigationSubtitle(for: destination))
#if !os(macOS)
		.navigationBarTitleDisplayMode(.inline)
		.environment(\.editMode, .constant(viewModel.isEditing ? .active : .inactive))
#endif
		.searchable(text: $viewModel.searchText, prompt: "Search")
		.toolbar { toolbar }
		.sheet(item: $viewModel.editingPair) { pair in
			editSheet(for: pair)
		}
		.sheet(isPresented: $viewModel.showingAdd) {
			addSheet
		}
		.onChange(of: destination) {
			if case .drawer(_) = destination {
				viewModel.selectedFilter = .all
			}
		}
	}
	
	// MARK: - Content
	
	private var pairList: some View {
		List(selection: $viewModel.selectedItems) {
			ForEach(displayedPairs) { pair in
				PairListItemView(pair: pair, editingPair: $viewModel.editingPair)
					.onTapGesture {
						viewModel.editingPair = pair
					}
			}
		}
	}
	
	private var emptyState: some View {
		VStack(spacing: 16) {
			Image(systemName: !viewModel.searchText.isEmpty ? "magnifyingglass" : "archivebox")
				.font(.system(size: 48))
				.foregroundStyle(.secondary)
			Text(!viewModel.searchText.isEmpty ? "No matches" : "No items yet")
				.font(.title3)
				.bold()
			Text(!viewModel.searchText.isEmpty ? "Try a different search term." : "Add your first item.")
				.foregroundStyle(.secondary)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.multilineTextAlignment(.center)
		.padding()
	}
	
	// MARK: - Toolbar
	
	@ToolbarContentBuilder
	private var toolbar: some ToolbarContent {
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
	
	// MARK: - Toolbar Items
	
	private var primaryAction: some View {
		Group {
			if viewModel.isEditing {
				Button("Delete", systemImage: "trash", role: .destructive) {
					viewModel.showItemDeleteConfirmation.toggle()
				}
				.tint(.red)
				.disabled(viewModel.selectedItems.isEmpty)
			} else {
				Button("New", systemImage: "square.and.pencil") {
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
			isPresented: $viewModel.showItemDeleteConfirmation,
			titleVisibility: .visible
		) {
			Button("Delete", role: .destructive) {
				deleteSelected()
			}
		} message: {
			Text("This action cannot be undone.")
		}
	}
	
	private var editButton: some View {
		Group {
			if viewModel.isEditing {
				Button(
					viewModel.selectedItems.count == displayedPairs.count
					? "Deselect All" : "Select All"
				) {
					if viewModel.selectedItems.count == displayedPairs.count {
						viewModel.selectedItems.removeAll()
					} else {
						viewModel.selectedItems = Set(displayedPairs.map { $0.id })
					}
				}
			}
			if !displayedPairs.isEmpty {
				Button(
					"Edit",
					systemImage: viewModel.isEditing ? "checkmark" : "pencil",
					role: viewModel.isEditing ? .confirm : .close
				) {
					withAnimation {
						viewModel.isEditing.toggle()
						if !viewModel.isEditing {
							viewModel.selectedItems.removeAll()
						}
					}
				}
				.tint(viewModel.isEditing ? accent.color : nil)
			}
		}
	}
	
	private var filterPickerMenu: some View {
		Menu {
			Picker("Filter", selection: $viewModel.selectedFilter) {
				ForEach(Filter.allCases, id: \.self) { filter in
					filter.label
				}
			}
		} label: {
			Label(
				viewModel.selectedFilter.rawValue.capitalized,
				systemImage: "line.3.horizontal.decrease"
			)
		}
	}
	
	// MARK: - Sheets
	
	private func editSheet(for pair: Pair) -> some View {
		NavigationStack {
			PairFormView(mode: .edit, pair: pair, onSave: {})
		}
		.tint(accent.color)
		.interactiveDismissDisabled()
		.presentationDetents([.large])
	}
	
	private var addSheet: some View {
		let pair = Pair(key: "", value: "", drawers: viewModel.selectedDrawers(for: destination))
		if viewModel.selectedFilter == .favorites {
			pair.isFavorite = true
		}
		return NavigationStack {
			PairFormView(mode: .new, pair: pair, onSave: {
				viewModel.selectedFilter = .all
			})
		}
		.presentationDetents([.large])
		.interactiveDismissDisabled()
	}
	
	// MARK: - Actions
	
	private func deleteSelected() {
		for id in viewModel.selectedItems {
			if let item = pairs.first(where: { $0.id == id }) {
				modelContext.delete(item)
			}
		}
		withAnimation {
			viewModel.selectedItems.removeAll()
			viewModel.isEditing = false
		}
	}
}

#Preview {
	NavigationStack {
		Color.clear
			.navigationTitle("Cabinet")
			.navigationDestination(isPresented: .constant(true)) {
				PairListView(
					destination: Destination.filter(.all)
				)
				.modelContainer(PreviewData.shared.modelContainer)
			}
	}
}
