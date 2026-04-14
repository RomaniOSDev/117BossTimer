//
//  KillLog.swift
//  117BossTimer
//

import Foundation

struct KillLog: Identifiable, Codable, Hashable {
    let id: UUID
    let bossId: UUID
    let bossName: String
    let killTime: Date
    let partyMembers: [String]
    var notes: String?
}
