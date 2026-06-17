//
//  PairListView.swift
//  Cabinet
//
//  Created by Eduardo Flores on 15/02/26.
//

import SwiftData
import SwiftUI

struct ContentView: View {
	@Environment(\.modelContext) private var modelContext
	@AppStorage("accentColor") private var accent: AppColor = .indigo
	@Namespace private var namespace

	@State private var viewModel = ContentViewModel()
	
	@Query private var pairs: [Pair]
	
	@Binding var selectedDestination: Destination?
	
	private var displayedPairs: [Pair] {
		viewModel.filteredPairs(pairs, destination: selectedDestination)
	}
	
	var body: some View {
		if let destination = selectedDestination {
			NavigationStack {
				VStack(spacing: 0) {
					if displayedPairs.isEmpty {
						if !viewModel.searchText.isEmpty {
							ContentUnavailableView.search(text: viewModel.searchText)
						} else {
							ContentUnavailableView(
								"No items yet",
								systemImage: "text.document",
								description: Text("Add your first item.")
							)
						}
					} else {
						switch viewModel.currentLayout {
						case .list:
							PairListLayoutView(
								pairs: displayedPairs,
								selectedItems: $viewModel.selectedItems,
								editingPair: $viewModel.editingPair
							)
						case .grid:
							PairGridLayoutView(
								pairs: displayedPairs,
								isEditing: viewModel.isEditing,
								selectedItems: $viewModel.selectedItems,
								editingPair: $viewModel.editingPair
							)
							.background(Color(uiColor: .systemGroupedBackground))
						}
					}
				}
				.safeAreaInset(edge: .top) {
					if !viewModel.isEditing && viewModel.showLayoutOptions {
						VStack(spacing: 0) {
							Picker("Layout", selection: $viewModel.currentLayout) {
								ForEach(LayoutType.allCases, id: \.self) { layout in
									Label(
										layout.title,
										systemImage: layout.symbolName
									)
								}
							}
							.pickerStyle(.segmented)
							.padding(.horizontal)
							.padding(.bottom, 8)
							.transition(.move(edge: .top).combined(with: .opacity))
							Divider()
						}
						.background(.ultraThinMaterial)
					}
				}
				.navigationTitle(viewModel.navigationTitle(for: destination))
				.navigationSubtitle(viewModel.navigationSubtitle(for: destination))
				.navigationBarTitleDisplayMode(.inline)
				.environment(\.editMode, .constant(viewModel.isEditing ? .active : .inactive))
				.searchable(text: $viewModel.searchText, prompt: "Search")
				.toolbar { contentTopToolbar }
				.toolbar { contentBottomToolbar }
				.sheet(item: $viewModel.editingPair) { pair in
					NavigationStack {
						PairFormView(mode: .edit, pair: pair, onSave: {})
					}
					.interactiveDismissDisabled()
					.presentationDetents([.large])
				}
				.sheet(isPresented: $viewModel.showingAdd) {
					addSheet
				}
				.onChange(of: destination) {
					if case .drawer = destination {
						viewModel.selectedFilter = .all
					}
				}
			}
		} else {
			ContentUnavailableView(
				"Select a drawer",
				systemImage: "archivebox",
				description: Text("Choose a drawer from the sidebar to view its contents")
			)
		}
	}
	
	// MARK: - Content
	
	@ViewBuilder
	private var contentView: some View {
		switch viewModel.currentLayout {
		case .list:
			PairListLayoutView(
				pairs: displayedPairs,
				selectedItems: $viewModel.selectedItems,
				editingPair: $viewModel.editingPair
			)
		case .grid:
			PairGridLayoutView(
				pairs: displayedPairs,
				isEditing: viewModel.isEditing,
				selectedItems: $viewModel.selectedItems,
				editingPair: $viewModel.editingPair
			)
			.background(Color(uiColor: .systemGroupedBackground))
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
	private var contentTopToolbar: some ToolbarContent {
		if !viewModel.isEditing {
			ToolbarItem(placement: .topBarTrailing) {
				Button {
					withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
						viewModel.showLayoutOptions.toggle()
					}
				} label: {
					Image(systemName: viewModel.showLayoutOptions ? "slider.horizontal.2.square" : "slider.horizontal.3")
				}
				.tint(viewModel.showLayoutOptions ? accent.color : .primary)
			}
			ToolbarSpacer(placement: .topBarTrailing)
		}
		ToolbarItemGroup(placement: .topBarTrailing) {
			Group {
				if viewModel.isEditing {
					Button(
						viewModel.selectedItems.count == displayedPairs.count
							? "Deselect All" : "Select All"
					) {
						if viewModel.selectedItems.count == displayedPairs.count {
							viewModel.selectedItems.removeAll()
						} else {
							viewModel.selectedItems = Set(displayedPairs.map(\.id))
						}
					}
				}
				
				if !displayedPairs.isEmpty {
					Button(
						viewModel.isEditing ? "Done" : "Edit",
						systemImage: viewModel.isEditing ? "checkmark" : "pencil"
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
	}
	
	@ToolbarContentBuilder
	private var contentBottomToolbar: some ToolbarContent {
		if case .drawer = selectedDestination {
			ToolbarItem(placement: .bottomBar) {
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
			ToolbarSpacer(placement: .bottomBar)
		}
		
		DefaultToolbarItem(kind: .search, placement: .bottomBar)
		ToolbarSpacer(placement: .bottomBar)
		
		if viewModel.isEditing {
			ToolbarItem(placement: .bottomBar) {
				Button("Delete", systemImage: "trash", role: .destructive) {
					viewModel.showItemDeleteConfirmation.toggle()
				}
				.tint(.red)
				.disabled(viewModel.selectedItems.isEmpty)
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
		} else {
			ToolbarItem(placement: .bottomBar) {
				Button("New", systemImage: "plus") {
					viewModel.showingAdd.toggle()
				}
				.buttonStyle(.glassProminent)
				.tint(accent.color)
				.matchedTransitionSource(id: "add-pair-transition", in: namespace)
			}
		}
	}
	
	// MARK: - Sheets

	private var addSheet: some View {
		let pair = Pair(key: "", value: "", drawers: viewModel.selectedDrawers(for: selectedDestination))
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
		.navigationTransition(.zoom(sourceID: "add-pair-transition", in: namespace))
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

#Preview("Selected") {
	@Previewable @State var selectedDestination: Destination? = .drawer(Drawer.sampleData.first!)
	
	NavigationStack {
		ContentView(selectedDestination: $selectedDestination)
	}
	.modelContainer(PreviewData.shared.modelContainer)
}

#Preview("Unselected") {
	NavigationStack {
		ContentView(selectedDestination: .constant(nil))
	}
	.modelContainer(PreviewData.shared.modelContainer)
}
