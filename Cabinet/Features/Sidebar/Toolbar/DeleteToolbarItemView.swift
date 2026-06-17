//
//  SettingsToolbarItemVIew.swift
//  Cabinet
//
//  Created by Eduardo Flores on 16/06/26.
//

import SwiftUI
import SwiftData

struct DeleteToolbarItemView: ToolbarContent {
	@Environment(\.modelContext) private var modelContext
	@AppStorage("accentColor") var accent: AppColor = .indigo
	@Binding var viewModel: SidebarViewModel
	
	@Query var drawers: [Drawer]
	
    var body: some ToolbarContent {
		ToolbarItem(placement: .bottomBar) {
			Button("Delete", systemImage: "trash", role: .destructive) {
				viewModel.showDrawerDeleteConfirmation.toggle()
			}
			.tint(.red)
			.disabled(viewModel.selectedItems.isEmpty)
			.confirmationDialog(
				"Delete selected items?",
				isPresented: $viewModel.showDrawerDeleteConfirmation,
				titleVisibility: .visible
			) {
				Button("Delete", role: .destructive) {
					deleteSelectedItems()
				}
			} message: {
				Text("This action cannot be undone. Items in this drawer will not be deleted, but will no longer be categorized.")
			}
		}
    }
	
	// MARK: - Actions
	
	private func deleteSelectedItems() {
		for id in viewModel.selectedItems {
			if let item = drawers.first(where: { $0.id == id }) {
				modelContext.delete(item)
			}
		}
		withAnimation {
			viewModel.selectedItems.removeAll()
			viewModel.isEditing = false
		}
	}
}

#Preview {
	@Previewable @State var viewModel = SidebarViewModel()
	
	NavigationStack {
		Text("Settings")
			.toolbar {
				DeleteToolbarItemView(viewModel: $viewModel)
			}
	}
}
