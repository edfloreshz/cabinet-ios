//
//  ItemView.swift
//  Cabinet
//
//  Created by Eduardo Flores on 14/12/25.
//


import SwiftUI
import WidgetKit
import AppIntents

struct ItemView : View {
    var pair: Pair
    
    var body: some View {
        Button(intent: CopyToClipboardIntent(value: pair.value)) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(alignment: .center, spacing: 2) {
                        Text(pair.key)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                        if pair.isFavorite {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(.yellow)
                                .accessibilityHidden(true)
                        }
                        Spacer()
                    }
                    Text(pair.isHidden ? String(repeating: "•", count: pair.value.count) : pair.value)
                        .font(.caption)
                        .lineLimit(1)
                }
                Image(systemName: "doc.on.doc").font(.system(size: 12))
                
            }
            .padding(8)
            .background(.fill)
            .clipShape(.containerRelative)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ItemView(pair: Pair.recentlyUsedOne.first!)
}
