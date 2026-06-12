//
//  PairFormView.swift
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

struct PairFormView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss
	@AppStorage("accentColor") private var accent: AppColor = .indigo
	@FocusState private var isContentFocused: Bool
	@FocusState private var isNameFocused: Bool
	@State private var selectedDrawers: Set<UUID> = []
	@State private var isPresented = false
	@State private var showDiscardAlert = false
	@State private var isAddDrawerPresented = false
	@Query private var drawers: [Drawer]
	
	let mode: ViewMode
	let pair: Pair
	let onSave: () -> Void
	
	@State private var formData: PairFormData
	
	init(mode: ViewMode, pair: Pair, onSave: @escaping () -> Void) {
		self.mode = mode
		self.pair = pair
		self.onSave = onSave
		self._formData = State(initialValue: PairFormData(from: pair))
	}
	
	private var isDirty: Bool {
		formData != PairFormData(from: pair)
	}
	
	var body: some View {
		Group {
#if os(macOS)
			macOSForm
#else
			iOSForm
#endif
		}
		.navigationTitle("Item")
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
					savePair()
					onSave()
					dismiss()
				}
				.tint(accent.color)
				.buttonStyle(.glassProminent)
				.disabled(
					formData.key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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
		.sheet(isPresented: $isAddDrawerPresented) {
			NavigationStack {
				DrawerFormView(drawer: Drawer(name: ""))
					.presentationSizing(.fitted)
			}
			.presentationDetents([.large])
			.interactiveDismissDisabled()
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
	
	// MARK: - Forms
	
	private var iOSForm: some View {
		Form {
			Section(header: Text("Content")) {
				HStack(spacing: 12) {
					TextField("Title", text: $formData.key)
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
				HStack {
					if formData.isHidden {
						SecureField("Your secret value", text: $formData.value)
							.focused($isContentFocused)
					} else {
						TextField("Content", text: $formData.value)
							.focused($isContentFocused)
					}
					
					Button(action: { formData.isHidden.toggle() }) {
						Image(systemName: formData.isHidden ? "eye.slash" : "eye")
							.foregroundStyle(.secondary)
					}
					.buttonStyle(.plain)
				}
			}
			
			Section(header: Text("Notes")) {
				TextField(
					"Type remarks or notes here",
					text: $formData.notes,
					axis: .vertical
				)
				.lineLimit(3...5)
			}
			
			Section(header: Text("Drawers")) {
				Button(role: .confirm, action: {
					isAddDrawerPresented.toggle()
				}) {
					Label {
						Text("Add drawer")
					} icon: {
						Image(systemName: "plus")
							.foregroundStyle(accent.color)
					}.tint(accent.color)
				}
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
	
	private var macOSForm: some View {
		Form {
			TextField("Title", text: $formData.key)
				.focused($isNameFocused)
			
			HStack(spacing: 8) {
				if formData.isHidden {
					SecureField(
						"Value",
						text: $formData.value,
						prompt: Text("Your secret value")
					)
					.focused($isContentFocused)
				} else {
					TextField(
						"Value",
						text: $formData.value,
						prompt: Text("Content")
					)
					.focused($isContentFocused)
				}
				
				Button(action: { formData.isHidden.toggle() }) {
					Image(systemName: formData.isHidden ? "eye.slash" : "eye")
						.foregroundStyle(.secondary)
						.frame(width: 16, height: 16)
				}
				.buttonStyle(.plain)
				.help(formData.isHidden ? "Show value" : "Hide value")
			}
			
			HStack {
				Text("Icon")
				Spacer()
				Button(action: { isPresented.toggle() }) {
					Label("Select", systemImage: formData.icon)
				}
				.help("Change icon")
			}
			
			VStack(alignment: .leading) {
				Text("Notes")
				TextEditor(text: $formData.notes)
					.frame(height: 80)
					.scrollContentBackground(.hidden)
					.overlay(
						RoundedRectangle(cornerRadius: 10)
							.stroke(Color.secondary.opacity(0.25), lineWidth: 1)
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
										.font(.system(size: 12, weight: .semibold))
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
							.stroke(Color.secondary.opacity(0.2), lineWidth: 1)
					)
				}
			}
		}
		.formStyle(.grouped)
	}
	
	// MARK: - Actions
	
	private func handleCancel() {
		if isDirty {
			showDiscardAlert = true
		} else {
			dismiss()
		}
	}
	
	private func savePair() {
		pair.key = formData.key
		pair.value = formData.value
		pair.notes = formData.notes
		pair.icon = formData.icon
		pair.isHidden = formData.isHidden
		pair.drawers = Array(selectedDrawers)
		
		if mode == .new {
			modelContext.insert(pair)
		}
		
		try? modelContext.save()
	}
}

#Preview {
	Color.clear.sheet(isPresented: .constant(true)) {
		NavigationStack {
			PairFormView(mode: .new, pair: Pair.sampleData[0], onSave: {})
		}
		.presentationDetents([.large])
	}
}
