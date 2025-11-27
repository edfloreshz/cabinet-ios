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
        Form {
            Section("Name") {
                TextField("Name", text: $key)
                    .textInputAutocapitalization(.none)
                    .autocorrectionDisabled()
            }
            Section("Value") {
                TextEditor(text: $value)
                    .frame(minHeight: 120)
                    .font(.body)
                    .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
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
    }
}
