//
//  CategoryPicker.swift
//  Cabinet
//
//  Created by Eduardo Flores on 11/02/26.
//

import SwiftUI

struct CategoryPicker: View {
	@Environment(\.dismiss) private var dismiss
	@AppStorage("accentColor") private var accent: ThemeColor = .indigo

	var options: [Category]
	@State private var selectedItems: Set<Category> = []
	var onChange: (Set<Category>) -> Void
	
    var body: some View {
		NavigationStack {
			Group {
				if options.isEmpty {
					Text("No categories available")
				} else {
					List(options, id: \.self) { item in
						HStack {
							Image(systemName: item.icon)
							Text(item.name)
							Spacer()
							if selectedItems.contains(item) {
								Image(systemName: "checkmark")
									.foregroundColor(.blue)
							}
						}
						.contentShape(Rectangle())
						.onTapGesture {
							if selectedItems.contains(item) {
								selectedItems.remove(item)
							} else {
								selectedItems.insert(item)
							}
							onChange(selectedItems)
						}
					}
				}
			}
			.navigationTitle("Categories")
			.navigationBarTitleDisplayMode(.inline)
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
				}
			}
		}
    }
}

#Preview {
	CategoryPicker(options: [
		Category(name: "Apple", icon: "apple.logo"),
		Category(name: "Xbox", icon: "xbox.logo"),
		Category(name: "Playstation", icon: "playstation.logo"),
		Category(name: "Shazam", icon: "shazam.logo.fill")
	], onChange: { _ in })
}
