//
//  Game.swift
//  117BossTimer
//

import Foundation

struct Game: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var icon: String
    var isFavorite: Bool
}
