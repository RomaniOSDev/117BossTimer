//
//  AppConfiguration.swift
//  117BossTimer
//

import Foundation

enum AppConfiguration {
    /// Enable this App Group on the app target and the widget extension in Signing & Capabilities.
    static let appGroupIdentifier = "group.com.era.b00sst3m5rr39ds.raidwatch"

    static var sharedDefaults: UserDefaults {
        UserDefaults(suiteName: appGroupIdentifier) ?? .standard
    }
}
