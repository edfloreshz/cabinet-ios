//
//  ItemView.swift
//  Cabinet
//
//  Created by Eduardo Flores on 26/11/25.
//

import SwiftData
import SwiftUI

enum ViewMode {
	case new, edit
}

struct ItemView: View {
	@Environment(\.dismiss) private var dismiss
	@AppStorage("accentColor") private var accent: ThemeColor = .indigo
	@FocusState private var isContentFocused: Bool
	@FocusState private var isNameFocused: Bool
	@State private var selectedCategories: Set<Category> = []
	@Query private var categories: [Category]

	let mode: ViewMode
	@Bindable var pair: Pair

	var body: some View {
		Form {
			Section {
				VStack(spacing: 12) {
					Image(systemName: "shippingbox.fill")
						.resizable()
						.scaledToFit()
						.frame(width: 40, height: 40)
						.padding(15)
						.glassEffect()
						.foregroundStyle(.brown)

					TextField("Title", text: $pair.key)
						.font(.system(size: 28, weight: .bold))
						.multilineTextAlignment(.center)
						.focused($isNameFocused)
				}
				.frame(maxWidth: .infinity)
				.listRowBackground(Color.clear)
			}

			Section(header: Text("Value")) {
				HStack {
					if pair.isHidden {
						SecureField("Your secret value", text: $pair.value)
							.focused($isContentFocused)
					} else {
						TextField("Your value", text: $pair.value)
							.focused($isContentFocused)
					}

					Button(action: {
						pair.isHidden
							? AuthenticationService.authenticate { result in
								switch result {
								case .success:
									pair.isHidden.toggle()
								case .failure(let error):
									ToastManager.shared.show(
										error.message,
										type: .error
									)
								}
							} : pair.isHidden.toggle()
					}) {
						Image(
							systemName: pair.isHidden ? "eye.slash" : "eye"
						)
						.foregroundStyle(.secondary)
					}
					.buttonStyle(.plain)
				}
			}

			Section(header: Text("Notes")) {
				TextField(
					"Type remarks or notes here",
					text: $pair.notes,
					axis: .vertical
				)
				.lineLimit(3...5)
			}

			Section(header: Text("Categories")) {
				if categories.isEmpty {
					Text("No categories available")
				} else {
					List(categories, id: \.self) { item in
						HStack {
							Image(systemName: item.icon)
							Text(item.name)
							Spacer()
							if pair.categories.contains(item) {
								Image(systemName: "checkmark")
									.foregroundColor(accent.color)
							}
						}
						.contentShape(Rectangle())
						.onTapGesture {
							if selectedCategories.contains(item) {
								selectedCategories.remove(item)
							} else {
								selectedCategories.insert(item)
							}
							pair.categories = Array(selectedCategories)
						}
					}
				}
			}
		}
		.navigationTitle("Item")
		.navigationBarTitleDisplayMode(.inline)
		.scrollDismissesKeyboard(.interactively)
		.toolbar {
			ToolbarItem(placement: .cancellationAction) {
				Button("Cancel", systemImage: "xmark") { dismiss() }
			}
			ToolbarItem(placement: .confirmationAction) {
				Button("Save", systemImage: "checkmark") {
					dismiss()
				}
				.tint(accent.color)
				.buttonStyle(.glassProminent)
				.disabled(
					pair.key.trimmingCharacters(in: .whitespacesAndNewlines)
						.isEmpty
				)
			}
		}
		.onAppear {
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
				switch mode {
				case .edit:
					isContentFocused = true
				case .new:
					isNameFocused = true
				}
			}
		}
	}
}

#Preview {
	ItemView(mode: .new, pair: Pair.sampleData[0])
}
