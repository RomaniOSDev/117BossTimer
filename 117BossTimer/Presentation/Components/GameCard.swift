//
//  GameCard.swift
//  117BossTimer
//

import SwiftUI

struct GameCard: View {
    let game: Game
    @ObservedObject var viewModel: RaidWatchViewModel

    private var bossesInGame: [Boss] {
        viewModel.bossesForGame(game.id)
    }

    private var activeCount: Int {
        bossesInGame.filter { $0.status(reference: viewModel.referenceDate) == .active }.count
    }

    var body: some View {
        HStack {
            Image(systemName: "gamecontroller.fill")
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.raidActive, Color.raidActive.opacity(0.65)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .font(.title2)
                .shadow(color: Color.raidActive.opacity(0.45), radius: 8, x: 0, y: 2)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(game.name)
                        .foregroundColor(.white)
                        .font(.headline)

                    if game.isFavorite {
                        Image(systemName: "star.fill")
                            .foregroundColor(.raidWaiting)
                            .font(.caption)
                    }
                }

                Text("\(bossesInGame.count) bosses • \(activeCount) active")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            if activeCount > 0 {
                Text("\(activeCount)")
                    .font(.title2)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.raidActive, Color.raidWaiting.opacity(0.9)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .bold()
                    .shadow(color: Color.raidActive.opacity(0.35), radius: 6, x: 0, y: 2)
            }
        }
        .padding()
        .raidElevatedCard(cornerRadius: 18, accent: .raidActive)
    }
}
