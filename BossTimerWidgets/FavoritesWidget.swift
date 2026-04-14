//
//  FavoritesWidget.swift
//  BossTimerWidgets
//

import SwiftUI
import WidgetKit

struct FavoriteBossesWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "com.era.bossTimer.favorites", provider: FavoritesProvider()) { entry in
            FavoritesWidgetView(entry: entry)
        }
        .configurationDisplayName("Favorites")
        .description("Starred bosses and their timers.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular])
    }
}

private struct FavoritesProvider: TimelineProvider {
    func placeholder(in context: Context) -> FavEntry {
        FavEntry(date: Date(), lines: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (FavEntry) -> Void) {
        completion(makeEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FavEntry>) -> Void) {
        let entry = makeEntry()
        completion(Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(15 * 60))))
    }

    private func makeEntry() -> FavEntry {
        let snap = WidgetSnapshotLoader.load()
        let favs = snap.bosses.filter(\.isFavorite).sorted { $0.sortKey < $1.sortKey }
        return FavEntry(date: snap.updatedAt, lines: Array(favs.prefix(8)))
    }
}

private struct FavEntry: TimelineEntry {
    let date: Date
    let lines: [WidgetBossLine]
}

private struct FavoritesWidgetView: View {
    @Environment(\.widgetFamily) private var family
    var entry: FavEntry

    var body: some View {
        Group {
            switch family {
            case .accessoryCircular:
                ZStack {
                    AccessoryWidgetBackground()
                    VStack(spacing: 2) {
                        Text("\(entry.lines.count)")
                            .font(.headline.weight(.bold))
                        Text("★")
                            .font(.caption2)
                    }
                    .foregroundStyle(.primary)
                }
            default:
                VStack(alignment: .leading, spacing: 6) {
                    Label("Favorites", systemImage: "star.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color(red: 1.0, green: 0.86, blue: 0.35))
                    if entry.lines.isEmpty {
                        Text("Star bosses in the app")
                            .font(.caption)
                            .foregroundStyle(WidgetAppearance.muted)
                    } else {
                        ForEach(entry.lines.prefix(5)) { line in
                            HStack {
                                Text(line.name)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(WidgetAppearance.bodyText)
                                    .lineLimit(1)
                                Spacer(minLength: 4)
                                Text(line.detail)
                                    .font(.caption2.monospacedDigit())
                                    .foregroundStyle(WidgetAppearance.muted)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
        .raidWidgetContainerBackground(family: family)
    }
}
