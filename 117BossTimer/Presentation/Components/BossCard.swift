//
//  BossCard.swift
//  117BossTimer
//

import SwiftUI

struct BossCard: View {
    let boss: Boss
    var referenceDate: Date

    var body: some View {
        let status = boss.status(reference: referenceDate)

        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "crown.fill")
                    .foregroundStyle(
                        LinearGradient(
                            colors: [boss.difficulty.color, boss.difficulty.color.opacity(0.65)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .font(.title2)
                    .shadow(color: boss.difficulty.color.opacity(0.4), radius: 6, x: 0, y: 2)

                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(boss.name)
                            .foregroundColor(.white)
                            .font(.headline)

                        if boss.isFavorite {
                            Image(systemName: "star.fill")
                                .foregroundColor(.raidWaiting)
                                .font(.caption)
                                .shadow(color: Color.raidWaiting.opacity(0.4), radius: 3, x: 0, y: 1)
                        }
                    }

                    Text("\(boss.gameName) • \(boss.difficulty.rawValue)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(status.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [status.color.opacity(0.35), status.color.opacity(0.15)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        )
                        .overlay(
                            Capsule()
                                .stroke(status.color.opacity(0.45), lineWidth: 1)
                        )
                        .foregroundColor(status.color)
                        .shadow(color: status.color.opacity(0.25), radius: 4, x: 0, y: 1)

                    Text(boss.timeRemainingString(reference: referenceDate))
                        .font(.caption2)
                        .foregroundColor(status.color)
                }
            }

            ProgressView(value: boss.progressPercentage(reference: referenceDate))
                .tint(status.color)
                .background(Color.black.opacity(0.25))
                .frame(height: 8)
                .scaleEffect(y: 1.4)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(Color.black.opacity(0.35), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.35), radius: 2, x: 0, y: 1)

            if let location = boss.location, !location.isEmpty {
                HStack {
                    Image(systemName: "mappin")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(location)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            if let lastKill = boss.lastKillTime {
                HStack {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("Last kill: \(formattedDate(lastKill))")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .raidElevatedCard(cornerRadius: 18, accent: status.color)
    }
}
