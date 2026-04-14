//
//  BossTemplateCatalog.swift
//  117BossTimer
//

import Foundation

struct BossTemplateEntry: Identifiable, Hashable {
    var id: String { name }
    var name: String
    var respawnMinutes: Int
    var difficulty: BossDifficulty
    var location: String?
}

struct GameTemplatePack: Identifiable {
    let id: String
    var title: String
    var subtitle: String
    var systemIcon: String
    var gameDisplayName: String
    var bosses: [BossTemplateEntry]
}

enum BossTemplateCatalog {
    static let packs: [GameTemplatePack] = [
        GameTemplatePack(
            id: "mmo_a",
            title: "MMO A — world bosses",
            subtitle: "Neutral names; rename anytime",
            systemIcon: "globe.americas.fill",
            gameDisplayName: "MMO A",
            bosses: [
                BossTemplateEntry(name: "Ancient Drake", respawnMinutes: 360, difficulty: .heroic, location: "Volcanic ridge"),
                BossTemplateEntry(name: "Shadow Colossus", respawnMinutes: 720, difficulty: .heroic, location: "Ruins"),
                BossTemplateEntry(name: "Storm Herald", respawnMinutes: 180, difficulty: .normal, location: "Coast"),
                BossTemplateEntry(name: "Crystal Warden", respawnMinutes: 1440, difficulty: .mythic, location: "Cavern"),
                BossTemplateEntry(name: "Frost Matriarch", respawnMinutes: 240, difficulty: .heroic, location: "Glacier")
            ]
        ),
        GameTemplatePack(
            id: "mmo_b",
            title: "MMO B — dungeon rotation",
            subtitle: "Shorter windows for daily clears",
            systemIcon: "square.stack.3d.down.forward.fill",
            gameDisplayName: "MMO B",
            bosses: [
                BossTemplateEntry(name: "Gatekeeper Construct", respawnMinutes: 90, difficulty: .normal, location: "Gate hall"),
                BossTemplateEntry(name: "Archive Curator", respawnMinutes: 120, difficulty: .heroic, location: "Library wing"),
                BossTemplateEntry(name: "Forge Overseer", respawnMinutes: 60, difficulty: .normal, location: "Foundry"),
                BossTemplateEntry(name: "Hollow Choir", respawnMinutes: 150, difficulty: .heroic, location: "Crypt"),
                BossTemplateEntry(name: "Spire Ascendant", respawnMinutes: 200, difficulty: .mythic, location: "Spire apex")
            ]
        )
    ]
}
