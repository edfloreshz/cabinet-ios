//
//  DrawerView.swift
//  Cabinet
//
//  Created by Eduardo Flores on 09/02/26.
//

import SFSymbolsPicker
import SwiftData
import SwiftUI

struct DrawerDetailView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss
	@FocusState private var isNameFocused: Bool
	@AppStorage("accentColor") private var accent: ThemeColor = .indigo

	@Bindable var drawer: Drawer
	@State var isPresented = false

	var body: some View {
		Form {
			#if os(macOS)
				macOSForm
			#else
				iOSForm
			#endif
		}
		.navigationTitle("Drawer")
		#if os(iOS) || os(iPadOS) || os(visionOS)
			.navigationBarTitleDisplayMode(.inline)
		#endif
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

	fileprivate var iOSForm: some View {
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
					#if os(iOS) || os(iPadOS) || os(visionOS)
						.textInputAutocapitalization(.none)
					#endif
					.autocorrectionDisabled()
					.font(.system(size: 28, weight: .bold))
					.multilineTextAlignment(.center)
					.focused($isNameFocused)
			}
			.frame(maxWidth: .infinity)
			.listRowBackground(Color.clear)
		}
	}
	
	fileprivate var macOSForm: some View {
		VStack(spacing: 20) {
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
			.buttonStyle(.plain)
			.help("Change icon")
			
			VStack(alignment: .leading, spacing: 4) {
				Text("Name")
					.font(.system(size: 13, weight: .semibold))
					.foregroundStyle(.secondary)
				
				TextField("", text: $drawer.name)
					.textFieldStyle(.roundedBorder)
					.font(.system(size: 13))
					.focused($isNameFocused)
			}
			.frame(maxWidth: 280)
		}
		.padding(20)
		.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
	}

	private func saveDrawer() {
		modelContext.insert(drawer)
		try? modelContext.save()
	}
}

#Preview {
	DrawerDetailView(
		drawer: Drawer(name: "All", icon: "tag.fill")
	)
}
