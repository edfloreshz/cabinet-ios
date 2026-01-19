//
//  AllPairsWidget.swift
//  Cabinet
//
//  Created by Eduardo Flores on 17/12/25.
//

import WidgetKit
import SwiftUI
import SwiftData

// MARK: - Timeline Provider for All Pairs
struct AllPairsProvider: TimelineProvider {
    typealias Entry = AllPairsEntry

    // Use the same App Group identifier used by RecentlyUsedWidget
    private let appGroupIdentifier = "group.dev.edfloreshz.Cabinet"

    // Shared ModelContainer to read SwiftData from the app group store
    private func makeSharedContainer() throws -> ModelContainer {
        let schema = Schema([Pair.self])
        let config: ModelConfiguration
        if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) {
            config = ModelConfiguration(schema: schema, url: url.appending(path: "SwiftData.store"))
        } else {
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
            print("AllPairsWidget: Failed to fetch from SwiftData: \(error)")
            return []
        }
    }

    func placeholder(in context: Context) -> AllPairsEntry {
        let pairs = loadAllPairs()
        return AllPairsEntry(date: Date(), pairs: pairs)
    }

    func getSnapshot(in context: Context, completion: @escaping (AllPairsEntry) -> Void) {
        let pairs = loadAllPairs()
        completion(AllPairsEntry(date: Date(), pairs: pairs))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<AllPairsEntry>) -> Void) {
        let pairs = loadAllPairs()
        let entries: [AllPairsEntry] = [AllPairsEntry(date: Date(), pairs: pairs)]
        // Modest refresh to pick up changes
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date().addingTimeInterval(900)
        completion(Timeline(entries: entries, policy: .after(refreshDate)))
    }
}

// MARK: - Entry
struct AllPairsEntry: TimelineEntry {
    let date: Date
    let pairs: [Pair]
}

// MARK: - Views (reusing RecentlyUsedWidget design patterns)
struct AllPairsWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: AllPairsProvider.Entry

    var body: some View {
        switch family {
        case .systemSmall:
            RecentlyUsedSmallWidget(entry: RecentlyUsedEntry(date: entry.date, recents: entry.pairs))
        case .systemMedium:
            RecentlyUsedMediumWidget(entry: RecentlyUsedEntry(date: entry.date, recents: entry.pairs))
        case .systemLarge:
            RecentlyUsedLargeWidget(entry: RecentlyUsedEntry(date: entry.date, recents: entry.pairs))
        default:
            RecentlyUsedSmallWidget(entry: RecentlyUsedEntry(date: entry.date, recents: entry.pairs))
        }
    }
}

// MARK: - Widget
struct AllPairsWidget: Widget {
    let kind: String = "AllPairsWidget"

    private static var supportedFamilies: [WidgetFamily] {
        if #available(iOS 15, *) {
            return [.systemLarge, .systemExtraLarge]
        } else {
            return [.systemLarge]
        }
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AllPairsProvider()) { entry in
            AllPairsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("All Pairs")
        .description("Browse all pairs saved in your library.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
    }
}

// MARK: - Preview
#Preview(as: .systemMedium) {
    AllPairsWidget()
} timeline: {
    AllPairsEntry(date: .now, pairs: Pair.recentlyUsedOne)
    AllPairsEntry(date: .now, pairs: Pair.recentlyUsedTwo)
    AllPairsEntry(date: .now, pairs: Pair.recentlyUsedThree)
}
