//
//  RaidGroupsView.swift
//  117BossTimer
//

import SwiftUI

struct RaidGroupsView: View {
    @ObservedObject var viewModel: RaidWatchViewModel
    @State private var showAddGroupSheet = false
    @State private var groupToEdit: RaidGroup?

    var body: some View {
        NavigationStack {
            ZStack {
                RaidScreenBackground()

                List {
                    ForEach(viewModel.groups) { group in
                        NavigationLink(value: group) {
                            GroupCard(group: group, viewModel: viewModel)
                        }
                        .buttonStyle(.plain)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .contextMenu {
                            Button("Edit group") {
                                groupToEdit = group
                            }
                            Button("Start") {
                                viewModel.startGroup(group)
                            }
                            Divider()
                            Button("Delete", role: .destructive) {
                                viewModel.deleteGroup(group)
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                viewModel.deleteGroup(group)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }

                            Button {
                                viewModel.startGroup(group)
                            } label: {
                                Label("Start", systemImage: "play.fill")
                            }
                            .tint(.raidActive)
                        }
                    }

                    Button {
                        showAddGroupSheet = true
                    } label: {
                        Text("Create group")
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
            .navigationTitle("Raid groups")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color.raidBackground.opacity(0.92), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .tint(.raidActive)
            .navigationDestination(for: RaidGroup.self) { group in
                GroupBossesView(group: group, viewModel: viewModel)
            }
            .sheet(isPresented: $showAddGroupSheet) {
                AddGroupView(viewModel: viewModel)
            }
            .sheet(item: $groupToEdit) { group in
                AddGroupView(viewModel: viewModel, existing: group)
            }
        }
    }
}
