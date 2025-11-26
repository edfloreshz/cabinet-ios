//
//  EmptyStateView.swift
//  Cabinet
//
//  Created by Eduardo Flores on 26/11/25.
//

import SwiftUI

struct EmptyStateView: View {
    var searching: Bool
    var onAdd: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: searching ? "magnifyingglass" : "archivebox")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text(searching ? "No matches" : "No items yet")
                .font(.title3)
                .bold()
            Text(searching ? "Try a different search term." : "Add your first key–value pair.")
                .foregroundStyle(.secondary)
            if !searching {
                Button(action: onAdd) {
                    Label("Add Pair", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut("n", modifiers: [.command])
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .multilineTextAlignment(.center)
        .padding()
    }
}

