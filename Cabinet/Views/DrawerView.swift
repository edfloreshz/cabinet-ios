//
//  DrawerView.swift
//  Cabinet
//
//  Created by Eduardo Flores on 09/02/26.
//

import SFSymbolsPicker
import SwiftData
import SwiftUI

struct DrawerView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss
	@FocusState private var isNameFocused: Bool
	@AppStorage("accentColor") private var accent: ThemeColor = .indigo

	@Bindable var drawer: Drawer
	@State var isPresented = false

	var body: some View {
		Form {
			Section {
				VStack(spacing: 12) {
					Button(action: {
						isPresented.toggle()
					}) {
						Image(systemName: drawer.icon)
							.resizable()
							.scaledToFit()
							.frame(width: 40, height: 40)
							.padding(20)
							.glassEffect()
							.foregroundStyle(.foreground)
					}

					TextField("Name", text: $drawer.name)
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
		.navigationTitle("Drawer")
		.navigationBarTitleDisplayMode(.inline)
		.scrollDismissesKeyboard(.interactively)
		.toolbar {
			ToolbarItem(placement: .cancellationAction) {
				Button("Cancel", systemImage: "xmark") { dismiss() }
			}
			ToolbarItem(placement: .confirmationAction) {
				Button("Save", systemImage: "checkmark") {
					saveDrawer()
					dismiss()
				}
				.tint(accent.color)
				.buttonStyle(.glassProminent)
				.disabled(
					drawer.name.trimmingCharacters(
						in: .whitespacesAndNewlines
					).isEmpty
				)
			}
		}
		.sheet(
			isPresented: $isPresented,
			content: {
				SymbolsPicker(
					selection: $drawer.icon,
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

	private func saveDrawer() {
		modelContext.insert(drawer)
		try? modelContext.save()
	}
}

#Preview {
	DrawerView(
		drawer: Drawer(name: "All", icon: "tag.fill")
	)
}
