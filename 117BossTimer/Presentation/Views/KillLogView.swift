//
//  KillLogView.swift
//  117BossTimer
//

import SwiftUI

struct KillLogView: View {
    @ObservedObject var viewModel: RaidWatchViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                RaidScreenBackground()

                Group {
                    if viewModel.killLogs.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 48))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.raidWaiting, Color.raidWaiting.opacity(0.55)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: Color.raidWaiting.opacity(0.35), radius: 12, x: 0, y: 4)
                            Text("No kills logged yet")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("On the Bosses tab, swipe a boss row and choose Mark kill. Each kill is saved here.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 12)
                        }
                        .padding(28)
                        .raidElevatedCard(cornerRadius: 22, accent: .raidWaiting)
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(viewModel.killLogs) { log in
                                KillLogCard(log: log)
                                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            viewModel.deleteKillLog(log)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .scrollContentBackground(.hidden)
                        .listStyle(.plain)
                    }
                }
            }
            .navigationTitle("Kill history")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color.raidBackground.opacity(0.92), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .tint(.raidActive)
        }
    }
}
