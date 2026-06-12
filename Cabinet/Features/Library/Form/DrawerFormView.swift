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
		Group {
#if os(macOS)
			macOSForm
#else
			iOSForm
#endif
		}
		.navigationTitle("Drawer")
#if !os(macOS)
		.navigationBarTitleDisplayMode(.inline)
#endif
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
					dismiss()
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
			Button("Keep editing", role: .cancel) { }
		} message: {
			Text("You have unsaved changes. Are you sure you want to discard them?")
		}
		.onAppear {
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
				isNameFocused = true
			}
		}
	}
	
	// MARK: - Forms
	
	private var iOSForm: some View {
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
	}
	
	private var macOSForm: some View {
		Form {
			LabeledContent("Name") {
				TextField("", text: $formData.name)
					.focused($isNameFocused)
			}
			
			LabeledContent("Icon") {
				Button(role: .confirm, action: {
					isPresented.toggle()
				}) {
					Image(systemName: formData.icon)
						.scaledToFit()
						.padding(2)
						.foregroundStyle(.foreground)
				}
				.buttonStyle(.glass)
				.help("Change icon")
			}
			
			LabeledContent("Purpose") {
				TextEditor(text: $formData.purpose)
					.padding(5)
					.font(.system(size: 12))
					.lineSpacing(2)
					.frame(height: 80)
					.scrollContentBackground(.hidden)
					.overlay(
						RoundedRectangle(cornerRadius: 6)
							.stroke(Color.secondary.opacity(0.25), lineWidth: 1)
					)
			}
		}
		.frame(minWidth: 400)
		.padding()
		.formStyle(.automatic)
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
		drawer.name = formData.name
		drawer.icon = formData.icon
		drawer.purpose = formData.purpose
		modelContext.insert(drawer)
		try? modelContext.save()
	}
}

#Preview {
	NavigationStack {
		DrawerFormView(drawer: Drawer(name: "All", icon: "archivebox"))
	}
}
