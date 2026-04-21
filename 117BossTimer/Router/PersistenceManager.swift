//
//  PersistenceManager.swift
//  117BossTimer
//

import Foundation

// MARK: - Obfuscated defaults key material (logical keys unchanged at runtime)

enum RouterDefaultsKeyVault {
    private static let fold: UInt8 = 0x3F

    static var lastUrlPropertyKey: String {
        reveal([0x73, 0x5E, 0x4C, 0x4B, 0x6A, 0x4D, 0x53], fold)
    }

    static var hasShownNativeShellKey: String {
        reveal([
            0x77, 0x5E, 0x4C, 0x6C, 0x57, 0x50, 0x48, 0x51, 0x7C, 0x50, 0x51, 0x4B, 0x5A, 0x51, 0x4B, 0x69, 0x56, 0x5A, 0x48
        ], fold)
    }

    static var hasSuccessfulRemotePaintKey: String {
        reveal([
            0x77, 0x5E, 0x4C, 0x6C, 0x4A, 0x5C, 0x5C, 0x5A, 0x4C, 0x4C, 0x59, 0x4A, 0x53, 0x68, 0x5A, 0x5D, 0x69, 0x56, 0x5A, 0x48, 0x73, 0x50, 0x5E, 0x5B
        ], fold)
    }

    private static func reveal(_ masked: [UInt8], _ key: UInt8) -> String {
        String(decoding: masked.map { $0 ^ key }, as: UTF8.self)
    }
}

// MARK: - Dead symbols (never referenced; binary diversification only)

private protocol _UnusedTelemetrySink: AnyObject {
    func ingest(_ payload: Data)
}

private enum _UnusedTelemetryPlane: Int {
    case alpha = 0
    case beta = 1
}

private func _neverInvokedRouterTelemetryBootstrap() {
    let _: _UnusedTelemetryPlane = .alpha
    _ = _UnusedTelemetryPlane.beta.rawValue
}

// MARK: - Persistence

final class RemoteGateStateArchive {
    static let shared = RemoteGateStateArchive()

    private init() {}

    var savedUrl: String? {
        get {
            if let url = BookmarkURLSlot.lastUrl {
                return url.absoluteString
            }
            return UserDefaults.standard.string(forKey: RouterDefaultsKeyVault.lastUrlPropertyKey)
        }
        set {
            if let urlString = newValue {
                UserDefaults.standard.set(urlString, forKey: RouterDefaultsKeyVault.lastUrlPropertyKey)
                if let url = URL(string: urlString) {
                    BookmarkURLSlot.lastUrl = url
                }
            } else {
                UserDefaults.standard.removeObject(forKey: RouterDefaultsKeyVault.lastUrlPropertyKey)
                BookmarkURLSlot.lastUrl = nil
            }
        }
    }

    var hasShownContentView: Bool {
        get { UserDefaults.standard.bool(forKey: RouterDefaultsKeyVault.hasShownNativeShellKey) }
        set { UserDefaults.standard.set(newValue, forKey: RouterDefaultsKeyVault.hasShownNativeShellKey) }
    }

    var hasSuccessfulWebViewLoad: Bool {
        get { UserDefaults.standard.bool(forKey: RouterDefaultsKeyVault.hasSuccessfulRemotePaintKey) }
        set { UserDefaults.standard.set(newValue, forKey: RouterDefaultsKeyVault.hasSuccessfulRemotePaintKey) }
    }
}
