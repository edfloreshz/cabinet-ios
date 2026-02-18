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

struct ItemDetailView: View {
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
		Group {
			#if os(macOS)
				macOSForm
			#else
				iOSForm
			#endif
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

	fileprivate var iOSForm: some View {
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
	}

	fileprivate var macOSForm: some View {
		Form {
			TextField("Title", text: $pair.key)
				.focused($isNameFocused)
			
			HStack(spacing: 8) {
				if pair.isHidden {
					SecureField(
						"Value",
						text: $pair.value,
						prompt: Text("Your secret value")
					)
					.focused($isContentFocused)
				} else {
					TextField(
						"Value",
						text: $pair.value,
						prompt: Text("Your value")
					)
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
					.frame(width: 16, height: 16)
				}
				.buttonStyle(.plain)
				.help(pair.isHidden ? "Show value" : "Hide value")
			}
			
			
			HStack {
				Text("Icon")
				Spacer()
				Button(action: { isPresented.toggle() }) {
					Label("Select", systemImage: pair.icon)
				}
				.help("Change icon")
			}
			
			VStack(alignment: .leading) {
				Text("Notes")
				
				TextEditor(text: $pair.notes)
					.frame(height: 80)
					.scrollContentBackground(.hidden)
					.overlay(
						RoundedRectangle(cornerRadius: 10)
							.stroke(
								Color.secondary.opacity(0.25),
								lineWidth: 1
							)
					)
			}
			
			VStack(alignment: .leading, spacing: 8) {
				Text("Drawers")
					.font(.system(size: 13, weight: .semibold))
					.foregroundStyle(.secondary)
				
				if drawers.isEmpty {
					Text("No drawers available")
						.font(.system(size: 13))
						.foregroundStyle(.tertiary)
						.frame(maxWidth: .infinity, alignment: .center)
						.padding(.vertical, 20)
				} else {
					VStack(spacing: 0) {
						ForEach(drawers, id: \.self) { drawer in
							HStack(spacing: 8) {
								Image(systemName: drawer.icon)
									.foregroundStyle(.secondary)
									.frame(width: 16)
								
								Text(drawer.name)
									.font(.system(size: 13))
								
								Spacer()
								
								if selectedDrawers.contains(drawer.id) {
									Image(systemName: "checkmark")
										.foregroundStyle(accent.color)
										.font(
											.system(
												size: 12,
												weight: .semibold
											)
										)
								}
							}
							.padding(.horizontal, 8)
							.padding(.vertical, 6)
							.contentShape(Rectangle())
							.background(
								selectedDrawers.contains(drawer.id)
								? accent.color.opacity(0.1)
								: Color.clear
							)
							.onTapGesture {
								if selectedDrawers.contains(drawer.id) {
									selectedDrawers.remove(drawer.id)
								} else {
									selectedDrawers.insert(drawer.id)
								}
							}
							
							if drawer != drawers.last {
								Divider()
									.padding(.leading, 32)
							}
						}
					}
					.background(.background.opacity(0.5))
					.clipShape(RoundedRectangle(cornerRadius: 6))
					.overlay(
						RoundedRectangle(cornerRadius: 6)
							.stroke(
								Color.secondary.opacity(0.2),
								lineWidth: 1
							)
					)
				}
			}
		}
		.formStyle(.grouped)
	}

	private func savePair() {
		pair.drawers = Array(selectedDrawers)
		modelContext.insert(pair)
		try? modelContext.save()
	}
}

#Preview {
	ItemDetailView(mode: .new, pair: Pair.sampleData[0], onSave: {})
}
