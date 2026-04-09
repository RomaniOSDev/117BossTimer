//
//  AddGroupView.swift
//  117BossTimer
//

import SwiftUI

struct AddGroupView: View {
    @ObservedObject var viewModel: RaidWatchViewModel
    var existing: RaidGroup?

    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var selectedBossIds: Set<UUID>

    init(viewModel: RaidWatchViewModel, existing: RaidGroup? = nil) {
        self.viewModel = viewModel
        self.existing = existing
        _name = State(initialValue: existing?.name ?? "")
        _selectedBossIds = State(initialValue: Set(existing?.bossIds ?? []))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                RaidScreenBackground()

                Form {
                    Section {
                        TextField("Group name", text: $name)
                            .foregroundColor(.white)
                            .tint(.raidActive)
                    }

                    Section {
                        if viewModel.bosses.isEmpty {
                            Text("No bosses yet. Add a boss first.")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(viewModel.bosses) { boss in
                                Toggle(isOn: binding(for: boss.id)) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(boss.name)
                                            .foregroundColor(.white)
                                        Text(boss.gameName)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .tint(.raidActive)
                            }
                        }
                    } header: {
                        Text("Bosses in group")
                            .foregroundColor(.gray)
                    }
                }
                .scrollContentBackground(.hidden)
                .foregroundColor(.white)
            }
            .navigationTitle(existing == nil ? "New group" : "Edit group")
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

    private func binding(for id: UUID) -> Binding<Bool> {
        Binding(
            get: { selectedBossIds.contains(id) },
            set: { on in
                if on {
                    selectedBossIds.insert(id)
                } else {
                    selectedBossIds.remove(id)
                }
            }
        )
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        if let existing = existing {
            let updated = RaidGroup(
                id: existing.id,
                name: trimmed,
                bossIds: Array(selectedBossIds),
                isActive: existing.isActive
            )
            viewModel.updateGroup(updated)
        } else {
            let group = RaidGroup(
                id: UUID(),
                name: trimmed,
                bossIds: Array(selectedBossIds),
                isActive: false
            )
            viewModel.addGroup(group)
        }
        dismiss()
    }
}
