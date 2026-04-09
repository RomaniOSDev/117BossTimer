//
//  HomeView.swift
//  117BossTimer
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: RaidWatchViewModel
    @Binding var selectedTab: Int

    @State private var showAddBoss = false
    @State private var bossToEdit: Boss?

    private var headerDate: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "EEEE, MMM d"
        return f.string(from: Date())
    }

    private var summaryLine: String {
        let a = viewModel.activeBosses.count
        let u = viewModel.urgentBosses.count
        let t = viewModel.bosses.count
        if t == 0 {
            return "Add your first boss to start tracking respawns."
        }
        return "\(a) ready • \(u) soon • \(t) total"
    }

    private var recentKills: [KillLog] {
        Array(viewModel.killLogs.prefix(4))
    }

    private var readinessFraction: CGFloat {
        CGFloat(min(1, max(0, viewModel.raidReadiness / 100)))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                RaidScreenBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        headerBlock

                        if !viewModel.bosses.isEmpty {
                            readinessRing
                            statsStrip
                        }

                        quickActions

                        if !viewModel.urgentBosses.isEmpty {
                            sectionTitle("Needs attention", icon: "exclamationmark.triangle.fill", color: .raidUrgent)
                            VStack(spacing: 10) {
                                ForEach(viewModel.urgentBosses) { boss in
                                    Button {
                                        bossToEdit = boss
                                        showAddBoss = true
                                    } label: {
                                        HomeCompactBossRow(boss: boss, referenceDate: viewModel.referenceDate) {
                                            viewModel.logKill(boss)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 4)
                        }

                        if !viewModel.activeBosses.isEmpty {
                            sectionTitle("Ready now", icon: "checkmark.circle.fill", color: .raidActive)
                            VStack(spacing: 10) {
                                ForEach(viewModel.activeBosses.prefix(6)) { boss in
                                    Button {
                                        bossToEdit = boss
                                        showAddBoss = true
                                    } label: {
                                        HomeCompactBossRow(boss: boss, referenceDate: viewModel.referenceDate) {
                                            viewModel.logKill(boss)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 4)

                            if viewModel.activeBosses.count > 6 {
                                Button {
                                    selectedTab = 1
                                } label: {
                                    Text("See all \(viewModel.activeBosses.count) ready")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundColor(.raidActive)
                                        .frame(maxWidth: .infinity)
                                }
                                .padding(.top, 4)
                            }
                        }

                        if !viewModel.favoriteBosses.isEmpty {
                            sectionTitle("Favorites", icon: "star.fill", color: .raidWaiting)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(viewModel.favoriteBosses.prefix(8)) { boss in
                                        favoriteChip(boss)
                                    }
                                }
                            }
                        }

                        if !recentKills.isEmpty {
                            HStack {
                                sectionTitle("Recent kills", icon: "clock.arrow.circlepath", color: .raidActive)
                                Spacer()
                                Button("See all") {
                                    selectedTab = 4
                                }
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.raidActive)
                            }
                            VStack(spacing: 8) {
                                ForEach(recentKills) { log in
                                    recentKillRow(log)
                                }
                            }
                            .padding(.horizontal, 4)
                        }

                        if viewModel.bosses.isEmpty {
                            emptyOnboarding
                        }

                        Color.clear.frame(height: 24)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.raidBackground.opacity(0.92), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Home")
                        .font(.headline.weight(.bold))
                        .foregroundColor(.raidActive)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        bossToEdit = nil
                        showAddBoss = true
                    } label: {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.raidActive, Color.raidActive.opacity(0.75)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 36, height: 36)
                                .shadow(color: Color.raidActive.opacity(0.45), radius: 8, x: 0, y: 3)
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .accessibilityLabel("Add boss")
                }
            }
            .sheet(isPresented: $showAddBoss, onDismiss: { bossToEdit = nil }) {
                AddBossView(viewModel: viewModel, existingBoss: bossToEdit)
            }
        }
    }

    private var headerBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(headerDate)
                .font(.subheadline.weight(.medium))
                .foregroundColor(.gray)
            Text(summaryLine)
                .font(.title3.weight(.semibold))
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.raidActive.opacity(0.18),
                            Color.raidBackground.opacity(0.9),
                            Color.raidWaiting.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Color.raidActive.opacity(0.45), Color.clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.42), radius: 18, x: 0, y: 12)
        .shadow(color: Color.raidActive.opacity(0.22), radius: 14, x: 0, y: 5)
    }

    private var readinessRing: some View {
        HStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.08), lineWidth: 12)
                    .frame(width: 118, height: 118)
                Circle()
                    .trim(from: 0, to: readinessFraction)
                    .stroke(
                        LinearGradient(
                            colors: [Color.raidActive, Color.raidActive.opacity(0.5)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 118, height: 118)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.45), value: readinessFraction)
                Text(String(format: "%.0f%%", viewModel.raidReadiness))
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: Color.raidActive.opacity(0.22), radius: 8, x: 0, y: 0)
            }
            .shadow(color: Color.raidActive.opacity(0.12), radius: 16, x: 0, y: 0)

            VStack(alignment: .leading, spacing: 8) {
                Text("Raid readiness")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("Share of bosses with an active respawn window (last kill recorded).")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
                Button {
                    selectedTab = 1
                } label: {
                    Label("Open boss list", systemImage: "list.bullet")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.raidActive)
                }
                .padding(.top, 4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .raidElevatedCard(cornerRadius: 20, accent: .raidActive)
    }

    private var statsStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                StatCard(
                    title: "Active",
                    value: "\(viewModel.activeBosses.count)",
                    icon: "checkmark.circle.fill",
                    color: .raidActive
                )
                StatCard(
                    title: "Soon",
                    value: "\(viewModel.urgentBosses.count)",
                    icon: "exclamationmark.triangle.fill",
                    color: .raidUrgent
                )
                StatCard(
                    title: "Total",
                    value: "\(viewModel.bosses.count)",
                    icon: "list.bullet",
                    color: .raidWaiting
                )
                StatCard(
                    title: "Games",
                    value: "\(viewModel.games.count)",
                    icon: "gamecontroller.fill",
                    color: .raidActive
                )
            }
        }
    }

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Shortcuts", icon: "bolt.fill", color: .raidActive)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                HomeQuickActionTile(title: "Add boss", systemImage: "plus.circle.fill", accent: .raidActive) {
                    bossToEdit = nil
                    showAddBoss = true
                }
                HomeQuickActionTile(title: "All bosses", systemImage: "list.bullet", accent: .raidWaiting) {
                    selectedTab = 1
                }
                HomeQuickActionTile(title: "Games", systemImage: "gamecontroller.fill", accent: .raidActive) {
                    selectedTab = 2
                }
                HomeQuickActionTile(title: "Groups", systemImage: "person.3.fill", accent: .raidWaiting) {
                    selectedTab = 3
                }
            }
        }
    }

    private func sectionTitle(_ text: String, icon: String, color: Color) -> some View {
        Label {
            Text(text)
                .font(.subheadline.weight(.bold))
                .foregroundColor(.white)
        } icon: {
            Image(systemName: icon)
                .foregroundColor(color)
        }
    }

    private func favoriteChip(_ boss: Boss) -> some View {
        let st = boss.status(reference: viewModel.referenceDate)
        return Button {
            bossToEdit = boss
            showAddBoss = true
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(boss.name)
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundColor(.raidWaiting)
                }
                Text(boss.timeRemainingString(reference: viewModel.referenceDate))
                    .font(.caption2)
                    .foregroundColor(st.color)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(width: 148, alignment: .leading)
            .raidSubtleTile(cornerRadius: 14, accent: st.color)
        }
        .buttonStyle(.plain)
    }

    private func recentKillRow(_ log: KillLog) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .font(.body)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.raidActive, Color.raidActive.opacity(0.65)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.raidActive.opacity(0.35), radius: 5, x: 0, y: 1)
            VStack(alignment: .leading, spacing: 3) {
                Text(log.bossName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                Text(formattedDateTime(log.killTime))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .raidElevatedCard(cornerRadius: 16, accent: .raidActive)
        .contentShape(Rectangle())
        .onTapGesture {
            selectedTab = 4
        }
    }

    private var emptyOnboarding: some View {
        VStack(spacing: 14) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 40))
                .foregroundStyle(Color.raidActive.opacity(0.85))
            Text("No bosses tracked")
                .font(.headline)
                .foregroundColor(.white)
            Text("Create a boss, set respawn timing, and use Mark kill after each defeat. Everything syncs on this Home screen.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            Button {
                bossToEdit = nil
                showAddBoss = true
            } label: {
                Text("Add your first boss")
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(Color(red: 0.04, green: 0.06, blue: 0.1))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.raidActive, Color.raidActive.opacity(0.82)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(Capsule().stroke(Color.white.opacity(0.25), lineWidth: 1))
                    .shadow(color: Color.raidActive.opacity(0.45), radius: 12, x: 0, y: 5)
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .raidElevatedCard(cornerRadius: 22, accent: .raidWaiting)
    }
}
