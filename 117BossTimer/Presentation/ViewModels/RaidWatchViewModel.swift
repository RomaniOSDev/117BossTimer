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
    @Published var raidNightSchedule = RaidNightSchedule.default

    @Published private(set) var referenceDate = Date()

    private var tick: AnyCancellable?
    private let gamesKey = "raidwatch_games"
    private let bossesKey = "raidwatch_bosses"
    private let groupsKey = "raidwatch_groups"
    private let killLogsKey = "raidwatch_killLogs"
    private let settingsKey = "raidwatch_settings"
    private let raidNightKey = "raidwatch_raidNight"
    private let killLogsMigrationKey = "raidwatch_migrated_kill_logs_v1"

    private var persistence: UserDefaults { AppConfiguration.sharedDefaults }

    init() {
        tick = Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] date in
                guard let self else { return }
                self.referenceDate = date
                WidgetSnapshotWriter.write(bosses: self.bosses, reference: date)
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

    func updateRaidNight(_ mutate: (inout RaidNightSchedule) -> Void) {
        mutate(&raidNightSchedule)
        saveToUserDefaults()
    }

    func bossesForRaidNightPreview() -> [Boss] {
        let list = raidNightRoster()
        return sortedBosses(list)
    }

    func bossesNotReadyBy(raidStart: Date) -> [Boss] {
        raidNightRoster().filter { !isBossLikelyReady(boss: $0, at: raidStart) }
    }

    func bossesReadyBy(raidStart: Date) -> [Boss] {
        raidNightRoster().filter { isBossLikelyReady(boss: $0, at: raidStart) }
    }

    private func raidNightRoster() -> [Boss] {
        if let gid = raidNightSchedule.focusedGroupId,
           let group = groups.first(where: { $0.id == gid }) {
            return group.bossIds.compactMap { id in bosses.first { $0.id == id } }
        }
        let fav = bosses.filter(\.isFavorite)
        if !fav.isEmpty { return fav }
        return bosses
    }

    /// Boss is expected to be in-window (or unknown) by `raidStart`.
    private func isBossLikelyReady(boss: Boss, at raidStart: Date) -> Bool {
        guard let last = boss.lastKillTime else { return true }
        let next = last.addingTimeInterval(Double(boss.respawnTime) * 60)
        return next <= raidStart
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

    func killCountsByWeek() -> [(weekStart: Date, count: Int)] {
        let cal = Calendar.current
        var buckets: [Date: Int] = [:]
        for log in killLogs {
            guard let start = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: log.killTime)) else { continue }
            buckets[start, default: 0] += 1
        }
        return buckets.keys.sorted().map { ($0, buckets[$0] ?? 0) }
    }

    func topBossesByKills(limit: Int) -> [(name: String, count: Int)] {
        var counts: [String: Int] = [:]
        for log in killLogs {
            counts[log.bossName, default: 0] += 1
        }
        return counts.map { ($0.key, $0.value) }
            .sorted { $0.1 > $1.1 }
            .prefix(limit)
            .map { ($0.0, $0.1) }
    }

    func averageHoursBetweenKills(limit: Int) -> [(name: String, hours: Double)] {
        let grouped = Dictionary(grouping: killLogs, by: \.bossName)
        var result: [(String, Double)] = []
        for (name, logs) in grouped where logs.count >= 2 {
            let sorted = logs.sorted { $0.killTime < $1.killTime }
            var gaps: [TimeInterval] = []
            for i in 1 ..< sorted.count {
                gaps.append(sorted[i].killTime.timeIntervalSince(sorted[i - 1].killTime))
            }
            let avg = gaps.reduce(0, +) / Double(gaps.count)
            result.append((name, avg / 3600))
        }
        return result.sorted { $0.1 < $1.1 }.prefix(limit).map { ($0.0, $0.1) }
    }

    func updateKillLogNotes(logId: UUID, notes: String?) {
        guard let i = killLogs.firstIndex(where: { $0.id == logId }) else { return }
        killLogs[i].notes = notes
        saveToUserDefaults()
    }

    func applyTemplatePack(_ pack: GameTemplatePack) {
        let gameId = addGame(name: pack.gameDisplayName)
        if let gi = games.firstIndex(where: { $0.id == gameId }) {
            games[gi].icon = pack.systemIcon
        }
        var newBossIds: [UUID] = []
        let now = Date()
        for (idx, row) in pack.bosses.enumerated() {
            let b = Boss(
                id: UUID(),
                name: row.name,
                gameId: gameId,
                gameName: pack.gameDisplayName,
                difficulty: row.difficulty,
                respawnTime: row.respawnMinutes,
                lastKillTime: now.addingTimeInterval(-Double(idx * 4000)),
                location: row.location,
                notes: "Tap to rename",
                isFavorite: idx < 3,
                createdAt: now
            )
            bosses.append(b)
            newBossIds.append(b.id)
            scheduleNotification(for: b)
        }
        let group = RaidGroup(id: UUID(), name: "\(pack.gameDisplayName) run", bossIds: newBossIds, isActive: false)
        groups.append(group)
        raidNightSchedule.focusedGroupId = group.id
        saveToUserDefaults()
    }

    /// Rich demo: 5 bosses, group, raid night, history for stats.
    func seedOnboardingEveningScenario() {
        for boss in bosses {
            cancelNotification(for: boss)
        }
        games = []
        bosses = []
        groups = []
        killLogs = []
        persistence.removeObject(forKey: gamesKey)
        persistence.removeObject(forKey: bossesKey)
        persistence.removeObject(forKey: groupsKey)
        persistence.removeObject(forKey: killLogsKey)

        let game = Game(id: UUID(), name: "Demo MMO", icon: "moon.stars.fill", isFavorite: true)
        games = [game]
        let now = Date()
        let names = ["Ember Wyrm", "Rift Colossus", "Shade Triad", "Iron Sentinel", "Starfall Oracle"]
        let respawns = [120, 240, 90, 360, 180]
        var ids: [UUID] = []
        for (i, name) in names.enumerated() {
            let id = UUID()
            ids.append(id)
            let b = Boss(
                id: id,
                name: name,
                gameId: game.id,
                gameName: game.name,
                difficulty: i == 4 ? .mythic : .heroic,
                respawnTime: respawns[i],
                lastKillTime: now.addingTimeInterval(-Double(i + 1) * 3500),
                location: "Zone \(i + 1)",
                notes: nil,
                isFavorite: true,
                createdAt: now
            )
            bosses.append(b)
            scheduleNotification(for: b)
        }
        let group = RaidGroup(id: UUID(), name: "Tonight's run", bossIds: ids, isActive: true)
        groups = [group]
        raidNightSchedule = RaidNightSchedule(weekday: Calendar.current.component(.weekday, from: now), hour: 20, minute: 0, isEnabled: true, focusedGroupId: group.id)

        var logs: [KillLog] = []
        for week in 0 ..< 4 {
            for (i, bid) in ids.enumerated() {
                let t = now.addingTimeInterval(-Double((week * 7 + i + 1) * 86400 / 10))
                logs.append(KillLog(id: UUID(), bossId: bid, bossName: names[i], killTime: t, partyMembers: [], notes: week == 0 ? "Clean run" : nil))
            }
        }
        killLogs = logs.sorted { $0.killTime > $1.killTime }
        saveToUserDefaults()
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
        if raidNightSchedule.focusedGroupId == group.id {
            raidNightSchedule.focusedGroupId = nil
        }
        saveToUserDefaults()
    }

    func startGroup(_ group: RaidGroup) {
        guard let index = groups.firstIndex(where: { $0.id == group.id }) else { return }
        groups[index].isActive = true
        saveToUserDefaults()
    }

    func startLiveActivity(for boss: Boss) async {
        await LiveActivityController.startCountdown(
            for: boss,
            reminderMinutes: reminderMinutes,
            notificationsEnabled: notificationsEnabled
        )
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
            persistence.set(encoded, forKey: gamesKey)
        }
        if let encoded = try? JSONEncoder().encode(bosses) {
            persistence.set(encoded, forKey: bossesKey)
        }
        if let encoded = try? JSONEncoder().encode(groups) {
            persistence.set(encoded, forKey: groupsKey)
        }
        if let encoded = try? JSONEncoder().encode(killLogs) {
            persistence.set(encoded, forKey: killLogsKey)
        }

        let settings = NotificationSetting(enabled: notificationsEnabled, minutesBefore: reminderMinutes)
        if let encoded = try? JSONEncoder().encode(settings) {
            persistence.set(encoded, forKey: settingsKey)
        }
        if let encoded = try? JSONEncoder().encode(raidNightSchedule) {
            persistence.set(encoded, forKey: raidNightKey)
        }

        mirrorToStandardUserDefaults()
        WidgetSnapshotWriter.write(bosses: bosses, reference: referenceDate)
    }

    /// Legacy installs wrote to `UserDefaults.standard`; keep a mirror so older paths still see keys if needed.
    private func mirrorToStandardUserDefaults() {
        let s = UserDefaults.standard
        if let d = persistence.data(forKey: gamesKey) { s.set(d, forKey: gamesKey) }
        if let d = persistence.data(forKey: bossesKey) { s.set(d, forKey: bossesKey) }
        if let d = persistence.data(forKey: groupsKey) { s.set(d, forKey: groupsKey) }
        if let d = persistence.data(forKey: killLogsKey) { s.set(d, forKey: killLogsKey) }
        if let d = persistence.data(forKey: settingsKey) { s.set(d, forKey: settingsKey) }
        if let d = persistence.data(forKey: raidNightKey) { s.set(d, forKey: raidNightKey) }
    }

    func loadFromUserDefaults() {
        migrateLegacyDefaultsIntoAppGroupIfNeeded()

        if let data = persistence.data(forKey: gamesKey),
           let decoded = try? JSONDecoder().decode([Game].self, from: data) {
            games = decoded
        }

        if let data = persistence.data(forKey: bossesKey),
           let decoded = try? JSONDecoder().decode([Boss].self, from: data) {
            bosses = decoded
        }

        if let data = persistence.data(forKey: groupsKey),
           let decoded = try? JSONDecoder().decode([RaidGroup].self, from: data) {
            groups = decoded
        }

        if let data = persistence.data(forKey: killLogsKey),
           let decoded = try? JSONDecoder().decode([KillLog].self, from: data) {
            killLogs = decoded
        }

        if let data = persistence.data(forKey: settingsKey),
           let decoded = try? JSONDecoder().decode(NotificationSetting.self, from: data) {
            notificationsEnabled = decoded.enabled
            reminderMinutes = decoded.minutesBefore
        }

        if let data = persistence.data(forKey: raidNightKey),
           let decoded = try? JSONDecoder().decode(RaidNightSchedule.self, from: data) {
            raidNightSchedule = decoded
        }

        if killLogs.isEmpty,
           !bosses.isEmpty,
           !persistence.bool(forKey: killLogsMigrationKey) {
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
            persistence.set(true, forKey: killLogsMigrationKey)
        }

        if games.isEmpty {
            loadDemoData()
            saveToUserDefaults()
        }

        WidgetSnapshotWriter.write(bosses: bosses, reference: referenceDate)
    }

    private func migrateLegacyDefaultsIntoAppGroupIfNeeded() {
        let legacy = UserDefaults.standard
        guard persistence.data(forKey: gamesKey) == nil,
              legacy.data(forKey: gamesKey) != nil else { return }
        for key in [gamesKey, bossesKey, groupsKey, killLogsKey, settingsKey, raidNightKey, killLogsMigrationKey] {
            if let v = legacy.object(forKey: key) {
                persistence.set(v, forKey: key)
            }
        }
    }

    func exportBundle() -> RaidWatchExport {
        RaidWatchExport(
            games: games,
            bosses: bosses,
            groups: groups,
            killLogs: killLogs,
            settings: NotificationSetting(enabled: notificationsEnabled, minutesBefore: reminderMinutes),
            raidNight: raidNightSchedule
        )
    }

    func applyImport(_ data: RaidWatchExport) {
        games = data.games
        bosses = data.bosses
        groups = data.groups
        killLogs = data.killLogs
        notificationsEnabled = data.settings.enabled
        reminderMinutes = data.settings.minutesBefore
        raidNightSchedule = data.raidNight
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
        raidNightSchedule = .default
        for key in [gamesKey, bossesKey, groupsKey, killLogsKey, settingsKey, raidNightKey, killLogsMigrationKey] {
            persistence.removeObject(forKey: key)
            UserDefaults.standard.removeObject(forKey: key)
        }
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
    var raidNight: RaidNightSchedule

    enum CodingKeys: String, CodingKey {
        case games, bosses, groups, killLogs, settings, raidNight
    }

    init(
        games: [Game],
        bosses: [Boss],
        groups: [RaidGroup],
        killLogs: [KillLog],
        settings: NotificationSetting,
        raidNight: RaidNightSchedule = .default
    ) {
        self.games = games
        self.bosses = bosses
        self.groups = groups
        self.killLogs = killLogs
        self.settings = settings
        self.raidNight = raidNight
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        games = try c.decode([Game].self, forKey: .games)
        bosses = try c.decode([Boss].self, forKey: .bosses)
        groups = try c.decode([RaidGroup].self, forKey: .groups)
        killLogs = try c.decode([KillLog].self, forKey: .killLogs)
        settings = try c.decode(NotificationSetting.self, forKey: .settings)
        raidNight = try c.decodeIfPresent(RaidNightSchedule.self, forKey: .raidNight) ?? .default
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(games, forKey: .games)
        try c.encode(bosses, forKey: .bosses)
        try c.encode(groups, forKey: .groups)
        try c.encode(killLogs, forKey: .killLogs)
        try c.encode(settings, forKey: .settings)
        try c.encode(raidNight, forKey: .raidNight)
    }
}
