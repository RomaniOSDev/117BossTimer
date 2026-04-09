//
//  BossStatus.swift
//  117BossTimer
//

import SwiftUI

enum BossStatus: String, Codable {
    case active = "Ready"
    case urgent = "Soon"
    case waiting = "On CD"

    var color: Color {
        switch self {
        case .active: return .raidActive
        case .urgent: return .raidUrgent
        case .waiting: return .raidWaiting
        }
    }
}
