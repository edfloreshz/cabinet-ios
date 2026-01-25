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
	@State var isUnlocked: Bool
	@State private var showingAdd = false
	@State private var showingSettings = false
	@State private var editingPair: Pair? = nil
	@State private var showCopyToast = false
	@State private var searchText: String = ""
	@Query private var pairs: [Pair]
	@State private var selectedItems: Set<UUID> = []
	@AppStorage("accentColor") private var accentColorName: String = "indigo"
	private let logger = Logger(subsystem: "dev.edfloreshz.Cabinet", category: "Utilities")
	
	private var accentColor: Color {
		Color.accentColorFromName(accentColorName)
	}
	
	var body: some View {
		NavigationStack {
			if isUnlocked {
				Group {
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
									onRevealOrToggleHidden: { pair.isHidden ? revealValue(pair: pair) : pair.isHidden.toggle() },
									onEdit: { editingPair = pair },
									onToggleFavorite: { pair.isFavorite.toggle() },
									onDelete: { modelContext.delete(pair) }
								)
								.onTapGesture {
									if !isEditing {
										copyToPasteboard(pair.value)
										showCopiedToast()
									}
								}
							}
						}
						.environment(\.editMode, .constant(isEditing ? .active : .inactive))
					}
				}
				.navigationTitle("Cabinet")
#if os(iOS)
				.navigationBarTitleDisplayMode(.inline)
#endif
				.searchable(text: $searchText, prompt: "Search keys or values")
				.toolbar {
#if os(macOS)
					ToolbarItem(placement: .primaryAction) {
						Button("Settings", systemImage: "gear") {
							showingSettings = true
						}
						.tint(accentColor)
					}
					
					ToolbarItem(placement: .principal) {
						Button("New", systemImage: "plus", role: .confirm) {
							showingAdd = true
						}
						.tint(accentColor)
						.keyboardShortcut(.init("n"), modifiers: [.command])
					}
#else
					ToolbarItem(placement: .topBarLeading) {
						Button("Settings", systemImage: "gear") {
							showingSettings = true
						}
						.tint(accentColor)
					}
					
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
						}
							   .tint(accentColor)
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
				.sheet(isPresented: $showingSettings) {
					NavigationStack {
						SettingsView(accentColorName: $accentColorName)
					}
					.tint(accentColor)
#if os(iOS) || os(visionOS)
					.presentationDetents([.medium, .large])
#endif
				}
				.sheet(isPresented: $showingAdd) {
					NavigationStack {
						EditItemView(title: "New Item", pair: Pair(key: "", value: "")) { newPair in
							modelContext.insert(newPair)
						}
					}
					.tint(accentColor)
#if os(iOS) || os(visionOS)
					.presentationDetents([.medium, .large])
#endif
				}
				.sheet(item: $editingPair) { pair in
					NavigationStack {
						EditItemView(title: "Edit Item", pair: pair) {
							editedPair in
							pair.key = editedPair.key
							pair.value = editedPair.value
							pair.isHidden = editedPair.isHidden
						}
					}
					.tint(accentColor)
#if os(iOS) || os(visionOS)
					.presentationDetents([.medium, .large])
#endif
				}
				.overlay(alignment: .bottom) {
					if showCopyToast {
						Label("Copied", systemImage: "doc.on.doc")
							.padding(.horizontal, 14)
							.padding(.vertical, 10)
							.background(.thinMaterial, in: Capsule())
							.padding(.bottom, 20)
							.transition(.move(edge: .bottom).combined(with: .opacity))
					}
				}
			} else {
				LockedView(authenticate: authenticate, accentColor: accentColor)
			}
		}.onAppear(perform: authenticate)
	}
	
	private func revealValue(pair: Pair) {
		let context = LAContext()
		var error: NSError?
		
		if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
			context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "We need to unlock your data.") { success, authenticationError in
				if success {
					pair.isHidden.toggle()
				} else {
					logger.error("We were unable to unlock the device.")
				}
			}
		} else {
			logger.error("There are no biometrics available.")
		}
	}
	
	private func authenticate() {
		let context = LAContext()
		var error: NSError?
		
		if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
			context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "We need to unlock your data.") { success, authenticationError in
				if success {
					isUnlocked = true
				} else {
					logger.error("We were unable to unlock the device.")
				}
			}
		} else {
			logger.error("There are no biometrics available.")
		}
	}
	
	private func copyToPasteboard(_ string: String) {
#if canImport(UIKit)
		UIPasteboard.general.string = string
#elseif canImport(AppKit)
		let pb = NSPasteboard.general
		pb.clearContents()
		pb.setString(string, forType: .string)
#endif
	}
	
	private func showCopiedToast() {
		withAnimation(.spring(duration: 0.25)) {
			showCopyToast = true
		}
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
			withAnimation(.easeOut(duration: 0.2)) {
				showCopyToast = false
			}
		}
	}
	
	private var filteredAndSortedPairs: [Pair] {
		let base = pairs
		let filtered: [Pair]
		if searchText.isEmpty {
			filtered = base
		} else {
			let term = searchText.lowercased()
			filtered = base.filter {
				$0.key.lowercased().contains(term) || $0.value.lowercased().contains(term)
			}
		}
		return filtered.sorted { lhs, rhs in
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
	ContentView(isUnlocked: true).modelContainer(SampleData.shared.modelContainer)
}

