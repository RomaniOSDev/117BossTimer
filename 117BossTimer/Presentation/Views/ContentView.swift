//
//  ContentView.swift
//  117BossTimer
//
//  Created by Роман Главацкий on 06.04.2026.
//

import SwiftUI
import UIKit
import UserNotifications

struct ContentView: View {
    @StateObject private var viewModel = RaidWatchViewModel()
    @State private var selectedTab = 0
    @AppStorage("raidwatch_onboarding_completed") private var onboardingCompleted = false

    var body: some View {
        Group {
            if onboardingCompleted {
                mainTabView
            } else {
                OnboardingFlowView(viewModel: viewModel) {
                    onboardingCompleted = true
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            skipOnboardingIfExistingData()
        }
    }

    /// Users who already have saved data should not see onboarding again after an app update.
    private func skipOnboardingIfExistingData() {
        guard !onboardingCompleted else { return }
        if UserDefaults.standard.data(forKey: "raidwatch_games") != nil
            || AppConfiguration.sharedDefaults.data(forKey: "raidwatch_games") != nil {
            onboardingCompleted = true
        }
    }

    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            HomeView(viewModel: viewModel, selectedTab: $selectedTab)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            BossListView(viewModel: viewModel)
                .tabItem {
                    Label("Bosses", systemImage: "list.bullet")
                }
                .tag(1)

            GamesView(viewModel: viewModel)
                .tabItem {
                    Label("Games", systemImage: "gamecontroller.fill")
                }
                .tag(2)

            RaidGroupsView(viewModel: viewModel)
                .tabItem {
                    Label("Groups", systemImage: "person.3.fill")
                }
                .tag(3)

            KillLogView(viewModel: viewModel)
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
                .tag(4)

            SettingsView(viewModel: viewModel)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(5)

            PlanHubView(viewModel: viewModel)
                .tabItem {
                    Label("Plan", systemImage: "calendar.badge.clock")
                }
                .tag(6)
        }
        .tint(.raidActive)
        .onAppear {
            styleTabBarAppearance()
            viewModel.loadFromUserDefaults()
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
        }
    }

    private func styleTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.05, green: 0.065, blue: 0.11, alpha: 0.96)
        appearance.shadowColor = UIColor.black.withAlphaComponent(0.45)
        appearance.shadowImage = UIImage()
        let accent = UIColor(Color.raidActive)
        let inactive = UIColor.lightGray.withAlphaComponent(0.55)
        let item = UITabBarItemAppearance()
        item.normal.iconColor = inactive
        item.normal.titleTextAttributes = [.foregroundColor: inactive]
        item.selected.iconColor = accent
        item.selected.titleTextAttributes = [.foregroundColor: accent]
        appearance.stackedLayoutAppearance = item
        appearance.inlineLayoutAppearance = item
        appearance.compactInlineLayoutAppearance = item
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    ContentView()
}
