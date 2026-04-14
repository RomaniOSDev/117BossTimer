//
//  SharedSnapshotModels.swift
//  BossTimerWidgets
//  JSON must match 117BossTimer/Core/WidgetSupport/WidgetSnapshotWriter.swift
//

import Foundation

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

enum WidgetSnapshotLoader {
    static let appGroup = "group.com.era.b00sst3m5rr39ds.raidwatch"
    private static let fileName = "widget_snapshot.json"

    static func load() -> WidgetSnapshot {
        if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup)?
            .appendingPathComponent(fileName),
            let data = try? Data(contentsOf: url),
            let snap = try? JSONDecoder().decode(WidgetSnapshot.self, from: data) {
            return snap
        }
        if let data = UserDefaults(suiteName: appGroup)?.data(forKey: "widget_snapshot_fallback"),
           let snap = try? JSONDecoder().decode(WidgetSnapshot.self, from: data) {
            return snap
        }
        return WidgetSnapshot(updatedAt: Date(), bosses: [])
    }
}
