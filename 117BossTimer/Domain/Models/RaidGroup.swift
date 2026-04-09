//
//  RaidGroup.swift
//  117BossTimer
//

import Foundation

struct RaidGroup: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var bossIds: [UUID]
    var isActive: Bool
}
