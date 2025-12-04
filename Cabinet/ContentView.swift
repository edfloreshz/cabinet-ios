//
//  ContentView.swift
//  Cabinet
//
//  Created by Eduardo Flores on 26/11/25.
//

import SwiftData
import SwiftUI
import LocalAuthentication
import os

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var isUnlocked = false
    @State private var showingAdd = false
    @State private var editingPair: Pair? = nil
    @State private var showCopyToast = false
    @State private var searchText: String = ""
    @Query private var pairs: [Pair]
    private let logger = Logger(subsystem: "dev.edfloreshz.Cabinet", category: "Utilities")

    var body: some View {
        let filtered = filteredAndSortedPairs
        NavigationStack {
            if isUnlocked {
                Group {
                    if filtered.isEmpty {
                        EmptyView(searching: !searchText.isEmpty) {
                            showingAdd = true
                        }
                    } else {
                        List {
                            ForEach(filtered) { pair in
                                HStack(spacing: 8) {
                                    ItemRowView(pair: pair)
                                    Menu {
                                        Button {
                                            editingPair = pair
                                        } label: {
                                            Label("Edit", systemImage: "pencil").tint(.black)
                                        }
                                        Button {
                                            pair.isFavorite.toggle()
                                        } label: {
                                            Label(pair.isFavorite ? "Unpin" : "Pin",
                                                  systemImage: pair.isFavorite ? "star.slash" : "star")
                                            .tint(.black)
                                        }
                                        ShareLink("Share", item: pair.value).tint(.black)
                                        Button(role: .destructive) {
                                            modelContext.delete(pair)
                                        } label: {
                                            Label("Delete", systemImage: "trash").tint(.red)
                                        }
                                    } label: {
                                        Image(systemName: "ellipsis.circle")
                                            .imageScale(.large)
                                            .foregroundStyle(.primary)
                                            .accessibilityLabel("More for \(pair.key)")
                                    }
                                    .buttonStyle(.borderless)
                                }
                                .onTapGesture {
                                    copyToPasteboard(pair.value)
                                    showCopiedToast()
                                }
                                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                    Button {
                                        pair.isFavorite.toggle()
                                    } label: {
                                        Label(
                                            pair.isFavorite ? "Unpin" : "Pin",
                                            systemImage: pair.isFavorite ? "star.slash" : "star")
                                    }
                                    .tint(.yellow)
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        modelContext.delete(pair)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }.tint(.red)
                                }
                            }
                            .onDelete(perform: delete(at:))
                        }
                        .animation(.default, value: pairs)
                    }
                }
                .navigationTitle("Cabinet")
                .toolbar {
                    #if os(macOS)
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            showingAdd = true
                        } label: {
                            Label("Add", systemImage: "plus")
                        }
                        .keyboardShortcut(.init("n"), modifiers: [.command])
                    }
                    #else
                    ToolbarItem(placement: .topBarLeading) {
                        EditButton()
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showingAdd = true
                        } label: {
                            Label("Add", systemImage: "plus")
                        }
                        .keyboardShortcut(.init("n"), modifiers: [.command])
                    }
                    #endif
                }
                .searchable(text: $searchText, placement: .automatic, prompt: "Search keys or values")
                .sheet(isPresented: $showingAdd) {
                    NavigationStack {
                        EditItemView(title: "New Item", pair: Pair(key: "", value: "")) { newPair in
                            modelContext.insert(newPair)
                        }
                    }
                    #if os(iOS) || os(visionOS)
                    .presentationDetents([.medium, .large])
                    #endif
                }
                .sheet(item: $editingPair) { pair in
                    NavigationStack {
                        EditItemView(title: "Edit Item", pair: pair) {
                            editedPair in
                            pair.key = editedPair.key
                            pair.value = editedPair.value
                            pair.isHidden = editedPair.isHidden
                        }
                    }
                    #if os(iOS) || os(visionOS)
                    .presentationDetents([.medium, .large])
                    #endif
                }
                .overlay(alignment: .bottom) {
                    if showCopyToast {
                        Label("Copied", systemImage: "doc.on.doc")
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(.thinMaterial, in: Capsule())
                            .padding(.bottom, 20)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            } else {
                LockedView(authenticate: authenticate)
            }
        }.onAppear(perform: authenticate)
    }
    
    private func authenticate() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "We need to unlock your data.") { success, authenticationError in
                if success {
                    isUnlocked = true
                } else {
                    logger.error("We were unable to unlock the device.")
                }
            }
        } else {
            logger.error("There are no biometrics available.")
        }
    }

    private func copyToPasteboard(_ string: String) {
        #if canImport(UIKit)
            UIPasteboard.general.string = string
        #elseif canImport(AppKit)
            let pb = NSPasteboard.general
            pb.clearContents()
            pb.setString(string, forType: .string)
        #endif
    }

    private func showCopiedToast() {
        withAnimation(.spring(duration: 0.25)) {
            showCopyToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeOut(duration: 0.2)) {
                showCopyToast = false
            }
        }
    }

    private var filteredAndSortedPairs: [Pair] {
        let base = pairs
        let filtered: [Pair]
        if searchText.isEmpty {
            filtered = base
        } else {
            let term = searchText.lowercased()
            filtered = base.filter {
                $0.key.lowercased().contains(term) || $0.value.lowercased().contains(term)
            }
        }
        return filtered.sorted { lhs, rhs in
            if lhs.isFavorite != rhs.isFavorite { return lhs.isFavorite && !rhs.isFavorite }
            return lhs.key.localizedCaseInsensitiveCompare(rhs.key) == .orderedAscending
        }
    }

    private func delete(at offsets: IndexSet) {
        let items = offsets.compactMap { index in
            filteredAndSortedPairs[safe: index]
        }
        for item in items {
            modelContext.delete(item)
        }
    }
}

extension Array {
    fileprivate subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    ContentView().modelContainer(SampleData.shared.modelContainer)
}

