//
//  ContentView.swift
//  Cabinet
//
//  Created by Eduardo Flores on 26/11/25.
//

import SwiftData
import SwiftUI
import LocalAuthentication
import os

struct ContentView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.editMode) private var editMode
	
	@State private var isEditing = false
	@State private var showingAdd = false
	@State private var showingAddCategory = false
	@State private var showingSettings = false
	@State private var editingPair: Pair? = nil
	@State private var searchText: String = ""
	@State private var selectedItems: Set<UUID> = []
	@State private var selectedCategory: String = "All"
	@Query private var pairs: [Pair]
	@Query private var categories: [Category]
	
	@AppStorage("accentColor") private var accentColorName: String = "indigo"

	private let logger = Logger(subsystem: "dev.edfloreshz.Cabinet", category: "Utilities")
	private var accentColor: Color {
		Color.accentColorFromName(accentColorName)
	}

	var body: some View {
		NavigationStack {
			Group {
				if filteredAndSortedPairs.isEmpty {
					EmptyView(searching: !searchText.isEmpty, accentColor: accentColor)
				} else {
					List(selection: $selectedItems) {
						ForEach(filteredAndSortedPairs) { pair in
							ItemRowView(
								pair: pair,
								accentColor: accentColor,
								onEdit: { editingPair = pair },
								onDelete: { modelContext.delete(pair) }
							)
							.onTapGesture {
								if !isEditing && pair.isHidden {
									AuthenticationService.authenticate { result in
										switch result {
										case .success:
											Clipboard.copy(pair.value)
											ToastManager.shared.show("Copied", type: .info)
										case .failure(let error):
											ToastManager.shared.show(error.message, type: .error)
										}
									}
								} else {
									Clipboard.copy(pair.value)
									ToastManager.shared.show("Copied", type: .info)
								}
							}
						}
					}
					.environment(\.editMode, .constant(isEditing ? .active : .inactive))
				}
			}
			.navigationTitle("Cabinet")
			.toolbarBackgroundVisibility(.hidden, for: .automatic)
			.navigationBarTitleDisplayMode(.inline)
			.searchable(text: $searchText, prompt: "Search keys or values")
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button("Settings", systemImage: "gear") {
						showingSettings.toggle()
					}
				}
				
				if !filteredAndSortedPairs.isEmpty {
					ToolbarItem(placement: .topBarTrailing) {
						Button(isEditing ? "" : "Edit",
							   systemImage: isEditing ? "checkmark" : "",
							   role: isEditing ? .confirm : .close) {
							withAnimation {
								isEditing.toggle()
								if !isEditing {
									selectedItems.removeAll()
								}
							}
						}.tint(accentColor)
					}
				}
				
				ToolbarItem(placement: .bottomBar) {
					Menu {
						Picker("Categories", selection: $selectedCategory) {
							ForEach(Category.defaultCategories) { category in
								Label(category.name.capitalized, systemImage: category.icon).tag(category.name)
							}
							ForEach(categories) { category in
								Label(category.name.capitalized, systemImage: category.icon).tag(category.name)
							}
						}
						ControlGroup {
							Button("Add Category", systemImage: "plus.circle.fill") {
								showingAddCategory.toggle()
							}
						}
					} label: {
						Label("Filters", systemImage: "line.3.horizontal.decrease.circle")
					}
				}
				ToolbarSpacer(placement: .bottomBar)
				DefaultToolbarItem(kind: .search, placement: .bottomBar)
				ToolbarSpacer(placement: .bottomBar)
				
				if isEditing {
					ToolbarItem(placement: .bottomBar) {
						Button("Delete", systemImage: "trash", role: .destructive) {
							for id in selectedItems {
								if let item = filteredAndSortedPairs.first(where: { $0.id == id }) {
									modelContext.delete(item)
								}
							}
							selectedItems.removeAll()
							isEditing.toggle()
						}
						.tint(.red)
						.disabled(selectedItems.isEmpty)
					}
				} else {
					ToolbarItem(placement: .bottomBar) {
						Button("New", systemImage: "plus") {
							showingAdd.toggle()
						}.tint(accentColor)
					}
				}
			}
			.sheet(isPresented: $showingSettings) {
				NavigationStack {
					SettingsView(accentColorName: $accentColorName)
				}
				.tint(accentColor)
				.presentationDetents([.medium, .large])
			}
			.sheet(isPresented: $showingAdd) {
				NavigationStack {
					EditItemView(title: "New Item",
								 pair: Pair(key: "", value: ""),
								 onSave: { newPair in modelContext.insert(newPair) },
								 onRevealOrToggleHidden: { pairToReveal in pairToReveal.isHidden
						? AuthenticationService.authenticate { result in
							switch result {
							case .success:
								pairToReveal.isHidden.toggle()
							case .failure(let error):
								ToastManager.shared.show(error.message, type: .error)
							}
						} : pairToReveal.isHidden.toggle() })
				}
				.tint(accentColor)
				.presentationDetents([.medium, .large])
			}
			.sheet(isPresented: $showingAddCategory) {
				NavigationStack {
					EditCategoryView(category: Category(name: "", icon: ""), onSave: { newCategory in
						modelContext.insert(newCategory)
					})
				}
				.tint(accentColor)
				.presentationDetents([.medium, .large])
			}
			.sheet(item: $editingPair) { pair in
				NavigationStack {
					EditItemView(title: "Edit Item", pair: pair, onSave: {
						editedPair in
						pair.key = editedPair.key
						pair.value = editedPair.value
						pair.isHidden = editedPair.isHidden
					}, onRevealOrToggleHidden: {
						pairToReveal in pairToReveal.isHidden
						? AuthenticationService.authenticate { result in
							switch result {
							case .success:
								pairToReveal.isHidden.toggle()
							case .failure(let error):
								ToastManager.shared.show(error.message, type: .error)
							}
						} : pairToReveal.isHidden.toggle()
					})
				}
				.tint(accentColor)
				.presentationDetents([.medium, .large])
			}
		}
	}
	
	private var filteredAndSortedPairs: [Pair] {
		let base = pairs
		let searchFiltered: [Pair]
		if searchText.isEmpty {
			searchFiltered = base
		} else {
			let term = searchText.lowercased()
			searchFiltered = base.filter {
				$0.key.lowercased().contains(term) || $0.value.lowercased().contains(term)
			}
		}

		let categoryFiltered: [Pair]
		switch selectedCategory {
		case "All":
			categoryFiltered = searchFiltered
		case "Favorites":
			categoryFiltered = searchFiltered.filter { $0.isFavorite }
		default:
			categoryFiltered = searchFiltered.filter { pair in
				(pair.categories).contains { $0.caseInsensitiveCompare(selectedCategory) == .orderedSame }
			}
		}

		return categoryFiltered.sorted { lhs, rhs in
			if lhs.isFavorite != rhs.isFavorite { return lhs.isFavorite && !rhs.isFavorite }
			return lhs.key.localizedCaseInsensitiveCompare(rhs.key) == .orderedAscending
		}
	}
	
	private func delete(at offsets: IndexSet) {
		let items = offsets.compactMap { index in
			filteredAndSortedPairs[safe: index]
		}
		for item in items {
			modelContext.delete(item)
		}
	}
}

extension Array {
	fileprivate subscript(safe index: Index) -> Element? {
		indices.contains(index) ? self[index] : nil
	}
}

extension Color {
	static func accentColorFromName(_ name: String) -> Color {
		switch name {
		case "blue": return .blue
		case "purple": return .purple
		case "pink": return .pink
		case "red": return .red
		case "orange": return .orange
		case "yellow": return .yellow
		case "green": return .green
		case "teal": return .teal
		case "cyan": return .cyan
		default: return .indigo
		}
	}
}

#Preview {
	ContentView().modelContainer(SampleData.shared.modelContainer)
}

