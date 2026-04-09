//
//  AddGameView.swift
//  117BossTimer
//

import SwiftUI

struct AddGameView: View {
    @ObservedObject var viewModel: RaidWatchViewModel
    var existing: Game?

    @Environment(\.dismiss) private var dismiss
    @State private var name: String

    init(viewModel: RaidWatchViewModel, existing: Game? = nil) {
        self.viewModel = viewModel
        self.existing = existing
        _name = State(initialValue: existing?.name ?? "")
    }

    var body: some View {
        NavigationStack {
            ZStack {
                RaidScreenBackground()

                Form {
                    TextField("Game name", text: $name)
                        .foregroundColor(.white)
                        .tint(.raidActive)
                }
                .scrollContentBackground(.hidden)
                .foregroundColor(.white)
            }
            .navigationTitle(existing == nil ? "New game" : "Edit game")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.raidBackground.opacity(0.94), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.raidActive)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .foregroundColor(.raidActive)
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if var game = existing {
            game.name = trimmed
            viewModel.updateGame(game)
        } else {
            viewModel.addGame(name: trimmed)
        }
        dismiss()
    }
}
