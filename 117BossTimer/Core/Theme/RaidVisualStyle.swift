//
//  RaidVisualStyle.swift
//  117BossTimer
//

import SwiftUI

// MARK: - Full screen

struct RaidScreenBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.07, blue: 0.14),
                    Color(red: 0.045, green: 0.055, blue: 0.095),
                    Color(red: 0.06, green: 0.045, blue: 0.095)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [Color.raidActive.opacity(0.14), Color.clear],
                center: UnitPoint(x: 0.15, y: 0.12),
                startRadius: 10,
                endRadius: 340
            )

            RadialGradient(
                colors: [Color.raidWaiting.opacity(0.1), Color.clear],
                center: UnitPoint(x: 0.9, y: 0.85),
                startRadius: 20,
                endRadius: 400
            )

            LinearGradient(
                colors: [
                    Color.white.opacity(0.03),
                    Color.clear,
                    Color.black.opacity(0.25)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
    }
}

// MARK: - Card styling

enum RaidCardStyle {
    static func fillGradient(accent: Color) -> LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.12, green: 0.15, blue: 0.22),
                Color(red: 0.065, green: 0.075, blue: 0.11)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func borderGradient(accent: Color) -> LinearGradient {
        LinearGradient(
            colors: [
                accent.opacity(0.55),
                Color.white.opacity(0.14),
                accent.opacity(0.12),
                Color.black.opacity(0.2)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

extension View {
    /// Raised card: gradient fill, luminous border, stacked shadows.
    func raidElevatedCard(cornerRadius: CGFloat = 16, accent: Color = .raidActive) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(RaidCardStyle.fillGradient(accent: accent))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(RaidCardStyle.borderGradient(accent: accent), lineWidth: 1.2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
                    .blur(radius: 0.5)
                    .padding(-0.5)
            )
            .shadow(color: Color.black.opacity(0.48), radius: 14, x: 0, y: 10)
            .shadow(color: accent.opacity(0.22), radius: 12, x: 0, y: 4)
            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
    }

    /// Shallow tile (stats, quick actions).
    func raidSubtleTile(cornerRadius: CGFloat = 14, accent: Color = .raidActive) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.09, green: 0.11, blue: 0.16),
                                Color(red: 0.055, green: 0.065, blue: 0.095)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [accent.opacity(0.35), Color.white.opacity(0.06)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(0.38), radius: 10, x: 0, y: 6)
            .shadow(color: accent.opacity(0.12), radius: 8, x: 0, y: 2)
    }

    func raidInsetWell(cornerRadius: CGFloat = 12) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.35),
                                Color.black.opacity(0.15)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.black.opacity(0.35), lineWidth: 1)
            )
    }
}
