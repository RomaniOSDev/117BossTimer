//
//  RaidWatchViewModel.swift
//  117BossTimer
//

import Combine
import Foundation
import UserNotifications

@MainActor
final class RaidWatchViewModel: ObservableObject {
    @Published var games: [Game] = []
    @Published var bosses: [Boss] = []
    @Published var groups: [RaidGroup] = []
    @Published var killLogs: [KillLog] = []

    @Published var notificationsEnabled = true
    @Published var reminderMinutes = 10

    @Published private(set) var referenceDate = Date()

    private var tick: AnyCancellable?
    private let gamesKey = "raidwatch_games"
    private let bossesKey = "raidwatch_bosses"
    private let groupsKey = "raidwatch_groups"
    private let killLogsKey = "raidwatch_killLogs"
    private let settingsKey = "raidwatch_settings"
    private let killLogsMigrationKey = "raidwatch_migrated_kill_logs_v1"

    init() {
        tick = Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] date in
                self?.referenceDate = date
            }
    }

    var activeBosses: [Boss] {
        bosses.filter { $0.status(reference: referenceDate) == .active }
    }

    var urgentBosses: [Boss] {
        bosses.filter { $0.status(reference: referenceDate) == .urgent }
    }

    var favoriteBosses: [Boss] {
        sortedBosses(bosses.filter(\.isFavorite))
    }

    var raidReadiness: Double {
        let ready = activeBosses.count
        let total = bosses.filter { $0.lastKillTime != nil }.count
        guard total > 0 else { return 0 }
        return Double(ready) / Double(total) * 100
    }

    var filteredBosses: [Boss] {
        sortedBosses(bosses)
    }

    func bossesSortedForGame(_ gameId: UUID) -> [Boss] {
        sortedBosses(bosses.filter { $0.gameId == gameId })
    }

    func bossesSortedForGroup(_ group: RaidGroup) -> [Boss] {
        let inGroup = group.bossIds.compactMap { bossId in bosses.first(where: { $0.id == bossId }) }
        return sortedBosses(inGroup)
    }

    func bossesForGame(_ gameId: UUID) -> [Boss] {
        bosses.filter { $0.gameId == gameId }
    }

    private func sortedBosses(_ list: [Boss]) -> [Boss] {
        list.sorted { a, b in
            let order: [BossStatus: Int] = [.urgent: 0, .active: 1, .waiting: 2]
            let oa = order[a.status(reference: referenceDate)] ?? 3
            let ob = order[b.status(reference: referenceDate)] ?? 3
            if oa != ob { return oa < ob }
            if a.isFavorite != b.isFavorite { return a.isFavorite && !b.isFavorite }
            return a.name.localizedCaseInsensitiveCompare(b.name) == .orderedAscending
        }
    }

    @discardableResult
    func addGame(name: String) -> UUID {
        let newGame = Game(id: UUID(), name: name, icon: "gamecontroller.fill", isFavorite: false)
        games.append(newGame)
        saveToUserDefaults()
        return newGame.id
    }

    func updateGame(_ game: Game) {
        guard let index = games.firstIndex(where: { $0.id == game.id }) else { return }
        games[index] = game
        for i in bosses.indices where bosses[i].gameId == game.id {
            bosses[i].gameName = game.name
        }
        saveToUserDefaults()
    }

    func deleteGame(_ game: Game) {
        games.removeAll { $0.id == game.id }
        bosses.removeAll { $0.gameId == game.id }
        saveToUserDefaults()
    }

    func toggleFavoriteGame(_ game: Game) {
        guard let index = games.firstIndex(where: { $0.id == game.id }) else { return }
        games[index].isFavorite.toggle()
        saveToUserDefaults()
    }

    func addBoss(_ boss: Boss) {
        bosses.append(boss)
        scheduleNotification(for: boss)
        saveToUserDefaults()
    }

    func updateBoss(_ boss: Boss) {
        guard let index = bosses.firstIndex(where: { $0.id == boss.id }) else { return }
        cancelNotification(for: bosses[index])
        bosses[index] = boss
        scheduleNotification(for: boss)
        saveToUserDefaults()
    }

    func deleteBoss(_ boss: Boss) {
        bosses.removeAll { $0.id == boss.id }
        cancelNotification(for: boss)
        saveToUserDefaults()
    }

    func toggleFavorite(_ boss: Boss) {
        guard let index = bosses.firstIndex(where: { $0.id == boss.id }) else { return }
        bosses[index].isFavorite.toggle()
        saveToUserDefaults()
    }

    func logKill(_ boss: Boss) {
        guard let index = bosses.firstIndex(where: { $0.id == boss.id }) else { return }
        let now = Date()
        bosses[index].lastKillTime = now

        let log = KillLog(
            id: UUID(),
            bossId: boss.id,
            bossName: boss.name,
            killTime: now,
            partyMembers: [],
            notes: nil
        )
        killLogs.insert(log, at: 0)

        cancelNotification(for: bosses[index])
        scheduleNotification(for: bosses[index])

        saveToUserDefaults()
    }

    func deleteKillLog(_ log: KillLog) {
        killLogs.removeAll { $0.id == log.id }
        saveToUserDefaults()
    }

    func addGroup(_ group: RaidGroup) {
        groups.append(group)
        saveToUserDefaults()
    }

    func updateGroup(_ group: RaidGroup) {
        guard let index = groups.firstIndex(where: { $0.id == group.id }) else { return }
        groups[index] = group
        saveToUserDefaults()
    }

    func deleteGroup(_ group: RaidGroup) {
        groups.removeAll { $0.id == group.id }
        saveToUserDefaults()
    }

    func startGroup(_ group: RaidGroup) {
        guard let index = groups.firstIndex(where: { $0.id == group.id }) else { return }
        groups[index].isActive = true
        saveToUserDefaults()
    }

    private func scheduleNotification(for boss: Boss) {
        guard notificationsEnabled, let nextRespawn = boss.nextRespawnTime(reference: Date()) else { return }

        let notificationTime = nextRespawn.addingTimeInterval(-Double(reminderMinutes) * 60)
        guard notificationTime > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Respawn reminder"
        content.body = "\(boss.name) will spawn in about \(reminderMinutes) minutes."
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: boss.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private func cancelNotification(for boss: Boss) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [boss.id.uuidString])
    }

    func updateAllNotifications() {
        for boss in bosses {
            cancelNotification(for: boss)
            scheduleNotification(for: boss)
        }
        saveToUserDefaults()
    }

    func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(games) {
            UserDefaults.standard.set(encoded, forKey: gamesKey)
        }
        if let encoded = try? JSONEncoder().encode(bosses) {
            UserDefaults.standard.set(encoded, forKey: bossesKey)
        }
        if let encoded = try? JSONEncoder().encode(groups) {
            UserDefaults.standard.set(encoded, forKey: groupsKey)
        }
        if let encoded = try? JSONEncoder().encode(killLogs) {
            UserDefaults.standard.set(encoded, forKey: killLogsKey)
        }

        let settings = NotificationSetting(enabled: notificationsEnabled, minutesBefore: reminderMinutes)
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: settingsKey)
        }
    }

    func loadFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: gamesKey),
           let decoded = try? JSONDecoder().decode([Game].self, from: data) {
            games = decoded
        }

        if let data = UserDefaults.standard.data(forKey: bossesKey),
           let decoded = try? JSONDecoder().decode([Boss].self, from: data) {
            bosses = decoded
        }

        if let data = UserDefaults.standard.data(forKey: groupsKey),
           let decoded = try? JSONDecoder().decode([RaidGroup].self, from: data) {
            groups = decoded
        }

        if let data = UserDefaults.standard.data(forKey: killLogsKey),
           let decoded = try? JSONDecoder().decode([KillLog].self, from: data) {
            killLogs = decoded
        }

        if let data = UserDefaults.standard.data(forKey: settingsKey),
           let decoded = try? JSONDecoder().decode(NotificationSetting.self, from: data) {
            notificationsEnabled = decoded.enabled
            reminderMinutes = decoded.minutesBefore
        }

        if killLogs.isEmpty,
           !bosses.isEmpty,
           !UserDefaults.standard.bool(forKey: killLogsMigrationKey) {
            let seeded = bosses.compactMap { boss -> KillLog? in
                guard let t = boss.lastKillTime else { return nil }
                return KillLog(
                    id: UUID(),
                    bossId: boss.id,
                    bossName: boss.name,
                    killTime: t,
                    partyMembers: [],
                    notes: nil
                )
            }
            if !seeded.isEmpty {
                killLogs = seeded.sorted { $0.killTime > $1.killTime }
                saveToUserDefaults()
            }
            UserDefaults.standard.set(true, forKey: killLogsMigrationKey)
        }

        if games.isEmpty {
            loadDemoData()
            saveToUserDefaults()
        }
    }

    func exportBundle() -> RaidWatchExport {
        RaidWatchExport(
            games: games,
            bosses: bosses,
            groups: groups,
            killLogs: killLogs,
            settings: NotificationSetting(enabled: notificationsEnabled, minutesBefore: reminderMinutes)
        )
    }

    func applyImport(_ data: RaidWatchExport) {
        games = data.games
        bosses = data.bosses
        groups = data.groups
        killLogs = data.killLogs
        notificationsEnabled = data.settings.enabled
        reminderMinutes = data.settings.minutesBefore
        updateAllNotifications()
        saveToUserDefaults()
    }

    func resetAllData() {
        for boss in bosses {
            cancelNotification(for: boss)
        }
        games = []
        bosses = []
        groups = []
        killLogs = []
        notificationsEnabled = true
        reminderMinutes = 10
        UserDefaults.standard.removeObject(forKey: gamesKey)
        UserDefaults.standard.removeObject(forKey: bossesKey)
        UserDefaults.standard.removeObject(forKey: groupsKey)
        UserDefaults.standard.removeObject(forKey: killLogsKey)
        UserDefaults.standard.removeObject(forKey: settingsKey)
        UserDefaults.standard.removeObject(forKey: killLogsMigrationKey)
        loadDemoData()
        saveToUserDefaults()
    }

    private func loadDemoData() {
        let game = Game(id: UUID(), name: "World of Warcraft", icon: "gamecontroller.fill", isFavorite: true)
        games = [game]

        let boss = Boss(
            id: UUID(),
            name: "Onyxia",
            gameId: game.id,
            gameName: game.name,
            difficulty: .heroic,
            respawnTime: 180,
            lastKillTime: Date().addingTimeInterval(-3600 * 2),
            location: "Onyxia's Lair",
            notes: "Tank required",
            isFavorite: true,
            createdAt: Date()
        )

        bosses = [boss]

        let group = RaidGroup(
            id: UUID(),
            name: "Evening raid",
            bossIds: [boss.id],
            isActive: false
        )

        groups = [group]

        killLogs = [
            KillLog(
                id: UUID(),
                bossId: boss.id,
                bossName: boss.name,
                killTime: Date().addingTimeInterval(-86400),
                partyMembers: [],
                notes: nil
            ),
            KillLog(
                id: UUID(),
                bossId: boss.id,
                bossName: boss.name,
                killTime: Date().addingTimeInterval(-86400 * 4),
                partyMembers: [],
                notes: nil
            )
        ]
    }
}

struct RaidWatchExport: Codable {
    var games: [Game]
    var bosses: [Boss]
    var groups: [RaidGroup]
    var killLogs: [KillLog]
    var settings: NotificationSetting
}
