//
//  PairFormView.swift
//  Cabinet
//
//  Created by Eduardo Flores on 26/11/25.
//

import PhotosUI
import SFSymbolsPicker
import SwiftData
import SwiftUI

enum ViewMode {
	case new, edit
}

enum FormField: Hashable {
	case title
	case content
	case notes
}

struct PairFormView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss
	@AppStorage("accentColor") private var accent: AppColor = .indigo
	
	@FocusState private var focusedField: FormField?
	
	@State private var selectedDrawers: Set<UUID> = []
	@State private var isPresented = false
	@State private var showDiscardAlert = false
	@State private var isAddDrawerPresented = false
	@State var imageSelection: PhotosPickerItem?
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
		Form {
			Section(header: Text("Content")) {
				HStack(spacing: 12) {
					TextField("Title", text: $formData.key)
						.font(.system(size: 20, weight: .bold))
						.multilineTextAlignment(.leading)
						.focused($focusedField, equals: .title) // Bound Focus
				}
				HStack {
					if formData.isHidden {
						SecureField("Your secret value", text: $formData.value)
							.focused($focusedField, equals: .content) // Bound Focus
					} else {
						TextField("Content", text: $formData.value)
							.focused($focusedField, equals: .content) // Bound Focus
					}
					
					Button(action: {
						let wasFocused = (focusedField == .content)
						formData.isHidden.toggle()
						if wasFocused {
							DispatchQueue.main.async {
								focusedField = .content
							}
						}
					}) {
						Image(systemName: formData.isHidden ? "eye.slash" : "eye")
							.foregroundStyle(.secondary)
					}
					.buttonStyle(.glass)
					.buttonBorderShape(.capsule)
				}
			}
			
			Section("Appearance") {
				if let imageData = formData.image, let uiImage = UIImage(data: imageData) {
					Image(uiImage: uiImage)
						.resizable()
						.scaledToFill()
						.frame(maxWidth: .infinity)
						.frame(height: 220)
						.clipped()
						.listRowInsets(EdgeInsets())
				}
				
				// MARK: - Banner Row
				HStack {
					Text("Header")
						.font(.body)
					
					Spacer()
					
					if formData.image != nil {
						Button(role: .cancel, action: {
							formData.image = nil
						}) {
							Image(systemName: "xmark")
						}
						.buttonStyle(FormCircleButtonStyle())
					}
					
					PhotosPicker(
						selection: $imageSelection,
						matching: .images,
						photoLibrary: .shared()
					) {
						Image(systemName: "photo")
					}
					.buttonStyle(FormCircleButtonStyle())
				}
				
				// MARK: - Icon Row
				HStack {
					Text("Icon")
						.font(.body)
					
					Spacer()
					
					if !formData.icon.isEmpty {
						Button(role: .cancel, action: {
							formData.icon = ""
						}) {
							Image(systemName: "xmark")
						}
						.buttonStyle(FormCircleButtonStyle())
					}
					
					Button(role: .confirm, action: {
						isPresented.toggle()
					}) {
						Image(systemName: formData.icon.isEmpty ? "magnifyingglass" : formData.icon)
					}
					.buttonStyle(FormCircleButtonStyle())
				}
			}
			
			Section(header: Text("Notes")) {
				TextField(
					"Type remarks or notes here",
					text: $formData.notes,
					axis: .vertical
				)
				.focused($focusedField, equals: .notes) // Bound Focus
				.lineLimit(3...10)
			}
			
			Section(header: HStack {
				Text("Drawers")
				Spacer()
				Button(role: .confirm, action: {
					isAddDrawerPresented.toggle()
				}) {
					Image(systemName: "plus")
				}
				.buttonStyle(FormCircleButtonStyle())
			}) {
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
			
			ToolbarItemGroup(placement: .keyboard) {
				if focusedField != nil {
					Spacer()
					
					HStack(spacing: 24) {
						Button(action: goToPreviousField) {
							Image(systemName: "chevron.up")
						}
						.disabled(focusedField == .title)
						
						Button(action: goToNextField) {
							Image(systemName: "chevron.down")
						}
						.disabled(focusedField == .notes)
						
						Button(action: { focusedField = nil }) {
							Image(systemName: "checkmark")
						}
					}
					.font(.system(size: 16, weight: .bold))
					.padding(.horizontal, 20)
					.frame(height: 50)
					.glassEffect()
					.padding(.bottom, 12)
				}
			}.sharedBackgroundVisibility(.hidden)
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
			Button("Keep editing", role: .cancel) {}
		} message: {
			Text("You have unsaved changes. Are you sure you want to discard them?")
		}
		.onChange(of: imageSelection) { _, newItem in
			Task { await saveImage(from: newItem) }
		}
		.onAppear {
			selectedDrawers = Set(pair.drawers)
			
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
				switch mode {
				case .edit:
					focusedField = .content
				case .new:
					focusedField = .title
				}
			}
		}
	}
	
	// MARK: - 4. Navigation Helpers
	private func goToNextField() {
		switch focusedField {
		case .title: focusedField = .content
		case .content:
			focusedField = nil
			DispatchQueue.main.async { focusedField = .notes }
		default: break
		}
	}
	
	private func goToPreviousField() {
		switch focusedField {
		case .notes:
			focusedField = nil
			DispatchQueue.main.async { focusedField = .content }
		case .content: focusedField = .title
		default: break
		}
	}
	
	// MARK: - Actions
	func saveImage(from item: PhotosPickerItem?) async {
		guard let item else { return }
		
		guard let data = try? await item.loadTransferable(type: Data.self),
			  let uiImage = UIImage(data: data),
			  let compressed = uiImage.jpegData(compressionQuality: 0.6) else { return }
		
		await MainActor.run {
			formData.image = compressed
			imageSelection = nil
		}
	}
	
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
		pair.image = formData.image
		
		if mode == .new {
			modelContext.insert(pair)
		}
		
		try? modelContext.save()
	}
}

struct FormCircleButtonStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.font(.system(size: 14, weight: .medium))
			.foregroundColor(.primary)
			.frame(width: 34, height: 34)
			.background(
				Circle()
					.stroke(Color(.systemGray4), lineWidth: 0.5)
					.background(Color(.systemBackground), in: .circle)
			)
			.opacity(configuration.isPressed ? 0.6 : 1.0)
	}
}

#Preview {
	Color.clear.sheet(isPresented: .constant(true)) {
		NavigationStack {
			PairFormView(mode: .new, pair: Pair.sampleData[0], onSave: {})
		}
		.presentationDetents([.large])
	}
	.modelContainer(PreviewData.shared.modelContainer)
}
