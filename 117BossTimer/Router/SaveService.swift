//
//  SaveService.swift
//  117BossTimer
//

import Foundation

struct BookmarkURLSlot {
    static var lastUrl: URL? {
        get { UserDefaults.standard.url(forKey: RouterDefaultsKeyVault.lastUrlPropertyKey) }
        set { UserDefaults.standard.set(newValue, forKey: RouterDefaultsKeyVault.lastUrlPropertyKey) }
    }
}
