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
	@State var isUnlocked: Bool
    @State private var showingAdd = false
    @State private var editingPair: Pair? = nil
    @State private var showCopyToast = false
    @State private var searchText: String = ""
	@Query private var pairs: [Pair]
    private let logger = Logger(subsystem: "dev.edfloreshz.Cabinet", category: "Utilities")

    var body: some View {
        NavigationStack {
            if isUnlocked {
                Group {
                    if filteredAndSortedPairs.isEmpty {
                        EmptyView(searching: !searchText.isEmpty) {
                            showingAdd = true
                        }
                    } else {
						List {
							ForEach(filteredAndSortedPairs) { pair in
                                ItemRowView(
                                    pair: pair,
                                    onRevealOrToggleHidden: { pair.isHidden ? revealValue(pair: pair) : pair.isHidden.toggle() },
                                    onEdit: { editingPair = pair },
                                    onToggleFavorite: { pair.isFavorite.toggle() },
                                    onDelete: { modelContext.delete(pair) }
                                )
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
				#if os(iOS)
				.navigationBarTitleDisplayMode(.inline)
				#endif
				.toolbar {
                    #if os(macOS)
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            showingAdd = true
                        } label: {
                            Label("Add", systemImage: "plus")
                        }
						.tint(.indigo)
                        .keyboardShortcut(.init("n"), modifiers: [.command])
                    }
                    #else
					ToolbarItem(placement: .topBarTrailing) {
						EditButton()
					}
					
					DefaultToolbarItem(kind: .search, placement: .bottomBar)
					ToolbarSpacer(placement: .bottomBar)
					ToolbarItem(placement: .bottomBar) {
						Button("New", systemImage: "plus", role: .confirm) {
							showingAdd = true
						}
						.tint(.indigo)
						.keyboardShortcut(.init("n"), modifiers: [.command])
					}
                    #endif
                }
				.searchable(text: $searchText, prompt: "Search keys or values")
                .sheet(isPresented: $showingAdd) {
                    NavigationStack {
                        EditItemView(title: "New Item", pair: Pair(key: "", value: "")) { newPair in
                            modelContext.insert(newPair)
                        }
                    }
                    .tint(.indigo)
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
                    .tint(.indigo)
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
    
    private func revealValue(pair: Pair) {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "We need to unlock your data.") { success, authenticationError in
                if success {
                    pair.isHidden.toggle()
                } else {
                    logger.error("We were unable to unlock the device.")
                }
            }
        } else {
            logger.error("There are no biometrics available.")
        }
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
    ContentView(isUnlocked: true).modelContainer(SampleData.shared.modelContainer)
}

