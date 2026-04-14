//
//  BossTimerWidgets.swift
//  BossTimerWidgets
//

import SwiftUI
import WidgetKit

@main
struct BossTimerWidgetsBundle: WidgetBundle {
    var body: some Widget {
        NextRespawnsWidget()
        FavoriteBossesWidget()
        InWindowWidget()
        RespawnLiveActivity()
    }
}
