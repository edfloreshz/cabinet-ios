//
//  CategoryView.swift
//  Cabinet
//
//  Created by Eduardo Flores on 09/02/26.
//

import SFSymbolsPicker
import SwiftData
import SwiftUI

struct CategoryView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss
	@FocusState private var isNameFocused: Bool
	@AppStorage("accentColor") private var accent: ThemeColor = .indigo

	@Bindable var category: Category
	@State var isPresented = false

	var body: some View {
		Form {
			Section {
				VStack(spacing: 12) {
					Button(action: {
						isPresented.toggle()
					}) {
						Image(systemName: category.icon)
							.resizable()
							.scaledToFit()
							.frame(width: 40, height: 40)
							.padding(20)
							.glassEffect()
							.foregroundStyle(.foreground)
					}

					TextField("Name", text: $category.name)
						.textInputAutocapitalization(.none)
						.autocorrectionDisabled()
						.font(.system(size: 28, weight: .bold))
						.multilineTextAlignment(.center)
						.focused($isNameFocused)
				}
				.frame(maxWidth: .infinity)
				.listRowBackground(Color.clear)
			}
		}
		.navigationTitle("Category")
		.navigationBarTitleDisplayMode(.inline)
		.scrollDismissesKeyboard(.interactively)
		.toolbar {
			ToolbarItem(placement: .cancellationAction) {
				Button("Cancel", systemImage: "xmark") { dismiss() }
			}
			ToolbarItem(placement: .confirmationAction) {
				Button("Save", systemImage: "checkmark") {
					saveCategory()
					dismiss()
				}
				.tint(accent.color)
				.buttonStyle(.glassProminent)
				.disabled(
					category.name.trimmingCharacters(
						in: .whitespacesAndNewlines
					).isEmpty
				)
			}
		}
		.sheet(
			isPresented: $isPresented,
			content: {
				SymbolsPicker(
					selection: $category.icon,
					title: "Pick a symbol",
					autoDismiss: true
				)
			}
		)
		.onAppear {
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
				isNameFocused = true
			}
		}
	}

	private func saveCategory() {
		// Check if the category is already managed by SwiftData
		if category.modelContext == nil {
			modelContext.insert(category)
		}

		// Optional: Explicitly save (though SwiftData usually autosaves on the next main loop)
		try? modelContext.save()
	}
}

#Preview {
	CategoryView(
		category: Category(name: "All", icon: "tag.fill")
	)
}
