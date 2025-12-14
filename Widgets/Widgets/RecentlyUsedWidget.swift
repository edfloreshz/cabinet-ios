//
//  Widgets.swift
//  Widgets
//
//  Created by Eduardo Flores on 13/12/25.
//

import WidgetKit
import SwiftUI

struct RecentlyUsedProvider: TimelineProvider {
    public typealias Entry = RecentlyUsedEntry
    
    func placeholder(in context: Context) -> RecentlyUsedEntry {
        return RecentlyUsedEntry(date: Date(), recents: Pair.recentlyUsedOne)
    }

    func getSnapshot(in context: Context, completion: @escaping (RecentlyUsedEntry) -> Void) {
        let entry = RecentlyUsedEntry(date: Date(), recents: Pair.recentlyUsedOne)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<RecentlyUsedEntry>) -> Void) {
        var entries: [RecentlyUsedEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = RecentlyUsedEntry(date: entryDate, recents: Pair.recentlyUsedOne)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct RecentlyUsedWidgetEntryView : View {
    @Environment(\.widgetFamily) var family
    var entry: RecentlyUsedProvider.Entry

    var body: some View {
        switch family {
        case .systemSmall:
            RecentlyUsedSmallWidget(entry: entry)
        case .systemMedium:
            RecentlyUsedMediumWidget(entry: entry)
        case .systemLarge:
            RecentlyUsedLargeWidget(entry: entry)
        default:
            RecentlyUsedSmallWidget(entry: entry)
        }
    }
}

struct RecentlyUsedWidget: Widget {
    let kind: String = "Widgets"
    
    private static var supportedFamilies: [WidgetFamily] {
        if #available(iOS 15, *) {
            return [.systemLarge, .systemExtraLarge]
        } else {
            return [.systemLarge]
        }
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: RecentlyUsedProvider()) { entry in
            RecentlyUsedWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Recently Used")
        .description("See recently used items.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
    }
}

#Preview(as: .systemMedium) {
    RecentlyUsedWidget()
} timeline: {
    RecentlyUsedEntry(date: .now, recents: Pair.recentlyUsedOne)
    RecentlyUsedEntry(date: .now, recents: Pair.recentlyUsedTwo)
    RecentlyUsedEntry(date: .now, recents: Pair.recentlyUsedThree)
}
