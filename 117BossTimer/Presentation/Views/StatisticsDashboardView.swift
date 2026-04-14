//
//  StatisticsDashboardView.swift
//  117BossTimer
//

import Charts
import SwiftUI

struct StatisticsDashboardView: View {
    @ObservedObject var viewModel: RaidWatchViewModel

    private var weeklyCounts: [(weekStart: Date, count: Int)] {
        viewModel.killCountsByWeek()
    }

    private var topBosses: [(name: String, count: Int)] {
        viewModel.topBossesByKills(limit: 6)
    }

    private var averageIntervals: [(name: String, hours: Double)] {
        viewModel.averageHoursBetweenKills(limit: 5)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if viewModel.killLogs.isEmpty {
                    emptyState
                } else {
                    killsPerWeekCard
                    topBossesCard
                    intervalsCard
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 28)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 44))
                .foregroundColor(.raidWaiting)
            Text("No statistics yet")
                .font(.headline)
                .foregroundColor(.white)
            Text("Mark kills on the Bosses tab to see weekly charts and top targets.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(28)
        .raidElevatedCard(cornerRadius: 22, accent: .raidWaiting)
    }

    private var killsPerWeekCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Kills per week")
                .font(.headline)
                .foregroundColor(.raidActive)
            Chart {
                ForEach(Array(weeklyCounts.enumerated()), id: \.offset) { _, row in
                    BarMark(
                        x: .value("Week", row.weekStart),
                        y: .value("Kills", row.count)
                    )
                    .foregroundStyle(Color.raidActive.gradient)
                }
            }
            .frame(height: 200)
        }
        .padding()
        .raidElevatedCard(cornerRadius: 20, accent: .raidActive)
    }

    private var topBossesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Most logged")
                .font(.headline)
                .foregroundColor(.raidUrgent)
            ForEach(topBosses, id: \.name) { row in
                HStack {
                    Text(row.name)
                        .foregroundColor(.white)
                    Spacer()
                    Text("\(row.count)")
                        .font(.headline.weight(.bold))
                        .foregroundColor(.raidActive)
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .raidElevatedCard(cornerRadius: 20, accent: .raidUrgent)
    }

    private var intervalsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Avg. hours between kills")
                .font(.headline)
                .foregroundColor(.raidWaiting)
            if averageIntervals.isEmpty {
                Text("Need at least two kills on the same boss.")
                    .font(.caption)
                    .foregroundColor(.gray)
            } else {
                ForEach(averageIntervals, id: \.name) { row in
                    HStack {
                        Text(row.name)
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Spacer()
                        Text(String(format: "%.1f h", row.hours))
                            .font(.subheadline.monospacedDigit())
                            .foregroundColor(.raidWaiting)
                    }
                }
            }
        }
        .padding()
        .raidElevatedCard(cornerRadius: 20, accent: .raidWaiting)
    }
}
