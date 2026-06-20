//
//  PairListItemView.swift
//  Cabinet
//
//  Created by Eduardo Flores on 26/11/25.
//

import SwiftData
import SwiftUI

struct PairListItemView: View {
	@Environment(\.modelContext) private var modelContext
	@State private var showDeleteConfirmation = false
	@State private var isRevealed = false
	
	let pair: Pair
	
	@Binding var editingPair: Pair?
	
	var body: some View {
		let secret = resolvedSecret

		HStack(alignment: .center, spacing: 12) {
			if let icon = pair.icon {
				Image(systemName: icon)
			}
			VStack(alignment: .leading, spacing: 2) {
				Text(pair.key)
					.font(.body.weight(.medium))
					.foregroundStyle(.primary)
				Text(displayValue(using: secret))
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
				copySecret(using: secret)
			}) {
				Image(
					systemName: "document.on.document"
				)
				.foregroundStyle(.secondary)
			}
			.buttonStyle(.plain)
			if pair.isHidden {
				Button(action: { isRevealed.toggle() }) {
					Image(systemName: isRevealed ? "eye" : "eye.slash")
						.foregroundStyle(.secondary)
				}
				.buttonStyle(.plain)
			}
		}
		.contextMenu {
			ControlGroup {
				if case .success(let value) = secret, !pair.isHidden {
					ShareLink(item: value) {
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
			
			if case .success(let value) = secret, !pair.isHidden {
				ShareLink(item: value) {
					Label("Share", systemImage: "square.and.arrow.up.fill")
				}
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
				deletePair()
			}
			Button("Cancel", role: .cancel) {}
		} message: {
			Text("This action cannot be undone.")
		}
	}

	private var resolvedSecret: Result<String, PairSecretAccessError> {
		Result { try pair.secretValue() }
			.mapError { _ in .decryptionFailed }
	}

	private var shouldMaskSecret: Bool {
		pair.isHidden && !isRevealed
	}

	private func displayValue(using secret: Result<String, PairSecretAccessError>) -> String {
		switch secret {
		case .success(let value):
			if shouldMaskSecret {
				return String(repeating: "•", count: max(value.count, 8))
			}
			return value
		case .failure:
			return "Secret unavailable"
		}
	}

	private func copySecret(using secret: Result<String, PairSecretAccessError>) {
		switch secret {
		case .success(let value):
			pair.lastUsedDate = Date()
			ClipboardService.shared.copy(text: value)
			ToastManager.shared.show("Copied", type: .info)
		case .failure(let error):
			ToastManager.shared.show(
				error.localizedDescription,
				type: .error,
				duration: 2.2
			)
		}
	}

	private func deletePair() {
		do {
			modelContext.delete(pair)
			try modelContext.save()
		} catch {
			ToastManager.shared.show(
				"Couldn't delete this item.",
				type: .error,
				duration: 2.2
			)
		}
	}
}

#Preview {
	@Previewable @State var editingPair: Pair? = nil
	PairListItemView(
		pair: Pair.sampleData[0],
		editingPair: $editingPair
	)
	.padding()
}
