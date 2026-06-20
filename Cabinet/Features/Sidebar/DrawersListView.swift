//
//  DrawersListView.swift
//  Cabinet
//
//  Created by Eduardo Flores on 11/06/26.
//

import SwiftData
import SwiftUI

struct DrawersListView: View {
	@Environment(\.modelContext) private var modelContext
	@AppStorage("accentColor") var accent: AppColor = .indigo
	
	@Binding var viewModel: SidebarViewModel
	@Binding var selectedDestination: Destination?
	@State var editingDrawer: Drawer?
	@State var drawerToDelete: Drawer?
	@Query(sort: \Drawer.name) var drawers: [Drawer]

	var body: some View {
		Section(header: Text("Drawers").fontWeight(.bold)) {
			if viewModel.filteredDrawers(drawers).isEmpty {
				ContentUnavailableView {
					Label("No drawers", systemImage: "archivebox")
				} description: {
					Text(viewModel.searchText.isEmpty
						 ? "Add your first drawer."
						 : "Try a different search term.")
				}
			} else {
				ForEach(viewModel.filteredDrawers(drawers)) { drawer in
					NavigationLink(value: Destination.drawer(drawer)) {
						Label {
							Text(drawer.name)
						} icon: {
							Image(systemName: drawer.icon)
								.foregroundStyle(accent.color)
						}
					}
					.tag(drawer.id)
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
		.sheet(item: $editingDrawer) { drawer in
			NavigationStack {
				DrawerFormView(drawer: drawer)
					.presentationSizing(.fitted)
			}
			.presentationDetents([.large])
			.interactiveDismissDisabled()
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
					delete(drawer: drawer)
				}
			}
			Button("Cancel", role: .cancel) {
				drawerToDelete = nil
			}
		} message: {
			Text("This action cannot be undone.")
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

	private func delete(drawer: Drawer) {
		do {
			if selectedDestination == .drawer(drawer) {
				selectedDestination = .filter(.all)
			}

			modelContext.delete(drawer)
			try modelContext.save()
			drawerToDelete = nil
		} catch {
			ToastManager.shared.show(
				"Couldn't delete this drawer.",
				type: .error,
				duration: 2.2
			)
		}
	}
}

@MainActor
let previewContainer: ModelContainer = {
	let container = try! ModelContainer(for: Drawer.self, configurations: .init(isStoredInMemoryOnly: true))
	for drawer in Drawer.sampleData {
		container.mainContext.insert(drawer)
	}
	return container
}()

#Preview("With Drawers") {
	@Previewable @State var viewModel = SidebarViewModel()
	@Previewable @State var selectedDestination: Destination? = .drawer(Drawer.sampleData.first!)
	
	List(selection: $selectedDestination) {
		DrawersListView(
			viewModel: $viewModel,
			selectedDestination: $selectedDestination
		)
	}
	.modelContainer(previewContainer)
}

#Preview("Empty") {
	@Previewable @State var viewModel = SidebarViewModel()
	@Previewable @State var selectedDestination: Destination? = .drawer(Drawer.sampleData.first!)
	
	let container = try! ModelContainer(for: Drawer.self, configurations: .init(isStoredInMemoryOnly: true))
	
	
	List(selection: $selectedDestination) {
		DrawersListView(
			viewModel: $viewModel,
			selectedDestination: $selectedDestination
		)
	}
	.modelContainer(container)
}
