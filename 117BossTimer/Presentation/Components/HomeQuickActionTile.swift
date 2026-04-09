//
//  HomeQuickActionTile.swift
//  117BossTimer
//

import SwiftUI

struct HomeQuickActionTile: View {
    let title: String
    let systemImage: String
    let accent: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.title2)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [accent, accent.opacity(0.65)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: accent.opacity(0.4), radius: 8, x: 0, y: 2)
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .raidSubtleTile(cornerRadius: 16, accent: accent)
        }
        .buttonStyle(.plain)
    }
}
