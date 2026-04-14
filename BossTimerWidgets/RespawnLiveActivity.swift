//
//  RespawnLiveActivity.swift
//  BossTimerWidgets
//

import ActivityKit
import SwiftUI
import WidgetKit

struct RespawnLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RespawnActivityAttributes.self) { context in
            VStack(alignment: .leading, spacing: 6) {
                Text(context.attributes.bossName)
                    .font(.headline)
                Text("Until next beat")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(context.state.endDate, style: .timer)
                    .font(.title2.monospacedDigit().weight(.bold))
            }
            .padding()
            .activityBackgroundTint(Color(red: 0.08, green: 0.1, blue: 0.16))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.attributes.bossName)
                        .font(.headline)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.endDate, style: .timer)
                        .font(.title3.monospacedDigit().weight(.semibold))
                }
            } compactLeading: {
                Image(systemName: "flame.fill")
            } compactTrailing: {
                Text(context.state.endDate, style: .timer)
                    .monospacedDigit()
                    .font(.caption2)
            } minimal: {
                Image(systemName: "timer")
            }
        }
    }
}
