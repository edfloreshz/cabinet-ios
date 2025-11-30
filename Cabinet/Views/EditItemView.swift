//
//  EditKVView.swift
//  Cabinet
//
//  Created by Eduardo Flores on 26/11/25.
//

import SwiftUI

struct EditItemView: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    @State var key: String
    @State var value: String
    var onSave: (String, String) -> Void

    var body: some View {
#if os(macOS)
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("Name")
                    .frame(width: 80, alignment: .trailing)
                    .foregroundStyle(.secondary)
                TextField("Name", text: $key)
                    .textFieldStyle(.roundedBorder)
                    .frame(minWidth: 260)
            }
            VStack(alignment: .leading, spacing: 6) {
                Text("Value")
                    .frame(width: 80, alignment: .trailing)
                    .foregroundStyle(.secondary)
                TextEditor(text: $value)
                    .font(.body)
                    .padding(6)
                    .frame(minHeight: 160)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .strokeBorder(.quaternary)
                    )
            }
            Spacer(minLength: 0)
        }
        .padding()
        .frame(minWidth: 420)
        .navigationTitle(title)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.escape, modifiers: [])
            }
            ToolbarItem(placement: .primaryAction) {
                Button("Save") {
                    onSave(key, value)
                    dismiss()
                }
                .keyboardShortcut(.return, modifiers: [.command])
                .keyboardShortcut(.defaultAction)
                .disabled(key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
#else
        Form {
            Section("Name") {
                TextField("Name", text: $key)
#if os(iOS) || os(visionOS)
                    .textInputAutocapitalization(.none)
                    .autocorrectionDisabled()
#endif
            }
            Section("Value") {
                TextEditor(text: $value)
                    .frame(minHeight: 120)
                    .font(.body)
                    .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle(title)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    onSave(key, value)
                    dismiss()
                }
                .disabled(key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
#endif
    }
}
