//
//  PairListLayoutView.swift
//  Cabinet
//
//  Created by Eduardo Flores on 12/06/26.
//

import SwiftData
import SwiftUI

struct PairListLayoutView: View {
	let pairs: [Pair]
	let isEditing: Bool
	@Binding var selectedItems: Set<UUID>
	@Binding var editingPair: Pair?

	var body: some View {
		List(selection: $selectedItems) {
			ForEach(pairs) { pair in
				PairListItemView(pair: pair, editingPair: $editingPair)
					.onTapGesture {
						guard !isEditing else { return }
						editingPair = pair
					}
			}
		}
	}
}

#Preview {
	@Previewable @State var selectedItems: Set<UUID> = []
	@Previewable @State var editingPair: Pair? = nil

	NavigationStack {
		PairListLayoutView(
			pairs: Pair.sampleData,
			isEditing: false,
			selectedItems: $selectedItems,
			editingPair: $editingPair
		)
	}
	.modelContainer(PreviewData.shared.modelContainer)
}
