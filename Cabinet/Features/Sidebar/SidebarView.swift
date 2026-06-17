//
//  SidebarView.swift
//  Cabinet
//
//  Created by Eduardo Flores on 14/06/26.
//

import SwiftData
import SwiftUI

struct SidebarView: View {
	@AppStorage("accentColor") var accent: AppColor = .indigo
	@Namespace private var namespace
	@Binding var selectedDestination: Destination?
	
	@Query private var drawers: [Drawer]
	@State private var viewModel = SidebarViewModel()
	
	var body: some View {
		Group {
			if viewModel.isEditing {
				List(selection: $viewModel.selectedItems) {
					CategoriesListView()
					DrawersListView(viewModel: $viewModel)
				}
			} else {
				List(selection: $selectedDestination) {
					CategoriesListView()
					DrawersListView(viewModel: $viewModel)
				}
			}
		}
		.navigationTitle("Cabinet")
		.navigationBarTitleDisplayMode(.inline)
		.searchable(text: $viewModel.searchText, prompt: "Search")
		.navigationSplitViewColumnWidth(min: 310, ideal: 310)
		.environment(\.editMode, .constant(viewModel.isEditing ? .active : .inactive))
		.toolbar {
			ToolbarItem(placement: .topBarLeading) {
				Button("Settings", systemImage: "gearshape") {
					viewModel.showingSettings.toggle()
				}
			}
			
			if viewModel.isEditing {
				ToolbarItem(placement: .topBarTrailing) {
					Button(
						viewModel.selectedItems.count == drawers.count
						? "Deselect All" : "Select All"
					) {
						if viewModel.selectedItems.count == drawers.count {
							viewModel.selectedItems.removeAll()
						} else {
							viewModel.selectedItems = Set(drawers.map(\.id))
						}
					}
				}
				ToolbarSpacer(placement: .topBarTrailing)
			}
			
			if !drawers.isEmpty {
				ToolbarItem(placement: .topBarTrailing) {
					Button(
						viewModel.isEditing ? "Done" : "Edit",
						systemImage: viewModel.isEditing ? "checkmark" : "pencil"
					) {
						withAnimation {
							viewModel.isEditing.toggle()
							if !viewModel.isEditing {
								viewModel.selectedItems.removeAll()
							}
						}
					}
					.tint(viewModel.isEditing ? accent.color : nil)
				}
			}
		}
		.toolbar {
			DefaultToolbarItem(kind: .search, placement: .bottomBar)
			ToolbarSpacer(placement: .bottomBar)
			
			if viewModel.isEditing {
				DeleteToolbarItemView(viewModel: $viewModel)
			} else {
				ToolbarItem(placement: .bottomBar) {
					Button("New", systemImage: "plus") {
						viewModel.showingAdd.toggle()
					}
					.buttonStyle(.glassProminent)
					.tint(accent.color)
				}
				.matchedTransitionSource(id: "add-drawer-transition", in: namespace)
			}
		}
		.sheet(isPresented: $viewModel.showingSettings) {
			NavigationStack {
				SettingsView()
			}
			.tint(accent.color)
			.presentationDetents([.medium, .large])
		}
		.sheet(isPresented: $viewModel.showingAdd) {
			NavigationStack {
				DrawerFormView(drawer: Drawer(name: ""))
					.presentationSizing(.fitted)
			}
			.presentationDetents([.large])
			.interactiveDismissDisabled()
			.navigationTransition(.zoom(sourceID: "add-drawer-transition", in: namespace))
		}
	}
}

#Preview {
	@Previewable @State var viewModel = SidebarViewModel()
	@Previewable @State var selectedDestination: Destination? = .filter(.all)
	
	NavigationStack {
		SidebarView(selectedDestination: $selectedDestination)
			.modelContainer(PreviewData.shared.modelContainer)
	}
}
