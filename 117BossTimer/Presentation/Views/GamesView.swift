//
//  GamesView.swift
//  117BossTimer
//

import SwiftUI

struct GamesView: View {
    @ObservedObject var viewModel: RaidWatchViewModel
    @State private var showAddGameSheet = false
    @State private var gameToEdit: Game?

    var body: some View {
        NavigationStack {
            ZStack {
                RaidScreenBackground()

                List {
                    ForEach(viewModel.games) { game in
                        NavigationLink(value: game) {
                            GameCard(game: game, viewModel: viewModel)
                        }
                        .buttonStyle(.plain)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .contextMenu {
                            Button("Edit game") {
                                gameToEdit = game
                            }
                            Button("Favorite") {
                                viewModel.toggleFavoriteGame(game)
                            }
                            Divider()
                            Button("Delete", role: .destructive) {
                                viewModel.deleteGame(game)
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                viewModel.deleteGame(game)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }

                            Button {
                                viewModel.toggleFavoriteGame(game)
                            } label: {
                                Label("Favorite", systemImage: "star")
                            }
                            .tint(.raidWaiting)
                        }
                    }

                    Button {
                        showAddGameSheet = true
                    } label: {
                        Text("Add game")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.raidActive)
                            .raidSubtleTile(cornerRadius: 16, accent: .raidActive)
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
            }
            .navigationTitle("My games")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color.raidBackground.opacity(0.92), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .tint(.raidActive)
            .navigationDestination(for: Game.self) { game in
                GameBossesView(game: game, viewModel: viewModel)
            }
            .sheet(isPresented: $showAddGameSheet) {
                AddGameView(viewModel: viewModel)
            }
            .sheet(item: $gameToEdit) { game in
                AddGameView(viewModel: viewModel, existing: game)
            }
        }
    }
}
