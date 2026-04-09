//
//  BossListView.swift
//  117BossTimer
//

import SwiftUI

struct BossListView: View {
    @ObservedObject var viewModel: RaidWatchViewModel
    @State private var showAddBoss = false
    @State private var bossToEdit: Boss?

    var body: some View {
        NavigationStack {
            ZStack {
                RaidScreenBackground()

                VStack(alignment: .leading, spacing: 0) {
                    List {
                        ForEach(viewModel.filteredBosses) { boss in
                            BossCard(boss: boss, referenceDate: viewModel.referenceDate)
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    bossToEdit = boss
                                    showAddBoss = true
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button {
                                        viewModel.logKill(boss)
                                    } label: {
                                        Label("Mark kill", systemImage: "checkmark")
                                    }
                                    .tint(.raidActive)

                                    Button(role: .destructive) {
                                        viewModel.deleteBoss(boss)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }

                                    Button {
                                        viewModel.toggleFavorite(boss)
                                    } label: {
                                        Label("Favorite", systemImage: "star")
                                    }
                                    .tint(.raidWaiting)
                                }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(.plain)
                }
            }
            .navigationTitle("All bosses")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color.raidBackground.opacity(0.92), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        bossToEdit = nil
                        showAddBoss = true
                    } label: {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.raidActive, Color.raidActive.opacity(0.78)],
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
}
