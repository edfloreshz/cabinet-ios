//
//  ItemRowView.swift
//  Cabinet
//
//  Created by Eduardo Flores on 26/11/25.
//

import SwiftData
import SwiftUI

struct ItemRowView: View {
	@Environment(\.modelContext) private var modelContext
	@AppStorage("accentColor") private var accent: ThemeColor = .indigo
	@State private var showDeleteConfirmation = false

	let pair: Pair
	
	@Binding var editingPair: Pair?
	
	var body: some View {
		HStack(alignment: .center, spacing: 12) {
			Image(systemName: pair.icon)
			VStack(alignment: .leading, spacing: 2) {
				Text(pair.key)
					.font(.body.weight(.medium))
					.foregroundStyle(.primary)
				Text(
					pair.isHidden
						? String(repeating: "•", count: pair.value.count)
						: pair.value
				)
				.font(.subheadline)
				.foregroundStyle(.secondary)
				.lineLimit(1)
				.truncationMode(.tail)
			}
			Spacer(minLength: 8)
			if pair.isFavorite {
				Image(systemName: "star.fill")
					.imageScale(.small)
					.foregroundStyle(.yellow)
					.accessibilityHidden(true)
			}
			Button(action: {
				pair.lastUsedDate = Date()
				ClipboardService.shared.copy(text: pair.value)
				ToastManager.shared.show("Copied", type: .info)
			}) {
				Image(
					systemName: "document.on.document"
				)
				.foregroundStyle(.secondary)
			}
			.buttonStyle(.plain)
			Button(action: { pair.isHidden.toggle() }) {
				Image(systemName: pair.isHidden ? "eye.slash" : "eye")
					.foregroundStyle(.secondary)
			}
			.buttonStyle(.plain)
		}
		.contextMenu {
			#if os(macOS)
				if !pair.isHidden {
					ShareLink(item: pair.value) {
						Label(
							"Share",
							systemImage: "square.and.arrow.up.fill"
						)
					}
				}
				Button {
					pair.isFavorite.toggle()
				} label: {
					Label(
						pair.isFavorite ? "Unpin" : "Pin",
						systemImage: pair.isFavorite
							? "star.slash.fill" : "star.fill"
					)
				}
				Button {
					editingPair = pair
				} label: {
					Label("Edit", systemImage: "pencil")
				}

			#else
				ControlGroup {
					if !pair.isHidden {
						ShareLink(item: pair.value) {
							Label(
								"Share",
								systemImage: "square.and.arrow.up.fill"
							)
						}
					}
					Button {
						pair.isFavorite.toggle()
					} label: {
						Label(
							pair.isFavorite ? "Unpin" : "Pin",
							systemImage: pair.isFavorite
								? "star.slash.fill" : "star.fill"
						)
					}
					Button {
						editingPair = pair
					} label: {
						Label("Edit", systemImage: "pencil")
					}
				}
			#endif
			Button(role: .destructive) {
				showDeleteConfirmation = true
			} label: {
				Label("Delete", systemImage: "trash.fill")
			}
		}
		.contentShape(Rectangle())
		.swipeActions(edge: .leading, allowsFullSwipe: true) {
			Button(
				pair.isFavorite ? "Unpin" : "Pin",
				systemImage: pair.isFavorite ? "star.slash" : "star"
			) {
				pair.isFavorite.toggle()
			}.tint(.yellow)

			ShareLink(item: pair.value) {
				Label("Share", systemImage: "square.and.arrow.up.fill")
			}
		}
		.swipeActions(edge: .trailing, allowsFullSwipe: true) {
			Button("Delete", systemImage: "trash") {
				showDeleteConfirmation = true
			}.tint(.red)

			Button("Edit", systemImage: "pencil") {
				editingPair = pair
			}.tint(.blue)
		}
		.confirmationDialog(
			"Delete ‘\(pair.key)’?",
			isPresented: $showDeleteConfirmation,
			titleVisibility: .visible
		) {
			Button("Delete", role: .destructive) {
				modelContext.delete(pair)
			}
			Button("Cancel", role: .cancel) {}
		} message: {
			Text("This action cannot be undone.")
		}
	}
}

#Preview {
	
}

struct AddContainer_Previews: PreviewProvider {
	@State static var editingPair: Pair?
	static var previews: some View {
		ItemRowView(pair: Pair(key: "Test", value: "Test"), editingPair: $editingPair).padding()
	}
}
