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
	@Query private var categories: [Category]

	@State private var viewModel = ContentViewModel()
	@State private var isEditing = false
	@State private var showingAdd = false
	@State private var showingAddCategory = false
	@State private var showingSettings = false
	@State private var showDeleteConfirmation = false
	@State private var editingCategory: Category? = nil
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
					categoryPickerMenu
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
			.sheet(isPresented: $showingAddCategory) {
				NavigationStack {
					CategoryView(
						category: Category(name: ""),
					)
				}
				.tint(accent.color)
				.presentationDetents([.large])
				.interactiveDismissDisabled()
			}
			.sheet(item: $editingCategory) { category in
				NavigationStack {
					CategoryView(category: category)
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

	fileprivate var categoryPickerMenu: some View {
		Menu {
			Section("General") {
				ForEach(Category.defaultCategories) { category in
					Button {
						viewModel.selectedCategory = category.name
					} label: {
						Label(
							category.name.capitalized,
							systemImage: category.icon
						)
					}
				}
			}

			Section("Categories") {
				ForEach(categories) { category in
					Menu {
						Button(
							"Delete",
							systemImage: "trash",
							role: .destructive
						) {
							modelContext.delete(category)
						}
						Button("Edit", systemImage: "pencil") {
							editingCategory = category
						}
						Button("Select", systemImage: "checkmark.circle") {
							viewModel.selectedCategory = category.name
						}
					} label: {
						Label(
							category.name.capitalized,
							systemImage: category.icon
						)
					}
				}

				Divider()

				Button {
					showingAddCategory.toggle()
				} label: {
					Label("Add Category", systemImage: "plus.circle")
				}
			}
		} label: {
			Label(
				viewModel.selectedCategory.capitalized,
				systemImage: "line.3.horizontal.decrease"
			)
		}
	}

	fileprivate var primaryAction: some View {
		Group {
			if isEditing {
				Button("Delete", systemImage: "trash", role: .destructive) {
					showDeleteConfirmation.toggle()
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
			isPresented: $showDeleteConfirmation,
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
