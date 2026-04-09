//
//  HomeCompactBossRow.swift
//  117BossTimer
//

import SwiftUI

struct HomeCompactBossRow: View {
    let boss: Boss
    var referenceDate: Date
    var onMarkKill: () -> Void

    var body: some View {
        let status = boss.status(reference: referenceDate)

        HStack(spacing: 12) {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [status.color, status.color.opacity(0.55)],
                        center: .center,
                        startRadius: 1,
                        endRadius: 10
                    )
                )
                .frame(width: 10, height: 10)
                .shadow(color: status.color.opacity(0.55), radius: 5, x: 0, y: 1)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(boss.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                    if boss.isFavorite {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.raidWaiting)
                            .shadow(color: Color.raidWaiting.opacity(0.35), radius: 3, x: 0, y: 0)
                    }
                }
                Text(boss.gameName)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 4) {
                Text(status.rawValue)
                    .font(.caption2.weight(.medium))
                    .foregroundColor(status.color)
                Text(boss.timeRemainingString(reference: referenceDate))
                    .font(.caption.weight(.medium))
                    .foregroundColor(.white.opacity(0.85))
            }

            Button(action: onMarkKill) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.raidActive, Color.raidActive.opacity(0.65)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color.raidActive.opacity(0.45), radius: 6, x: 0, y: 2)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Mark kill")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .raidElevatedCard(cornerRadius: 16, accent: status.color)
    }
}
