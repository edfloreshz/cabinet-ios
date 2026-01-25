//
//  EditKVView.swift
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
#if os(macOS)
		VStack(alignment: .leading, spacing: 12) {
			HStack(alignment: .firstTextBaseline) {
				Text("Name")
					.frame(width: 80, alignment: .trailing)
					.foregroundStyle(.secondary)
				TextField("Name", text: $pair.key)
					.textFieldStyle(.roundedBorder)
					.frame(minWidth: 260)
			}
			HStack(alignment: .firstTextBaseline, spacing: 8) {
				Text("Value")
					.frame(width: 80, alignment: .trailing)
					.foregroundStyle(.secondary)
				ZStack(alignment: .trailing) {
					if pair.isHidden {
						SecureField("Value", text: $pair.value)
							.textFieldStyle(.roundedBorder)
					} else {
						TextField("Value", text: $pair.value)
							.textFieldStyle(.roundedBorder)
					}
					Button(action: { onRevealOrToggleHidden(pair) }) {
						Image(systemName: pair.isHidden ? "eye.slash" : "eye")
							.foregroundStyle(.secondary)
					}
					.buttonStyle(.plain)
					.padding(.trailing, 6)
				}
				.frame(minWidth: 260)
			}
			Spacer(minLength: 0)
		}
		.padding()
		.frame(minWidth: 420)
		.navigationTitle(title)
		.toolbar {
			ToolbarItem(placement: .cancellationAction) {
				Button("Cancel") { dismiss() }
					.keyboardShortcut(.escape, modifiers: [])
			}
			ToolbarItem(placement: .primaryAction) {
				Button("Save") {
					onSave(pair)
					dismiss()
				}
				.keyboardShortcut(.return, modifiers: [.command])
				.keyboardShortcut(.defaultAction)
				.disabled(pair.key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
			}
		}
#else
		Form {
			Section("Name") {
				TextField("Name", text: $pair.key)
#if os(iOS) || os(visionOS)
					.textInputAutocapitalization(.none)
					.autocorrectionDisabled()
#endif
			}
			Section("Value") {
				HStack(spacing: 8) {
					ZStack(alignment: .trailing) {
						if pair.isHidden {
							SecureField("Value", text: $pair.value)
						} else {
							TextField("Value", text: $pair.value)
						}
						Button(action: { onRevealOrToggleHidden(pair) }) {
							Image(systemName: pair.isHidden ? "eye.slash" : "eye")
								.foregroundStyle(.secondary)
						}
						.buttonStyle(.plain)
					}
				}
			}
		}
		.navigationTitle(title)
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
#endif
	}
}

#Preview {
	EditItemView(title: "Edit", pair: Pair.sampleData[0], onSave: { _ in }, onRevealOrToggleHidden: { _ in })
}
