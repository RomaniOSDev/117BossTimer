//
//  GameBossesView.swift
//  117BossTimer
//

import SwiftUI

struct GameBossesView: View {
    let game: Game
    @ObservedObject var viewModel: RaidWatchViewModel
    @State private var showEditGame = false
    @State private var showAddBoss = false
    @State private var bossToEdit: Boss?

    private var displayName: String {
        viewModel.games.first(where: { $0.id == game.id })?.name ?? game.name
    }

    private var bossesInGame: [Boss] {
        viewModel.bossesSortedForGame(game.id)
    }

    var body: some View {
        ZStack {
            RaidScreenBackground()

            if bossesInGame.isEmpty {
                VStack(spacing: 16) {
                    Text("No bosses in this game yet.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    Button("Add boss") {
                        bossToEdit = nil
                        showAddBoss = true
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Color(red: 0.04, green: 0.06, blue: 0.1))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 11)
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
                    .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
                    .shadow(color: Color.raidActive.opacity(0.4), radius: 10, x: 0, y: 4)
                }
                .padding(26)
                .raidElevatedCard(cornerRadius: 22, accent: .raidActive)
                .padding(.horizontal, 18)
            } else {
                List {
                    ForEach(bossesInGame) { boss in
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
        .navigationTitle(displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.raidBackground.opacity(0.92), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .tint(.raidActive)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showEditGame = true
                } label: {
                    Image(systemName: "pencil")
                }
                .accessibilityLabel("Edit game")
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
                                    colors: [Color.raidActive, Color.raidActive.opacity(0.78)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 34, height: 34)
                            .shadow(color: Color.raidActive.opacity(0.45), radius: 8, x: 0, y: 3)
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .accessibilityLabel("Add boss")
            }
        }
        .sheet(isPresented: $showEditGame) {
            if let current = viewModel.games.first(where: { $0.id == game.id }) {
                AddGameView(viewModel: viewModel, existing: current)
            }
        }
        .sheet(isPresented: $showAddBoss, onDismiss: { bossToEdit = nil }) {
            AddBossView(viewModel: viewModel, existingBoss: bossToEdit, presetGameId: game.id)
        }
    }
}
