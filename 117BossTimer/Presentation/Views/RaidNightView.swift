//
//  RaidNightView.swift
//  117BossTimer
//

import SwiftUI

struct RaidNightView: View {
    @ObservedObject var viewModel: RaidWatchViewModel

    private var schedule: RaidNightSchedule {
        viewModel.raidNightSchedule
    }

    private var nextStart: Date {
        schedule.nextRaidStart(after: viewModel.referenceDate)
    }

    private var raidBosses: [Boss] {
        viewModel.bossesForRaidNightPreview()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                scheduleCard

                if schedule.isEnabled {
                    countdownCard
                    statusBoard
                    wontBeReadySection
                    checklistSection
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 28)
        }
    }

    private var scheduleCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Schedule")
                .font(.headline)
                .foregroundColor(.raidActive)

            Toggle("Raid night enabled", isOn: Binding(
                get: { viewModel.raidNightSchedule.isEnabled },
                set: { v in viewModel.updateRaidNight { $0.isEnabled = v } }
            ))
            .tint(.raidActive)
            .foregroundColor(.white)

            if schedule.isEnabled {
                weekdayPicker
                timePicker
                groupPicker
            }
        }
        .padding()
        .raidElevatedCard(cornerRadius: 20, accent: .raidActive)
    }

    private var weekdayPicker: some View {
        HStack {
            Text("Weekday")
                .foregroundColor(.white)
            Spacer()
            Picker("", selection: Binding(
                get: { viewModel.raidNightSchedule.weekday },
                set: { v in viewModel.updateRaidNight { $0.weekday = v } }
            )) {
                Text("Sun").tag(1)
                Text("Mon").tag(2)
                Text("Tue").tag(3)
                Text("Wed").tag(4)
                Text("Thu").tag(5)
                Text("Fri").tag(6)
                Text("Sat").tag(7)
            }
            .pickerStyle(.menu)
            .tint(.raidActive)
        }
    }

    private var timePicker: some View {
        HStack {
            Text("Start time")
                .foregroundColor(.white)
            Spacer()
            DatePicker(
                "",
                selection: Binding(
                    get: {
                        var c = DateComponents()
                        c.hour = schedule.hour
                        c.minute = schedule.minute
                        return Calendar.current.date(from: c) ?? viewModel.referenceDate
                    },
                    set: { date in
                        let h = Calendar.current.component(.hour, from: date)
                        let m = Calendar.current.component(.minute, from: date)
                        viewModel.updateRaidNight { row in
                            row.hour = h
                            row.minute = m
                        }
                    }
                ),
                displayedComponents: .hourAndMinute
            )
            .labelsHidden()
            .tint(.raidActive)
        }
    }

    private var groupPicker: some View {
        HStack {
            Text("Boss list")
                .foregroundColor(.white)
            Spacer()
            Picker("", selection: Binding(
                get: { schedule.focusedGroupId?.uuidString ?? "" },
                set: { newVal in
                    viewModel.updateRaidNight { row in
                        if newVal.isEmpty {
                            row.focusedGroupId = nil
                        } else if let u = UUID(uuidString: newVal) {
                            row.focusedGroupId = u
                        }
                    }
                }
            )) {
                Text("Favorites (or all)").tag("")
                ForEach(viewModel.groups) { g in
                    Text(g.name).tag(g.id.uuidString)
                }
            }
            .pickerStyle(.menu)
            .tint(.raidActive)
        }
    }

    private var countdownCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Next raid night")
                .font(.caption.weight(.semibold))
                .foregroundColor(.gray)
            Text(formatted(nextStart))
                .font(.title2.weight(.bold))
                .foregroundColor(.white)
            Text(timeUntil(nextStart))
                .font(.subheadline.weight(.medium))
                .foregroundColor(.raidActive)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .raidElevatedCard(cornerRadius: 20, accent: .raidWaiting)
    }

    private var statusBoard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Now")
                .font(.headline)
                .foregroundColor(.raidActive)
            if raidBosses.isEmpty {
                Text("Add bosses or pick a group with bosses.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            } else {
                ForEach(raidBosses) { boss in
                    raidRow(boss)
                }
            }
        }
        .padding()
        .raidElevatedCard(cornerRadius: 20, accent: .raidUrgent)
    }

    private func raidRow(_ boss: Boss) -> some View {
        let st = boss.status(reference: viewModel.referenceDate)
        return HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(boss.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                Text(boss.timeRemainingString(reference: viewModel.referenceDate))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            Text(st.rawValue)
                .font(.caption.weight(.bold))
                .foregroundColor(st.color)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(st.color.opacity(0.18))
                .clipShape(Capsule())
        }
        .padding(.vertical, 6)
    }

    private var wontBeReadySection: some View {
        let blocked = viewModel.bossesNotReadyBy(raidStart: nextStart)
        return Group {
            if !blocked.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Likely still on CD at start")
                        .font(.headline)
                        .foregroundColor(.raidUrgent)
                    Text("Next spawn window is after your raid start time.")
                        .font(.caption)
                        .foregroundColor(.gray)
                    ForEach(blocked) { boss in
                        HStack {
                            Text(boss.name)
                                .foregroundColor(.white)
                            Spacer()
                            if let next = boss.nextRespawnTime(reference: viewModel.referenceDate) {
                                Text(formatted(next))
                                    .font(.caption)
                                    .foregroundColor(.raidUrgent)
                            }
                        }
                    }
                }
                .padding()
                .raidElevatedCard(cornerRadius: 20, accent: .raidUrgent)
            }
        }
    }

    private var checklistSection: some View {
        let ready = viewModel.bossesReadyBy(raidStart: nextStart)
        return VStack(alignment: .leading, spacing: 10) {
            Text("Before you pull")
                .font(.headline)
                .foregroundColor(.raidActive)
            Text("Bosses that should be in-window or close by raid start (based on your last kills).")
                .font(.caption)
                .foregroundColor(.gray)
            ForEach(ready.prefix(12)) { boss in
                Label(boss.name, systemImage: "checkmark.circle")
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            if ready.count > 12 {
                Text("+\(ready.count - 12) more")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .raidElevatedCard(cornerRadius: 20, accent: .raidActive)
    }

    private func formatted(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: date)
    }

    private func timeUntil(_ date: Date) -> String {
        let sec = max(0, Int(date.timeIntervalSince(viewModel.referenceDate)))
        let d = sec / 86400
        let h = (sec % 86400) / 3600
        let m = (sec % 3600) / 60
        if d > 0 { return "In \(d)d \(h)h" }
        if h > 0 { return "In \(h)h \(m)m" }
        return "In \(m)m"
    }
}
