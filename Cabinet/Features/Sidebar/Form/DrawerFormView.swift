//
//  DrawerFormView.swift
//  Cabinet
//
//  Created by Eduardo Flores on 09/02/26.
//

import SFSymbolsPicker
import SwiftData
import SwiftUI

struct DrawerFormView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss
	@AppStorage("accentColor") private var accent: AppColor = .indigo
	@FocusState private var isNameFocused: Bool
	@State private var isPresented = false
	@State private var showDiscardAlert = false
	@State private var formData: DrawerFormData
	
	let drawer: Drawer
	
	init(drawer: Drawer) {
		self.drawer = drawer
		self._formData = State(initialValue: DrawerFormData(from: drawer))
	}
	
	private var isDirty: Bool {
		formData != DrawerFormData(from: drawer)
	}
	
	var body: some View {
		Form {
			Section("Name") {
				HStack(spacing: 12) {
					TextField("Name", text: $formData.name)
						.font(.system(size: 20, weight: .bold))
						.multilineTextAlignment(.leading)
						.focused($isNameFocused)
					Button(role: .confirm, action: {
						isPresented.toggle()
					}) {
						Image(systemName: formData.icon)
							.resizable()
							.scaledToFit()
							.frame(width: 20, height: 20)
							.padding(6)
							.foregroundStyle(.foreground)
					}
					.buttonBorderShape(.circle)
					.buttonStyle(.glass)
				}
			}
			Section("Purpose") {
				TextEditor(text: $formData.purpose)
					.frame(height: 80)
			}
		}
		.formStyle(.grouped)
		.presentationSizing(.fitted)
		.navigationTitle("Drawer")
			.navigationBarTitleDisplayMode(.inline)
			.scrollDismissesKeyboard(.interactively)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Cancel", systemImage: "xmark") {
						handleCancel()
					}
				}
				ToolbarItem(placement: .confirmationAction) {
					Button("Save", systemImage: "checkmark") {
						saveDrawer()
					}
					.tint(accent.color)
					.buttonStyle(.glassProminent)
					.disabled(
						formData.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
					)
				}
			}
			.sheet(isPresented: $isPresented) {
				SymbolsPicker(
					selection: $formData.icon,
					title: "Pick a symbol",
					autoDismiss: true
				)
			}
			.interactiveDismissDisabled(isDirty)
			.confirmationDialog(
				"Discard changes?",
				isPresented: $showDiscardAlert,
				titleVisibility: .visible
			) {
				Button("Discard changes", role: .destructive) {
					dismiss()
				}
				Button("Keep editing", role: .cancel) {}
			} message: {
				Text("You have unsaved changes. Are you sure you want to discard them?")
			}
			.onAppear {
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
					isNameFocused = true
				}
			}
	}

	// MARK: - Actions
	
	private func handleCancel() {
		if isDirty {
			showDiscardAlert = true
		} else {
			dismiss()
		}
	}
	
	private func saveDrawer() {
		drawer.name = formData.name.trimmingCharacters(in: .whitespacesAndNewlines)
		drawer.icon = formData.icon
		drawer.purpose = formData.purpose

		do {
			if drawer.modelContext == nil {
				modelContext.insert(drawer)
			}

			try modelContext.save()
			dismiss()
		} catch {
			ToastManager.shared.show(
				"Couldn't save this drawer.",
				type: .error,
				duration: 2.2
			)
		}
	}
}

#Preview {
	NavigationStack {
		DrawerFormView(drawer: Drawer(name: "All", icon: "archivebox"))
	}
}
