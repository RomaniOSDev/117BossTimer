//
//  KillLogCard.swift
//  117BossTimer
//

import SwiftUI

struct KillLogCard: View {
    let log: KillLog

    var body: some View {
        HStack {
            Image(systemName: "crown.fill")
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.raidActive, Color.raidActive.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .font(.title2)
                .shadow(color: Color.raidActive.opacity(0.4), radius: 6, x: 0, y: 2)

            VStack(alignment: .leading, spacing: 4) {
                Text(log.bossName)
                    .foregroundColor(.white)
                    .font(.headline)

                Text(formattedDateTime(log.killTime))
                    .font(.caption)
                    .foregroundColor(.gray)

                if !log.partyMembers.isEmpty {
                    Text("Party: \(log.partyMembers.joined(separator: ", "))")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }

                if let notes = log.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.raidWaiting)
                        .padding(.top, 2)
                }
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.raidActive, Color.raidWaiting.opacity(0.85)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.raidActive.opacity(0.35), radius: 5, x: 0, y: 1)
        }
        .padding()
        .raidElevatedCard(cornerRadius: 18, accent: .raidActive)
    }
}
