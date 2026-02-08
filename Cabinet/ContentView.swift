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
#if os(iOS)
	@Environment(\.editMode) private var editMode
#endif
	private let logger = Logger(subsystem: "dev.edfloreshz.Cabinet", category: "Utilities")
	@AppStorage("accentColor") private var accentColorName: String = "indigo"

	@State private var isEditing = false
	@State private var showingAdd = false
	@State private var showingSettings = false
	@State private var editingPair: Pair? = nil
	@State private var searchText: String = ""
	@State private var selectedItems: Set<UUID> = []
	@State private var selectedCategory: String = "All"
	@Query private var pairs: [Pair]

	private var accentColor: Color {
		Color.accentColorFromName(accentColorName)
	}
	
	var body: some View {
		NavigationStack {
			Group {
				Filters(accentColor: accentColor) { category in
					selectedCategory = category
				}
				
				if filteredAndSortedPairs.isEmpty {
					EmptyView(searching: !searchText.isEmpty, accentColor: accentColor) {
						showingAdd = true
					}
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
								if !isEditing {
									if (pair.isHidden) {
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
					}
#if os(iOS)
					.environment(\.editMode, .constant(isEditing ? .active : .inactive))
#endif
				}
			}
			.toolbarBackgroundVisibility(.hidden, for: .automatic)
			.navigationTitle("Cabinet")
#if os(iOS)
			.navigationBarTitleDisplayMode(.inline)
#endif
			.searchable(text: $searchText, prompt: "Search keys or values")
			.toolbar {
#if os(macOS)
				ToolbarItem(placement: .automatic) {
					Button("New", systemImage: "plus", role: .confirm) {
						showingAdd = true
					}
					.tint(accentColor)
					.keyboardShortcut(.init("n"), modifiers: [.command])
				}
				ToolbarSpacer(placement: .automatic)
				
				DefaultToolbarItem(kind: .search, placement: .automatic)
				
				ToolbarSpacer(placement: .automatic)
				ToolbarItem(placement: .secondaryAction) {
					Button("Settings", systemImage: "gear") {
						showingSettings = true
					}
					.tint(accentColor)
				}
#else
				ToolbarItem(placement: .topBarLeading) {
					Button("Settings", systemImage: "gear") {
						showingSettings = true
					}
					.tint(accentColor)
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
				
				DefaultToolbarItem(kind: .search, placement: .bottomBar)
				
				if isEditing {
					ToolbarSpacer(placement: .bottomBar)
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
				} else if !filteredAndSortedPairs.isEmpty {
					ToolbarSpacer(placement: .bottomBar)
					ToolbarItem(placement: .bottomBar) {
						Button("New", systemImage: "plus") {
							showingAdd = true
						}.tint(accentColor)
					}
				}
#endif
			}
		#if os(iOS) || os(visionOS)
			.background(Color(uiColor: .systemGroupedBackground))
		#elseif os(macOS)
			.background(Color(nsColor: .windowBackgroundColor))
		#endif
			.sheet(isPresented: $showingSettings) {
				NavigationStack {
					SettingsView(accentColorName: $accentColorName)
#if os(macOS)
						.padding()
#endif
				}
				.tint(accentColor)
#if os(iOS) || os(visionOS)
				.presentationDetents([.medium, .large])
#endif
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
#if os(iOS) || os(visionOS)
				.presentationDetents([.medium, .large])
#endif
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
#if os(iOS) || os(visionOS)
				.presentationDetents([.medium, .large])
#endif
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

