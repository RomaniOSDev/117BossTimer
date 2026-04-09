//
//  DateFormatting.swift
//  117BossTimer
//

import Foundation

func formattedDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "dd.MM.yyyy HH:mm"
    return formatter.string(from: date)
}

func formattedDateTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "dd.MM.yyyy, HH:mm"
    return formatter.string(from: date)
}

func formatTime(_ minutes: Int) -> String {
    if minutes >= 60 {
        let hours = minutes / 60
        let mins = minutes % 60
        if mins > 0 {
            return "\(hours)h \(mins)m"
        }
        return "\(hours)h"
    }
    return "\(minutes)m"
}
