//
//  EditItemView.swift
//  Cabinet
//
//  Created by Eduardo Flores on 26/11/25.
//

import SwiftUI

struct EditItemView: View {
	@Environment(\.dismiss) private var dismiss
	
	let title: String
	@State var pair: Pair
	var onSave: (Pair) -> Void
	var onRevealOrToggleHidden: (Pair) -> Void
	
	var body: some View {
		Form {
			Section("Name") {
				TextField("Name", text: $pair.key)
					.textInputAutocapitalization(.none)
					.autocorrectionDisabled()
			}
			Section("Content") {
				HStack(spacing: 8) {
					ZStack(alignment: .trailing) {
						if pair.isHidden {
							SecureField("Content", text: $pair.value)
						} else {
							TextField("Content", text: $pair.value)
						}
						Button(action: {
							pair.isHidden
							? AuthenticationService.authenticate { result in
								switch result {
								case .success:
									pair.isHidden.toggle()
								case .failure(let error):
									ToastManager.shared.show(error.message, type: .error)
								}
							} : pair.isHidden.toggle()
						}) {
							Image(systemName: pair.isHidden ? "eye.slash" : "eye")
								.foregroundStyle(.secondary)
						}
						.buttonStyle(.plain)
					}
				}
			}
		}
		.navigationTitle(title)
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarItem(placement: .cancellationAction) {
				Button("Cancel") { dismiss() }
			}
			ToolbarItem(placement: .confirmationAction) {
				Button("Save") {
					onSave(pair)
					dismiss()
				}
				.disabled(pair.key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
			}
		}
	}
}

#Preview {
	EditItemView(title: "Edit", pair: Pair.sampleData[0], onSave: { _ in }, onRevealOrToggleHidden: { _ in })
}
