//
//  ContentView.swift
//  Cabinet
//
//  Created by Eduardo Flores on 26/11/25.
//

import LocalAuthentication
import SwiftData
import SwiftUI

struct ContentView: View {
	@Environment(\.modelContext) private var modelContext
	@AppStorage("accentColor") private var accent: ThemeColor = .indigo

	@Query private var pairs: [Pair]
	@Query private var drawers: [Drawer]

	@State private var viewModel = ContentViewModel()
	@State private var isEditing = false
	@State private var showingAdd = false
	@State private var showingAddDrawer = false
	@State private var showingSettings = false
	@State private var showItemDeleteConfirmation = false
	@State private var showDrawerDeleteConfirmation = false
	@State private var editingDrawer: Drawer? = nil
	@State private var drawerToDelete: Drawer? = nil
	@State private var selectedItems: Set<UUID> = []

	var body: some View {
		let displayedPairs = viewModel.filteredPairs(pairs)

		NavigationStack {
			Group {
				if displayedPairs.isEmpty {
					EmptyView(
						searching: !viewModel.searchText.isEmpty,
						accentColor: accent.color
					)
				} else {
					List(selection: $selectedItems) {
						ForEach(displayedPairs) { pair in
							ItemRowView(pair: pair)
								.onTapGesture {
									if !isEditing {
										handleCopy(for: pair)
									}
								}
						}
					}
					.environment(
						\.editMode,
						.constant(isEditing ? .active : .inactive)
					)
				}
			}
			.navigationTitle("Cabinet")
			.navigationBarTitleDisplayMode(.inline)
			.searchable(
				text: $viewModel.searchText,
				prompt: "Keys, values, notes"
			)
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button("Settings", systemImage: "gearshape") {
						showingSettings.toggle()
					}
				}
				ToolbarItemGroup(placement: .topBarTrailing) {
					editButton
				}
				ToolbarItem(placement: .bottomBar) {
					drawerPickerMenu
				}
				ToolbarSpacer(placement: .bottomBar)
				DefaultToolbarItem(kind: .search, placement: .bottomBar)
				ToolbarSpacer(placement: .bottomBar)
				ToolbarItem(placement: .bottomBar) {
					primaryAction
				}
			}
			.sheet(isPresented: $showingSettings) {
				NavigationStack {
					SettingsView()
				}
				.tint(accent.color)
				.presentationDetents([.medium, .large])
			}
			.sheet(isPresented: $showingAddDrawer) {
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
			.sheet(isPresented: $showingAdd) {
				NavigationStack {
					ItemView(
						mode: .new,
						pair: Pair(key: "", value: ""),
					)
				}
				.presentationDetents([.large])
				.interactiveDismissDisabled()
			}
		}
	}

	fileprivate var drawerPickerMenu: some View {
		Menu {
			Section("General") {
				ForEach(Drawer.defaultDrawers) { drawer in
					Button {
						viewModel.selectedDrawer = drawer.name
					} label: {
						Label(
							drawer.name.capitalized,
							systemImage: drawer.icon
						)
					}
				}
			}

			Section("Drawers") {
				ForEach(drawers) { drawer in
					Menu {
						Button(
							"Delete",
							systemImage: "trash",
							role: .destructive
						) {
							drawerToDelete = drawer
							showDrawerDeleteConfirmation = true
						}
						Button("Edit", systemImage: "pencil") {
							editingDrawer = drawer
						}
						Button("Select", systemImage: "checkmark.circle") {
							viewModel.selectedDrawer = drawer.name
						}
					} label: {
						Label(
							drawer.name.capitalized,
							systemImage: drawer.icon
						)
					}
				}

				Divider()

				Button {
					showingAddDrawer.toggle()
				} label: {
					Label("Add Drawer", systemImage: "plus.circle")
				}
			}
		} label: {
			Label(
				viewModel.selectedDrawer.capitalized,
				systemImage: "line.3.horizontal.decrease"
			)
		}
		.confirmationDialog(
			"Delete '\(drawerToDelete?.name ?? "drawer")'?",
			isPresented: $showDrawerDeleteConfirmation,
			titleVisibility: .visible
		) {
			Button("Delete", role: .destructive) {
				if let drawer = drawerToDelete {
					if viewModel.selectedDrawer == drawer.name {
						viewModel.selectedDrawer = "All"
					}
					modelContext.delete(drawer)
				}
			}
			Button("Cancel", role: .cancel) {
				drawerToDelete = nil
			}
		} message: {
			Text("This action cannot be undone. Items in this drawer will not be deleted, but will no longer be categorized.")
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
				.buttonStyle(.glassProminent)
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
		let displayedPairs = viewModel.filteredPairs(pairs)

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

	private func handleCopy(for pair: Pair) {
		let performCopy = {
			#if canImport(UIKit)
				UIPasteboard.general.string = pair.value
			#elseif canImport(AppKit)
				let pb = NSPasteboard.general
				pb.clearContents()
				pb.setString(pair.value, forType: .string)
			#endif

			ToastManager.shared.show("Copied", type: .info)
		}

		// Only authenticate if the item is hidden and we aren't currently in Edit Mode
		if pair.isHidden {
			AuthenticationService.authenticate { result in
				switch result {
				case .success:
					performCopy()
				case .failure(let error):
					ToastManager.shared.show(error.message, type: .error)
				}
			}
		} else {
			// If not hidden or in edit mode, copy directly
			performCopy()
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
	ContentView().modelContainer(SampleData.shared.modelContainer)
}
