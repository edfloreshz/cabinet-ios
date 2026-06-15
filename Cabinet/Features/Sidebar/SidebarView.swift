//
//  SidebarView.swift
//  Cabinet
//
//  Created by Eduardo Flores on 14/06/26.
//

import SwiftUI
import SwiftData

struct SidebarView: View {
	@Environment(\.modelContext) private var modelContext
	@AppStorage("accentColor") var accent: AppColor = .indigo
	@Namespace private var namespace
	@Binding var selectedDestination: Destination?

	@Query private var drawers: [Drawer]
	@State private var viewModel = SidebarViewModel()

    var body: some View {
		List(selection: $selectedDestination) {
			CategoriesListView()
			DrawersListView(viewModel: $viewModel)
		}
		.navigationTitle("Cabinet")
		.navigationBarTitleDisplayMode(.inline)
		.searchable(text: $viewModel.searchText, prompt: "Search")
		.navigationSplitViewColumnWidth(min: 310, ideal: 310)
		.toolbar {
			ToolbarItem(placement: .topBarLeading) {
				Button("Settings", systemImage: "gearshape") {
					viewModel.showingSettings.toggle()
				}
			}
			ToolbarItem(placement: .automatic) {
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
						.buttonStyle(.glassProminent)
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
			.matchedTransitionSource(id: "add-drawer-transition", in: namespace)
		}
		.sheet(isPresented: $viewModel.showingSettings) {
			NavigationStack {
				SettingsView()
			}
			.tint(accent.color)
			.presentationDetents([.medium, .large])
		}
		.sheet(isPresented: $viewModel.showingAdd) {
			NavigationStack {
				DrawerFormView(drawer: Drawer(name: ""))
					.presentationSizing(.fitted)
			}
			.presentationDetents([.large])
			.interactiveDismissDisabled()
			.navigationTransition(.zoom(sourceID: "add-drawer-transition", in: namespace))
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
	@Previewable @State var viewModel = SidebarViewModel()
	@Previewable @State var selectedDestination: Destination? = .filter(.all)
	
	NavigationStack {
		SidebarView(selectedDestination: $selectedDestination)
	}
}
