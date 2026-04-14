//
//  RaidNightSchedule.swift
//  117BossTimer
//

import Foundation

struct RaidNightSchedule: Codable, Equatable {
    /// `Calendar` weekday: 1 = Sunday … 7 = Saturday
    var weekday: Int
    var hour: Int
    var minute: Int
    var isEnabled: Bool
    var focusedGroupId: UUID?

    static let `default` = RaidNightSchedule(weekday: 4, hour: 20, minute: 0, isEnabled: true, focusedGroupId: nil)

    func nextRaidStart(after date: Date, calendar: Calendar = .current) -> Date {
        var comps = DateComponents()
        comps.weekday = weekday
        comps.hour = hour
        comps.minute = minute
        comps.second = 0
        guard let next = calendar.nextDate(after: date.addingTimeInterval(-1), matching: comps, matchingPolicy: .nextTime) else {
            return date
        }
        return next
    }
}
