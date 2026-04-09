//
//  SettingsView.swift
//  117BossTimer
//

import StoreKit
import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct SettingsView: View {
    @ObservedObject var viewModel: RaidWatchViewModel

    @State private var showResetConfirmation = false
    @State private var showShare = false
    @State private var exportURL: URL?
    @State private var showImportPicker = false
    @State private var importError: String?

    var body: some View {
        NavigationStack {
            ZStack {
                RaidScreenBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Notifications")
                                .font(.headline)
                                .foregroundColor(.raidActive)

                            Toggle("Enable notifications", isOn: $viewModel.notificationsEnabled)
                                .tint(.raidActive)
                                .onChange(of: viewModel.notificationsEnabled) { _ in
                                    viewModel.updateAllNotifications()
                                }

                            if viewModel.notificationsEnabled {
                                HStack {
                                    Text("Remind me before")
                                        .foregroundColor(.white)
                                    Spacer()
                                    Picker("", selection: $viewModel.reminderMinutes) {
                                        Text("5 min").tag(5)
                                        Text("10 min").tag(10)
                                        Text("15 min").tag(15)
                                        Text("30 min").tag(30)
                                        Text("1 hour").tag(60)
                                    }
                                    .pickerStyle(.menu)
                                    .tint(.raidActive)
                                    .onChange(of: viewModel.reminderMinutes) { _ in
                                        viewModel.updateAllNotifications()
                                    }
                                }
                            }
                        }
                        .padding()
                        .raidElevatedCard(cornerRadius: 20, accent: .raidActive)
                        .padding(.horizontal)

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Data")
                                .font(.headline)
                                .foregroundColor(.raidActive)

                            Button("Export data") {
                                exportData()
                            }
                            .foregroundColor(.raidActive)

                            Button("Import data") {
                                showImportPicker = true
                            }
                            .foregroundColor(.raidActive)

                            Button("Reset all data") {
                                showResetConfirmation = true
                            }
                            .foregroundColor(.raidUrgent)
                        }
                        .padding()
                        .raidElevatedCard(cornerRadius: 20, accent: .raidUrgent)
                        .padding(.horizontal)

                        VStack(alignment: .leading, spacing: 12) {
                            Text("About")
                                .font(.headline)
                                .foregroundColor(.raidActive)

                            settingsLinkRow(title: "Rate us", systemImage: "star.fill") {
                                rateApp()
                            }

                            settingsLinkRow(title: "Privacy Policy", systemImage: "hand.raised.fill") {
                                openPolicy()
                            }

                            settingsLinkRow(title: "Terms of Use", systemImage: "doc.text.fill") {
                                openTerms()
                            }
                        }
                        .padding()
                        .raidElevatedCard(cornerRadius: 20, accent: .raidWaiting)
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color.raidBackground.opacity(0.92), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .tint(.raidActive)
            .confirmationDialog(
                "Reset all data?",
                isPresented: $showResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Reset", role: .destructive) {
                    viewModel.resetAllData()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This removes bosses, games, groups, and history on this device. Demo data will be loaded again.")
            }
            .sheet(isPresented: $showShare) {
                if let url = exportURL {
                    ActivityView(activityItems: [url])
                }
            }
            .fileImporter(
                isPresented: $showImportPicker,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else { return }
                    importFromURL(url)
                case .failure(let error):
                    importError = error.localizedDescription
                }
            }
            .alert("Import failed", isPresented: Binding(
                get: { importError != nil },
                set: { if !$0 { importError = nil } }
            )) {
                Button("OK", role: .cancel) { importError = nil }
            } message: {
                if let importError {
                    Text(importError)
                }
            }
        }
    }

    private func settingsLinkRow(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color.raidActive)
                    .frame(width: 26)
                Text(title)
                    .font(.body.weight(.medium))
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.gray.opacity(0.6))
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }

    private func openPolicy() {
        if let url = AppExternalLink.privacyPolicy.url {
            UIApplication.shared.open(url)
        }
    }

    private func openTerms() {
        if let url = AppExternalLink.termsOfUse.url {
            UIApplication.shared.open(url)
        }
    }

    private func exportData() {
        let payload = viewModel.exportBundle()
        do {
            let data = try JSONEncoder().encode(payload)
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("boss-timer-export.json")
            try data.write(to: url, options: .atomic)
            exportURL = url
            showShare = true
        } catch {
            importError = error.localizedDescription
        }
    }

    private func importFromURL(_ url: URL) {
        do {
            let accessed = url.startAccessingSecurityScopedResource()
            defer {
                if accessed { url.stopAccessingSecurityScopedResource() }
            }
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(RaidWatchExport.self, from: data)
            viewModel.applyImport(decoded)
        } catch {
            importError = error.localizedDescription
        }
    }
}
