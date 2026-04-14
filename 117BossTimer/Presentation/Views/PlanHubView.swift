//
//  PlanHubView.swift
//  117BossTimer
//

import SwiftUI

enum PlanHubSection: String, CaseIterable, Identifiable {
    case raidNight = "Raid night"
    case stats = "Stats"
    case library = "Library"

    var id: String { rawValue }
}

struct PlanHubView: View {
    @ObservedObject var viewModel: RaidWatchViewModel
    @State private var section: PlanHubSection = .raidNight

    var body: some View {
        NavigationStack {
            ZStack {
                RaidScreenBackground()

                VStack(spacing: 0) {
                    Picker("Section", selection: $section) {
                        ForEach(PlanHubSection.allCases) { tab in
                            Text(tab.rawValue).tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                    Group {
                        switch section {
                        case .raidNight:
                            RaidNightView(viewModel: viewModel)
                        case .stats:
                            StatisticsDashboardView(viewModel: viewModel)
                        case .library:
                            TemplateLibraryView(viewModel: viewModel)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Plan")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color.raidBackground.opacity(0.92), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .tint(.raidActive)
        }
    }
}
