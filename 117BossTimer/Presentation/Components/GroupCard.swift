//
//  GroupCard.swift
//  117BossTimer
//

import SwiftUI

struct GroupCard: View {
    let group: RaidGroup
    @ObservedObject var viewModel: RaidWatchViewModel

    private var groupBosses: [Boss] {
        viewModel.bosses.filter { group.bossIds.contains($0.id) }
    }

    private var ready: Int {
        groupBosses.filter { $0.status(reference: viewModel.referenceDate) == .active }.count
    }

    private var total: Int {
        groupBosses.count
    }

    private var cardAccent: Color {
        group.isActive ? .raidActive : .raidWaiting
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "person.3.fill")
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.raidActive, Color.raidActive.opacity(0.65)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .font(.title2)
                    .shadow(color: Color.raidActive.opacity(0.4), radius: 6, x: 0, y: 2)

                Text(group.name)
                    .foregroundColor(.white)
                    .font(.headline)

                Spacer()

                if group.isActive {
                    Text("Active")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.raidActive.opacity(0.4), Color.raidActive.opacity(0.18)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .overlay(Capsule().stroke(Color.raidActive.opacity(0.5), lineWidth: 1))
                        .foregroundColor(.raidActive)
                        .shadow(color: Color.raidActive.opacity(0.25), radius: 4, x: 0, y: 1)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(group.bossIds, id: \.self) { bossId in
                        if let boss = viewModel.bosses.first(where: { $0.id == bossId }) {
                            let st = boss.status(reference: viewModel.referenceDate)
                            HStack {
                                Text(boss.name)
                                    .font(.caption)
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [st.color.opacity(0.95), st.color.opacity(0.5)],
                                            center: .center,
                                            startRadius: 1,
                                            endRadius: 8
                                        )
                                    )
                                    .frame(width: 7, height: 7)
                                    .shadow(color: st.color.opacity(0.5), radius: 3, x: 0, y: 0)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .raidSubtleTile(cornerRadius: 11, accent: st.color)
                        }
                    }
                }
            }
            .allowsHitTesting(false)

            HStack {
                Text("Readiness:")
                    .font(.caption)
                    .foregroundColor(.gray)

                Text("\(ready)/\(total)")
                    .font(.caption)
                    .foregroundColor(.raidActive)

                Spacer()

                ProgressView(value: total > 0 ? Double(ready) / Double(total) : 0)
                    .tint(.raidActive)
                    .frame(width: 100, height: 5)
                    .background(Color.black.opacity(0.2))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.black.opacity(0.35), lineWidth: 1))
            }
        }
        .padding()
        .raidElevatedCard(cornerRadius: 18, accent: cardAccent)
    }
}
