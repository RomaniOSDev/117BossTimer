//
//  AppExternalLink.swift
//  117BossTimer
//

import Foundation

enum AppExternalLink {
    case privacyPolicy
    case termsOfUse

    var urlString: String {
        switch self {
        case .privacyPolicy:
            return "https://www.termsfeed.com/live/d1b9b8f4-abf2-4e45-a614-efab5c764b73"
        case .termsOfUse:
            return "https://www.termsfeed.com/live/72ff8b73-fd98-4074-8bff-1c89c5b0d23a"
        }
    }

    var url: URL? {
        URL(string: urlString)
    }
}
