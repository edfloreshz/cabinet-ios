//
//  KVRow.swift
//  Cabinet
//
//  Created by Eduardo Flores on 26/11/25.
//

import SwiftUI

struct ItemRowView: View {
	let pair: Pair
	var accentColor: Color
	var onRevealOrToggleHidden: () -> Void
	var onEdit: () -> Void
	var onToggleFavorite: () -> Void
	var onDelete: () -> Void
	
	var body: some View {
		HStack(alignment: .center, spacing: 12) {
			VStack(alignment: .leading, spacing: 2) {
				Text(pair.key)
					.font(.body.weight(.medium))
					.foregroundStyle(.primary)
				Text(pair.isHidden ? String(repeating: "•", count: pair.value.count) : pair.value)
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
			Button(action: { onRevealOrToggleHidden() }) {
				Image(systemName: pair.isHidden ? "eye.slash" : "eye")
					.foregroundStyle(.secondary)
			}
			.buttonStyle(.plain)
			Menu {
#if os(macOS)
				Button { onEdit() } label: {
					Label("Edit", systemImage: "pencil.circle.fill")
				}
				Button { onToggleFavorite() } label: {
					Label(pair.isFavorite ? "Unpin" : "Pin",
						  systemImage: pair.isFavorite ? "star.slash.fill" : "star.fill")
				}
				ShareLink(item: pair.value) {
					Label("Share", systemImage: "square.and.arrow.up.fill")
				}
#else
				ControlGroup {
					ShareLink(item: pair.value) {
						Label("Share", systemImage: "square.and.arrow.up.fill")
					}
					Button { onToggleFavorite() } label: {
						Label(pair.isFavorite ? "Unpin" : "Pin",
							  systemImage: pair.isFavorite ? "star.slash.fill" : "star.fill")
					}
					Button { onEdit() } label: {
						Label("Edit", systemImage: "pencil.circle.fill")
					}
				}
				Button(role: .destructive) { onDelete() } label: {
					Label("Delete", systemImage: "trash.fill")
				}
#endif
			} label: {
				Image(systemName: "ellipsis.circle")
					.imageScale(.large)
					.foregroundStyle(.primary)
					.accessibilityLabel("More for \(pair.key)")
#if os(iOS)
					.tint(accentColor)
#endif
			}
		}
		.contentShape(Rectangle())
		.swipeActions(edge: .leading, allowsFullSwipe: true) {
			Button(pair.isFavorite ? "Unpin" : "Pin", systemImage: pair.isFavorite ? "star.slash" : "star") {
				onToggleFavorite()
			}.tint(.yellow)
		}
		.swipeActions(edge: .trailing, allowsFullSwipe: true) {
			Button("Delete", systemImage: "trash", role: .destructive) {
				onDelete()
			}.tint(.red)
		}
	}
}

#Preview {
	ItemRowView(
		pair: Pair.sampleData[0],
		accentColor: .indigo,
		onRevealOrToggleHidden: { },
		onEdit: { },
		onToggleFavorite: { },
		onDelete: { }
	).padding()
}
