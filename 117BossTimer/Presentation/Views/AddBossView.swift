//
//  AddBossView.swift
//  117BossTimer
//

import SwiftUI

private let respawnMinuteOptions = [5, 10, 15, 20, 30, 45, 60, 90, 120, 180, 240, 360, 480, 720, 1440]

struct AddBossView: View {
    @ObservedObject var viewModel: RaidWatchViewModel
    var existingBoss: Boss?

    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var selectedGameId: UUID?
    @State private var newGameName: String
    @State private var difficulty: BossDifficulty
    @State private var respawnTime: Int
    @State private var location: String
    @State private var lastKillTime: Date
    @State private var notes: String
    @State private var isFavorite: Bool

    init(viewModel: RaidWatchViewModel, existingBoss: Boss? = nil, presetGameId: UUID? = nil) {
        self.viewModel = viewModel
        self.existingBoss = existingBoss
        _name = State(initialValue: existingBoss?.name ?? "")
        _selectedGameId = State(initialValue: existingBoss?.gameId ?? presetGameId)
        _newGameName = State(initialValue: "")
        _difficulty = State(initialValue: existingBoss?.difficulty ?? .normal)
        _respawnTime = State(initialValue: existingBoss?.respawnTime ?? 60)
        _location = State(initialValue: existingBoss?.location ?? "")
        _lastKillTime = State(initialValue: existingBoss?.lastKillTime ?? Date())
        _notes = State(initialValue: existingBoss?.notes ?? "")
        _isFavorite = State(initialValue: existingBoss?.isFavorite ?? false)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                RaidScreenBackground()

                Form {
                    Section {
                        TextField("Boss name", text: $name)
                            .foregroundColor(.white)
                            .tint(.raidActive)

                        Picker("Game", selection: $selectedGameId) {
                            ForEach(viewModel.games) { game in
                                Text(game.name).tag(Optional(game.id))
                            }
                            Text("+ New game").tag(nil as UUID?)
                        }
                        .tint(.raidActive)

                        if selectedGameId == nil {
                            TextField("New game name", text: $newGameName)
                                .foregroundColor(.white)
                                .tint(.raidActive)
                        }

                        Picker("Difficulty", selection: $difficulty) {
                            ForEach(BossDifficulty.allCases, id: \.self) { diff in
                                Text(diff.rawValue).tag(diff)
                            }
                        }
                        .tint(.raidActive)
                    }

                    Section {
                        HStack {
                            Text("Respawn (minutes)")
                                .foregroundColor(.white)
                            Spacer()
                            Picker("", selection: $respawnTime) {
                                ForEach(respawnMinuteOptions, id: \.self) { minutes in
                                    Text(formatTime(minutes)).tag(minutes)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(.raidActive)
                        }
                    } header: {
                        Text("Respawn time")
                            .foregroundColor(.gray)
                    }

                    Section {
                        TextField("Location (optional)", text: $location)
                            .foregroundColor(.white)
                            .tint(.raidActive)

                        DatePicker("Last kill", selection: $lastKillTime, displayedComponents: [.date, .hourAndMinute])
                            .tint(.raidActive)

                        TextEditor(text: $notes)
                            .frame(height: 80)
                            .foregroundColor(.white)
                            .tint(.raidActive)
                    } header: {
                        Text("Details")
                            .foregroundColor(.gray)
                    }

                    Section {
                        Toggle("Add to favorites", isOn: $isFavorite)
                            .tint(.raidActive)
                    }
                }
                .scrollContentBackground(.hidden)
                .foregroundColor(.white)
            }
            .navigationTitle(existingBoss == nil ? "New boss" : "Edit boss")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.raidBackground.opacity(0.94), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.raidActive)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveBoss()
                    }
                    .foregroundColor(.raidActive)
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func saveBoss() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        var gameId = selectedGameId
        var gameName = viewModel.games.first(where: { $0.id == gameId })?.name ?? ""

        if gameId == nil {
            let trimmedGame = newGameName.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedGame.isEmpty else { return }
            gameId = viewModel.addGame(name: trimmedGame)
            gameName = trimmedGame
        }

        guard let gid = gameId else { return }

        let loc = location.trimmingCharacters(in: .whitespacesAndNewlines)
        let noteStr = notes.trimmingCharacters(in: .whitespacesAndNewlines)

        if var existing = existingBoss {
            existing.name = trimmedName
            existing.gameId = gid
            existing.gameName = gameName
            existing.difficulty = difficulty
            existing.respawnTime = respawnTime
            existing.lastKillTime = lastKillTime
            existing.location = loc.isEmpty ? nil : loc
            existing.notes = noteStr.isEmpty ? nil : noteStr
            existing.isFavorite = isFavorite
            viewModel.updateBoss(existing)
        } else {
            let boss = Boss(
                id: UUID(),
                name: trimmedName,
                gameId: gid,
                gameName: gameName,
                difficulty: difficulty,
                respawnTime: respawnTime,
                lastKillTime: lastKillTime,
                location: loc.isEmpty ? nil : loc,
                notes: noteStr.isEmpty ? nil : noteStr,
                isFavorite: isFavorite,
                createdAt: Date()
            )
            viewModel.addBoss(boss)
        }

        dismiss()
    }
}
