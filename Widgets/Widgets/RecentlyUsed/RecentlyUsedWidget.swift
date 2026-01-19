//
//  Widgets.swift
//  Widgets
//
//  Created by Eduardo Flores on 13/12/25.
//

import WidgetKit
import SwiftUI
import SwiftData

struct RecentlyUsedProvider: TimelineProvider {
    typealias Entry = RecentlyUsedEntry

    // Update this to your real App Group identifier shared between the app and the widget extension
    private let appGroupIdentifier = "group.dev.edfloreshz.Cabinet"

    // Create a ModelContainer pointing at the shared App Group store so the widget can read SwiftData
    private func makeSharedContainer() throws -> ModelContainer {
        let schema = Schema([Pair.self])
        let config: ModelConfiguration
        if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) {
            config = ModelConfiguration(schema: schema, url: url.appending(path: "SwiftData.store"))
        } else {
            // Fallback to default in-memory if the app group is unavailable
            config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        }
        return try ModelContainer(for: schema, configurations: [config])
    }

    private func loadAllPairs() -> [Pair] {
        do {
            let container = try makeSharedContainer()
            let context = ModelContext(container)
            let descriptor = FetchDescriptor<Pair>()
            return try context.fetch(descriptor)
        } catch {
            // If anything fails (e.g., model not available in widget), return empty and we'll fallback to sample data
            print("Failed to fetch from SwiftData")
            return []
        }
    }

    func placeholder(in context: Context) -> RecentlyUsedEntry {
        return RecentlyUsedEntry(date: Date(), recents: Pair.sampleData)
    }

    func getSnapshot(in context: Context, completion: @escaping (RecentlyUsedEntry) -> Void) {
        let recents = loadAllPairs()
        let entry = RecentlyUsedEntry(date: Date(), recents: recents)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<RecentlyUsedEntry>) -> Void) {
        let recents = loadAllPairs()
        let entries: [RecentlyUsedEntry] = [RecentlyUsedEntry(date: Date(), recents: recents)]
        let refreshDate = Calendar.current.date(byAdding: .second, value: 1, to: Date())!
        let timeline = Timeline(entries: entries, policy: .after(refreshDate))
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

