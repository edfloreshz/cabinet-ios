//
//  PairListView.swift
//  Cabinet
//
//  Created by Eduardo Flores on 15/02/26.
//
import SwiftData
import SwiftUI

struct PairContainerView: View {
	@Environment(\.modelContext) private var modelContext
	@AppStorage("accentColor") private var accent: AppColor = .indigo
	@State private var viewModel = PairContainerViewModel()
	
	@Query private var pairs: [Pair]
	
	var destination: Destination
	
	private var displayedPairs: [Pair] {
		viewModel.filteredPairs(pairs, destination: destination)
	}
	
	var body: some View {
		NavigationStack {
			VStack(spacing: 0) {
				if displayedPairs.isEmpty {
					emptyState
				} else {
					contentView
				}
			}
			.safeAreaInset(edge: .top) {
				if !viewModel.isEditing && viewModel.showLayoutOptions {
					VStack(spacing: 0) {
						layoutPickerMenu
							.padding(.horizontal)
							.padding(.bottom, 8)
							.transition(.move(edge: .top).combined(with: .opacity))
						Divider()
					}
					.background(.ultraThinMaterial)
				}
			}
			.animation(.smooth(duration: 0.25), value: viewModel.isEditing)
			.animation(.smooth(duration: 0.25), value: viewModel.showLayoutOptions)
			.animation(.easeInOut(duration: 0.2), value: viewModel.currentLayout)
			.navigationTitle(viewModel.navigationTitle(for: destination))
			.navigationSubtitle(viewModel.navigationSubtitle(for: destination))
			.navigationBarTitleDisplayMode(.inline)
			.environment(\.editMode, .constant(viewModel.isEditing ? .active : .inactive))
			.searchable(text: $viewModel.searchText, prompt: "Search")
			.toolbar { toolbar }
			.sheet(item: $viewModel.editingPair) { pair in
				editSheet(for: pair)
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
	private var toolbar: some ToolbarContent {
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
			editButton
		}
		if case .drawer = destination {
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
				Button("New", systemImage: "plus") {
					viewModel.showingAdd.toggle()
				}
				.buttonStyle(.glassProminent)
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
	
	private var layoutPickerMenu: some View {
		Picker("Layout", selection: $viewModel.currentLayout) {
			ForEach(LayoutType.allCases, id: \.self) { layout in
				Label(
					layout.title,
					systemImage: layout.symbolName
				)
			}
		}.pickerStyle(.segmented)
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
		PairContainerView(destination: .drawer(Drawer.sampleData.first!))
	}
	.modelContainer(PreviewData.shared.modelContainer)
}
