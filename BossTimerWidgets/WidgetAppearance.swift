//
//  WidgetAppearance.swift
//  BossTimerWidgets
//

import SwiftUI
import WidgetKit

enum WidgetAppearance {
    static let homeBackground = Color(red: 0.05, green: 0.065, blue: 0.11)
    static let title = Color(red: 0.96, green: 0.97, blue: 0.99)
    static let bodyText = Color(red: 0.96, green: 0.97, blue: 0.99)
    static let muted = Color(red: 0.72, green: 0.76, blue: 0.84)
}

extension View {
    @ViewBuilder
    func raidWidgetContainerBackground(family: WidgetFamily) -> some View {
        containerBackground(for: .widget) {
            switch family {
            case .accessoryInline, .accessoryRectangular, .accessoryCircular:
                AccessoryWidgetBackground()
            case .systemSmall, .systemMedium, .systemLarge, .systemExtraLarge:
                WidgetAppearance.homeBackground
            @unknown default:
                WidgetAppearance.homeBackground
            }
        }
    }
}
