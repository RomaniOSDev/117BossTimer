//
//  StatCard.swift
//  117BossTimer
//

import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: color.opacity(0.35), radius: 4, x: 0, y: 1)
                Text(title)
                    .foregroundColor(.gray)
                    .font(.caption)
            }

            Text(value)
                .foregroundColor(.white)
                .font(.title2)
                .bold()
        }
        .padding()
        .frame(width: 140, alignment: .leading)
        .raidSubtleTile(cornerRadius: 14, accent: color)
    }
}
