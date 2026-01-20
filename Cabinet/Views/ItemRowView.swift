//
//  KVRow.swift
//  Cabinet
//
//  Created by Eduardo Flores on 26/11/25.
//

import SwiftUI

struct ItemRowView: View {
    let pair: Pair
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
				ShareLink("Share", item: pair.value)
#else
                ControlGroup {
                    Button { onEdit() } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    Button { onToggleFavorite() } label: {
                        Label(pair.isFavorite ? "Unpin" : "Pin",
                              systemImage: pair.isFavorite ? "star.slash.fill" : "star.fill")
                    }
					ShareLink("Share", item: pair.value)
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
                    .tint(.indigo)
#endif
            }
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    ItemRowView(
        pair: Pair.sampleData[0],
        onRevealOrToggleHidden: { },
		onEdit: { },
        onToggleFavorite: { },
        onDelete: { }
	).padding()
}
