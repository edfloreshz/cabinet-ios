//
//  EditCategoryView.swift
//  Cabinet
//
//  Created by Eduardo Flores on 09/02/26.
//

import SwiftUI
import SFSymbolsPicker

struct EditCategoryView: View {
	@Environment(\.dismiss) private var dismiss
	
	@State var category: Category
	@State var isPresented = false
	
	var onSave: (Category) -> Void
	
    var body: some View {
		Form {
			Section("Name") {
				TextField("Name", text: $category.name)
					.textInputAutocapitalization(.none)
					.autocorrectionDisabled()
				
			}
			Section("Icon") {
				Button("Select icon", systemImage: category.icon) {
					isPresented.toggle()
				}
			}
		}
		.navigationTitle("Edit Category")
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarItem(placement: .cancellationAction) {
				Button("Cancel") { dismiss() }
			}
			ToolbarItem(placement: .confirmationAction) {
				Button("Save") {
					onSave(category)
					dismiss()
				}
				.disabled(category.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
			}
		}
		.sheet(isPresented: $isPresented, content: {
			SymbolsPicker(selection: $category.icon, title: "Pick a symbol", autoDismiss: true)
		})
    }
}

#Preview {
	EditCategoryView(category: Category(name: "All", icon: "square.grid.2x2"), onSave: { _ in })
}
