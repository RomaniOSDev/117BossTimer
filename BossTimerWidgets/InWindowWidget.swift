//
//  InWindowWidget.swift
//  BossTimerWidgets
//

import SwiftUI
import WidgetKit

struct InWindowWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "com.era.bossTimer.inWindow", provider: InWindowProvider()) { entry in
            InWindowWidgetView(entry: entry)
        }
        .configurationDisplayName("In window")
        .description("Bosses that are ready or spawning within 15 minutes.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
    }
}

private struct InWindowProvider: TimelineProvider {
    func placeholder(in context: Context) -> WindowEntry {
        WindowEntry(date: Date(), lines: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (WindowEntry) -> Void) {
        completion(makeEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WindowEntry>) -> Void) {
        let entry = makeEntry()
        completion(Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(5 * 60))))
    }

    private func makeEntry() -> WindowEntry {
        let snap = WidgetSnapshotLoader.load()
        let active = snap.bosses.filter { $0.statusRaw == "Ready" || $0.statusRaw == "Soon" }
            .sorted { $0.sortKey < $1.sortKey }
        return WindowEntry(date: snap.updatedAt, lines: Array(active.prefix(8)))
    }
}

private struct WindowEntry: TimelineEntry {
    let date: Date
    let lines: [WidgetBossLine]
}

private struct InWindowWidgetView: View {
    @Environment(\.widgetFamily) private var family
    var entry: WindowEntry

    var body: some View {
        Group {
            switch family {
            case .accessoryRectangular:
                accessoryRectangular
            default:
                homeContent
            }
        }
        .raidWidgetContainerBackground(family: family)
    }

    private var homeContent: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Ready & soon")
                .font(.caption.weight(.bold))
                .foregroundStyle(WidgetAppearance.title)
            if entry.lines.isEmpty {
                Text("No urgent bosses")
                    .font(.caption)
                    .foregroundStyle(WidgetAppearance.muted)
            } else {
                ForEach(entry.lines.prefix(family == .systemSmall ? 4 : 6)) { line in
                    HStack {
                        Circle()
                            .fill(line.statusRaw == "Ready" ? Color.green : Color.orange)
                            .frame(width: 6, height: 6)
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

    private var accessoryRectangular: some View {
        Group {
            if let first = entry.lines.first {
                HStack {
                    Circle()
                        .fill(first.statusRaw == "Ready" ? Color.green : Color.orange)
                        .frame(width: 5, height: 5)
                    Text(first.name)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    Spacer(minLength: 2)
                    Text(first.detail)
                        .font(.caption2.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            } else {
                Text("No urgent bosses")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
