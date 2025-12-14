//
//  RecentlyUsedMediumWidget.swift
//  Cabinet
//
//  Created by Eduardo Flores on 14/12/25.
//

import WidgetKit
import SwiftUI

struct RecentlyUsedMediumWidget : View {
    var entry: RecentlyUsedProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Recently Used")
                .font(.headline)
                .lineLimit(1)
                .foregroundStyle(.primary)
            
            if entry.recents.isEmpty {
                Text("No recent items")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(entry.recents.prefix(4), id: \.key) { pair in
                        ItemView(pair: pair)
                    }
                }
            }
        }
        .containerBackground(.fill, for: .widget)
    }
}

#Preview {
    RecentlyUsedMediumWidget(entry: RecentlyUsedEntry(date: .now, recents: Pair.recentlyUsedOne))
}
