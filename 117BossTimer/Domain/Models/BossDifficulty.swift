//
//  BossDifficulty.swift
//  117BossTimer
//

import SwiftUI

enum BossDifficulty: String, Codable, CaseIterable {
    case normal = "Normal"
    case heroic = "Heroic"
    case mythic = "Mythic"

    var color: Color {
        switch self {
        case .normal: return .raidWaiting
        case .heroic: return .raidUrgent.opacity(0.85)
        case .mythic: return Color.purple.opacity(0.9)
        }
    }
}
