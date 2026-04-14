//
//  WidgetSnapshotWriter.swift
//  117BossTimer
//

import Foundation
import WidgetKit

enum WidgetSnapshotWriter {
    private static let fileName = "widget_snapshot.json"

    static func snapshotURL() -> URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppConfiguration.appGroupIdentifier)?
            .appendingPathComponent(fileName, isDirectory: false)
    }

    static func write(bosses: [Boss], reference: Date) {
        let lines: [WidgetBossLine] = bosses.map { boss in
            let st = boss.status(reference: reference)
            return WidgetBossLine(
                id: boss.id,
                name: boss.name,
                isFavorite: boss.isFavorite,
                statusRaw: st.rawValue,
                detail: boss.timeRemainingString(reference: reference),
                sortKey: sortKey(for: st, boss: boss, reference: reference)
            )
        }
        .sorted { $0.sortKey < $1.sortKey }

        let snap = WidgetSnapshot(updatedAt: reference, bosses: lines)
        guard let data = try? JSONEncoder().encode(snap) else { return }

        if let url = snapshotURL() {
            try? data.write(to: url, options: [.atomic])
        } else {
            AppConfiguration.sharedDefaults.set(data, forKey: "widget_snapshot_fallback")
        }

        WidgetCenter.shared.reloadAllTimelines()
    }

    private static func sortKey(for status: BossStatus, boss: Boss, reference: Date) -> Double {
        switch status {
        case .urgent:
            return 0 + Double(boss.name.hashValue % 1000) / 1_000_000
        case .active:
            return 1 + Double(boss.name.hashValue % 1000) / 1_000_000
        case .waiting:
            let t = boss.nextRespawnTime(reference: reference)?.timeIntervalSince1970 ?? .greatestFiniteMagnitude
            return 2 + t / 1e15
        }
    }
}

struct WidgetSnapshot: Codable {
    var updatedAt: Date
    var bosses: [WidgetBossLine]
}

struct WidgetBossLine: Codable, Identifiable {
    var id: UUID
    var name: String
    var isFavorite: Bool
    var statusRaw: String
    var detail: String
    var sortKey: Double
}
