//
//  PairGridLayoutView.swift
//  Cabinet
//
//  Created by Eduardo Flores on 12/06/26.
//

import SwiftData
import SwiftUI

struct PairGridLayoutView: View {
	@Environment(\.modelContext) private var modelContext
	@State private var pendingDeletionPair: Pair?
	
	let pairs: [Pair]
	let isEditing: Bool
	@Binding var selectedItems: Set<UUID>
	@Binding var editingPair: Pair?
	
	private let columns = [
		GridItem(.flexible(), spacing: 20, alignment: .top),
		GridItem(.flexible(), spacing: 20, alignment: .top)
	]
	
	var body: some View {
		ScrollView {
			LazyVGrid(columns: columns, spacing: 20) {
				ForEach(pairs) { pair in
					PairGridCardView(
						pair: pair,
						isEditing: isEditing,
						isSelected: selectedItems.contains(pair.id),
						onTap: {
							handleTap(for: pair)
						},
						onEdit: {
							editingPair = pair
						},
						onDeleteRequest: {
							pendingDeletionPair = pair
						}
					)
				}
			}
			.padding(16)
		}
		.confirmationDialog(
			deletionTitle,
			isPresented: deletionDialogIsPresented,
			titleVisibility: .visible
		) {
			Button("Delete", role: .destructive) {
				guard let pair = pendingDeletionPair else { return }
				modelContext.delete(pair)
				pendingDeletionPair = nil
			}
			Button("Cancel", role: .cancel) {
				pendingDeletionPair = nil
			}
		} message: {
			Text("This action cannot be undone.")
		}
	}
	
	private var deletionDialogIsPresented: Binding<Bool> {
		Binding(
			get: { pendingDeletionPair != nil },
			set: { isPresented in
				if !isPresented {
					pendingDeletionPair = nil
				}
			}
		)
	}
	
	private var deletionTitle: String {
		guard let pair = pendingDeletionPair else {
			return "Delete item?"
		}
		
		return "Delete ‘\(pair.key)’?"
	}
	
	private func handleTap(for pair: Pair) {
		if isEditing {
			if selectedItems.contains(pair.id) {
				selectedItems.remove(pair.id)
			} else {
				selectedItems.insert(pair.id)
			}
		} else {
			editingPair = pair
		}
	}
}

#Preview {
	@Previewable @State var selectedItems: Set<UUID> = []
	@Previewable @State var editingPair: Pair? = nil
	
	NavigationStack {
		PairGridLayoutView(
			pairs: Pair.sampleData,
			isEditing: false,
			selectedItems: $selectedItems,
			editingPair: $editingPair
		)
	}
	.modelContainer(PreviewData.shared.modelContainer)
}
