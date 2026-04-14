//
//  RespawnActivityAttributes.swift
//  117BossTimer
//  Keep in sync with BossTimerWidgets/RespawnActivityAttributes.swift
//

import ActivityKit
import Foundation

struct RespawnActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var endDate: Date
        var detail: String
    }

    var bossId: String
    var bossName: String
    var kind: String
}
