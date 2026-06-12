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
			sidebar
		} detail: {
			detail
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
			NavigationStack {
				SettingsView()
			}
			.tint(accent.color)
			.presentationDetents([.large])
		}
		.sheet(isPresented: $viewModel.showingAdd) {
			NavigationStack {
				DrawerFormView(drawer: Drawer(name: ""))
					.presentationSizing(.fitted)
			}
			.presentationDetents([.large])
			.interactiveDismissDisabled()
		}
		.sheet(item: $viewModel.editingDrawer) { drawer in
			NavigationStack {
				DrawerFormView(drawer: drawer)
					.presentationSizing(.fitted)
			}
			.presentationDetents([.large])
			.interactiveDismissDisabled()
		}
	}
	
	// MARK: - Subviews
	
	private var sidebar: some View {
		List(selection: $viewModel.selectedDestination) {
			SmartFiltersListView()
			DrawersListView(
				searchText: $viewModel.searchText,
				editingDrawer: $viewModel.editingDrawer,
				drawerToDelete: $viewModel.drawerToDelete,
				filteredDrawers: viewModel.filteredDrawers(drawers)
			)
		}
		.navigationTitle("Cabinet")
#if !os(macOS)
		.navigationBarTitleDisplayMode(.inline)
		.searchable(text: $viewModel.searchText, prompt: "Search")
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
	}
	
	private var detail: some View {
		Group {
			if let destination = viewModel.selectedDestination {
				PairListView(destination: destination)
			} else {
				ContentUnavailableView(
					"Select a drawer",
					systemImage: "archivebox",
					description: Text("Choose a drawer from the sidebar to view its contents")
				)
			}
		}
	}
	
	private var primaryAction: some View {
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
				deleteSelectedItems()
			}
		} message: {
			Text("This action cannot be undone. Items in this drawer will not be deleted, but will no longer be categorized.")
		}
	}
	
	// MARK: - Actions
	
	private func deleteSelectedItems() {
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

#Preview {
	LibraryView()
		.modelContainer(SampleData.shared.modelContainer)
}
