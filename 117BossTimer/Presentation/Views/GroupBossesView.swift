//
//  GroupBossesView.swift
//  117BossTimer
//

import SwiftUI

struct GroupBossesView: View {
    let group: RaidGroup
    @ObservedObject var viewModel: RaidWatchViewModel
    @State private var showEditGroup = false
    @State private var showAddBoss = false
    @State private var bossToEdit: Boss?

    private var displayName: String {
        viewModel.groups.first(where: { $0.id == group.id })?.name ?? group.name
    }

    private var bossesInGroup: [Boss] {
        let current = viewModel.groups.first(where: { $0.id == group.id }) ?? group
        return viewModel.bossesSortedForGroup(current)
    }

    var body: some View {
        ZStack {
            RaidScreenBackground()

            if bossesInGroup.isEmpty {
                VStack(spacing: 16) {
                    Text("No bosses in this group yet.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    Button("Edit group") {
                        showEditGroup = true
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.raidActive)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 11)
                    .background(
                        Capsule()
                            .fill(Color.raidBackground.opacity(0.4))
                    )
                    .overlay(Capsule().stroke(Color.raidActive.opacity(0.45), lineWidth: 1))
                    .shadow(color: Color.black.opacity(0.35), radius: 10, x: 0, y: 5)
                }
                .padding(26)
                .raidElevatedCard(cornerRadius: 22, accent: .raidWaiting)
                .padding(.horizontal, 18)
            } else {
                List {
                    ForEach(bossesInGroup) { boss in
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
                    showEditGroup = true
                } label: {
                    Image(systemName: "pencil")
                }
                .accessibilityLabel("Edit group")
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
        .sheet(isPresented: $showEditGroup) {
            if let current = viewModel.groups.first(where: { $0.id == group.id }) {
                AddGroupView(viewModel: viewModel, existing: current)
            }
        }
        .sheet(isPresented: $showAddBoss, onDismiss: { bossToEdit = nil }) {
            AddBossView(viewModel: viewModel, existingBoss: bossToEdit)
        }
    }
}
