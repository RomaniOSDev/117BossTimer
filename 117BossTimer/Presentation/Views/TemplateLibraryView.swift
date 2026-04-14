//
//  TemplateLibraryView.swift
//  117BossTimer
//

import SwiftUI

struct TemplateLibraryView: View {
    @ObservedObject var viewModel: RaidWatchViewModel
    @State private var confirmPack: GameTemplatePack?
    @State private var didImportMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Starter packs use neutral names so you can rename bosses after import.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)

                ForEach(BossTemplateCatalog.packs) { pack in
                    packCard(pack)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 28)
        }
        .confirmationDialog(
            "Import “\(confirmPack?.title ?? "")”?",
            isPresented: Binding(
                get: { confirmPack != nil },
                set: { if !$0 { confirmPack = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Import") {
                if let pack = confirmPack {
                    viewModel.applyTemplatePack(pack)
                    didImportMessage = "Added \(pack.bosses.count) bosses to \(pack.gameDisplayName)."
                }
                confirmPack = nil
            }
            Button("Cancel", role: .cancel) { confirmPack = nil }
        }
        .alert("Imported", isPresented: Binding(
            get: { didImportMessage != nil },
            set: { if !$0 { didImportMessage = nil } }
        )) {
            Button("OK", role: .cancel) { didImportMessage = nil }
        } message: {
            Text(didImportMessage ?? "")
        }
    }

    private func packCard(_ pack: GameTemplatePack) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: pack.systemIcon)
                    .font(.title2)
                    .foregroundStyle(Color.raidActive)
                VStack(alignment: .leading, spacing: 4) {
                    Text(pack.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(pack.subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            Text("\(pack.bosses.count) bosses • \(pack.gameDisplayName)")
                .font(.caption.weight(.medium))
                .foregroundColor(.raidWaiting)

            Button {
                confirmPack = pack
            } label: {
                Text("Add to my games")
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(Color(red: 0.04, green: 0.06, blue: 0.1))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.raidActive)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .padding()
        .raidElevatedCard(cornerRadius: 20, accent: .raidActive)
    }
}
