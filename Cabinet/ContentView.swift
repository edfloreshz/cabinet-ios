//
//  ContentView.swift
//  Cabinet
//
//  Created by Eduardo Flores on 26/11/25.
//

import SwiftUI
import Observation

struct ContentView: View {
    @State private var model = ItemStoreViewModel()
    @State private var showingAdd = false
    @State private var editingPair: Pair? = nil
    @State private var showCopyToast = false

    var body: some View {
        NavigationStack {
            Group {
                if model.filteredPairs.isEmpty {
                    EmptyView(searching: !model.searchText.isEmpty) {
                        showingAdd = true
                    }
                } else {
                    List {
                        ForEach(model.filteredPairs) { pair in
                            HStack(spacing: 8) {
                                ItemRowView(pair: pair)
                                Menu {
                                    Button { editingPair = pair } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    Button { model.toggleFavorite(pair) } label: {
                                        Label(pair.isFavorite ? "Unpin" : "Pin", systemImage: pair.isFavorite ? "star.slash" : "star")
                                    }
                                    Button(role: .destructive) { model.delete(pair) } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                } label: {
                                    Image(systemName: "ellipsis.circle")
                                        .imageScale(.large)
                                        .foregroundStyle(.primary)
                                        .tint(Color.orange)
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
                                    model.toggleFavorite(pair)
                                } label: {
                                    Label(pair.isFavorite ? "Unpin" : "Pin", systemImage: pair.isFavorite ? "star.slash" : "star")
                                }
                                .tint(.yellow)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    model.delete(pair)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                        .onDelete(perform: model.delete)
                    }
                    .animation(.default, value: model.filteredPairs)
                }
            }
            .navigationTitle("Cabinet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
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
            }
            .searchable(text: $model.searchText, placement: .automatic, prompt: "Search keys or values")
            .sheet(isPresented: $showingAdd) {
                NavigationStack {
                    EditItemView(title: "New Item", key: "", value: "") { key, value in
                        model.addPair(key: key, value: value)
                    }
                }
                .presentationDetents([.medium, .large])
            }
            .sheet(item: $editingPair) { pair in
                NavigationStack {
                    EditItemView(title: "Edit Item", key: pair.key, value: pair.value) { key, value in
                        model.updatePair(pair, key: key, value: value)
                    }
                }
                .presentationDetents([.medium, .large])
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
}

#Preview {
    ContentView()
}
