//
//  Boss.swift
//  117BossTimer
//

import Foundation

struct Boss: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var gameId: UUID
    var gameName: String
    var difficulty: BossDifficulty
    var respawnTime: Int
    var lastKillTime: Date?
    var location: String?
    var notes: String?
    var isFavorite: Bool
    var createdAt: Date
}

extension Boss {
    func nextRespawnTime(reference: Date) -> Date? {
        guard let lastKill = lastKillTime else { return nil }
        return lastKill.addingTimeInterval(Double(respawnTime) * 60)
    }

    func status(reference: Date) -> BossStatus {
        guard let next = nextRespawnTime(reference: reference) else { return .active }
        if reference >= next { return .active }
        let remaining = next.timeIntervalSince(reference)
        if remaining <= 15 * 60 { return .urgent }
        return .waiting
    }

    func progressPercentage(reference: Date) -> Double {
        guard let lastKill = lastKillTime else { return 1 }
        guard let next = nextRespawnTime(reference: reference) else { return 1 }
        if reference >= next { return 1 }
        let total = Double(respawnTime) * 60
        let elapsed = reference.timeIntervalSince(lastKill)
        guard total > 0 else { return 1 }
        return min(1, max(0, elapsed / total))
    }

    func timeRemainingString(reference: Date) -> String {
        switch status(reference: reference) {
        case .active:
            return "Ready"
        case .urgent, .waiting:
            guard let next = nextRespawnTime(reference: reference) else { return "—" }
            let sec = max(0, Int(next.timeIntervalSince(reference)))
            let h = sec / 3600
            let m = (sec % 3600) / 60
            if h > 0 { return String(format: "%dh %dm left", h, m) }
            return String(format: "%dm left", max(1, m))
        }
    }
}
