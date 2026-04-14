//
//  NextRespawnsWidget.swift
//  BossTimerWidgets
//

import SwiftUI
import WidgetKit

struct NextRespawnsWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "com.era.bossTimer.nextRespawns", provider: NextRespawnsProvider()) { entry in
            NextRespawnsWidgetView(entry: entry)
        }
        .configurationDisplayName("Next respawns")
        .description("Soonest spawns and timers for all tracked bosses.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular, .accessoryInline])
    }
}

private struct NextRespawnsProvider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), lines: [
            WidgetBossLine(id: UUID(), name: "Sample", isFavorite: true, statusRaw: "Soon", detail: "12m left", sortKey: 0)
        ])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        completion(makeEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        let entry = makeEntry()
        completion(Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(15 * 60))))
    }

    private func makeEntry() -> SimpleEntry {
        let snap = WidgetSnapshotLoader.load()
        let sorted = snap.bosses.sorted { $0.sortKey < $1.sortKey }
        return SimpleEntry(date: snap.updatedAt, lines: Array(sorted.prefix(8)))
    }
}

private struct SimpleEntry: TimelineEntry {
    let date: Date
    let lines: [WidgetBossLine]
}

private struct NextRespawnsWidgetView: View {
    @Environment(\.widgetFamily) private var family
    var entry: SimpleEntry

    var body: some View {
        Group {
            switch family {
            case .accessoryRectangular, .accessoryInline:
                accessoryView
            default:
                homeView
            }
        }
        .raidWidgetContainerBackground(family: family)
    }

    private var homeView: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Next respawns")
                .font(.caption.weight(.bold))
                .foregroundStyle(WidgetAppearance.title)
            if entry.lines.isEmpty {
                Text("Open BossTimer to add bosses")
                    .font(.caption)
                    .foregroundStyle(WidgetAppearance.muted)
            } else {
                ForEach(entry.lines.prefix(family == .systemSmall ? 3 : 5)) { line in
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

    private var accessoryView: some View {
        Group {
            if let first = entry.lines.first {
                HStack {
                    Text(first.name)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    Spacer(minLength: 2)
                    Text(first.detail)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .minimumScaleFactor(0.7)
                }
            } else {
                Text("No bosses")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
