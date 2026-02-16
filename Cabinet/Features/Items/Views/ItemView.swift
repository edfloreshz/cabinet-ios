//
//  ItemView.swift
//  Cabinet
//
//  Created by Eduardo Flores on 26/11/25.
//

import SFSymbolsPicker
import SwiftData
import SwiftUI

enum ViewMode {
	case new, edit
}

struct ItemView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss
	@AppStorage("accentColor") private var accent: ThemeColor = .indigo
	@FocusState private var isContentFocused: Bool
	@FocusState private var isNameFocused: Bool
	@State private var selectedDrawers: Set<UUID> = []
	@State var isPresented = false
	@Query private var drawers: [Drawer]
	
	let mode: ViewMode
	@State var pair: Pair
	let onSave: () -> Void

	var body: some View {
		Form {
			Section {
				VStack(spacing: 12) {
					Button(action: {
						isPresented.toggle()
					}) {
						Image(systemName: pair.icon)
							.resizable()
							.scaledToFit()
							.frame(width: 40, height: 40)
							.padding(15)
							.glassEffect()
							.foregroundStyle(.brown)
					}

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

			Section(header: Text("Drawers")) {
				if drawers.isEmpty {
					Text("No drawers available")
				} else {
					List(drawers, id: \.self) { drawer in
						HStack {
							Image(systemName: drawer.icon)
							Text(drawer.name)
							Spacer()
							if selectedDrawers.contains(drawer.id) {
								Image(systemName: "checkmark")
									.foregroundColor(accent.color)
							}
						}
						.contentShape(Rectangle())
						.onTapGesture {
							if selectedDrawers.contains(drawer.id) {
								selectedDrawers.remove(drawer.id)
							} else {
								selectedDrawers.insert(drawer.id)
							}
						}
					}
				}
			}
		}
		.navigationTitle("Item")
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
					savePair()
					onSave()
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
		.sheet(
			isPresented: $isPresented,
			content: {
				SymbolsPicker(
					selection: $pair.icon,
					title: "Pick a symbol",
					autoDismiss: true
				)
			}
		)
		.onAppear {
			selectedDrawers = Set(pair.drawers)

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

	private func savePair() {
		pair.drawers = Array(selectedDrawers)
		modelContext.insert(pair)
		try? modelContext.save()
	}
}

#Preview {
	ItemView(mode: .new, pair: Pair.sampleData[0], onSave: {})
}
