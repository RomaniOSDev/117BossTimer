//
//  LiveActivityController.swift
//  117BossTimer
//

import ActivityKit
import Foundation

@MainActor
enum LiveActivityController {
    static var activitiesEnabled: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }

    static func startCountdown(for boss: Boss, reminderMinutes: Int, notificationsEnabled: Bool) async {
        guard activitiesEnabled else { return }
        let now = Date()
        let target: Date?
        if notificationsEnabled,
           let next = boss.nextRespawnTime(reference: now) {
            let reminder = next.addingTimeInterval(-Double(reminderMinutes) * 60)
            if reminder > now {
                target = reminder
            } else if next > now {
                target = next
            } else {
                target = next.addingTimeInterval(Double(boss.respawnTime) * 60)
            }
        } else if let next = boss.nextRespawnTime(reference: now), next > now {
            target = next
        } else if let last = boss.lastKillTime {
            target = last.addingTimeInterval(Double(boss.respawnTime) * 60)
        } else {
            target = now.addingTimeInterval(3600)
        }

        guard let end = target, end > now else { return }

        await endExisting(bossId: boss.id)

        let attributes = RespawnActivityAttributes(bossId: boss.id.uuidString, bossName: boss.name, kind: "Respawn")
        let state = RespawnActivityAttributes.ContentState(endDate: end, detail: "Countdown")

        let content = ActivityContent(state: state, staleDate: end.addingTimeInterval(120))

        do {
            _ = try Activity<RespawnActivityAttributes>.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
        } catch {
            // Activity may fail on Simulator or if disabled
        }
    }

    static func endExisting(bossId: UUID) async {
        let idString = bossId.uuidString
        for activity in Activity<RespawnActivityAttributes>.activities where activity.attributes.bossId == idString {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }

    static func endAll() async {
        for activity in Activity<RespawnActivityAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }
}
