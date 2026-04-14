//
//  OnboardingFlowView.swift
//  117BossTimer
//

import SwiftUI

struct OnboardingFlowView: View {
    @ObservedObject var viewModel: RaidWatchViewModel
    var onComplete: () -> Void

    @State private var page = 0
    private let lastPage = 3

    var body: some View {
        ZStack {
            RaidScreenBackground()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button("Skip") {
                        onComplete()
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.gray)
                    .padding(.trailing, 20)
                    .padding(.top, 8)
                }

                TabView(selection: $page) {
                    OnboardingPageView(
                        symbol: "calendar.badge.clock",
                        symbolColors: [Color.raidActive, Color.raidWaiting],
                        title: "Track every respawn",
                        message: "Add bosses, set respawn windows, and see who is ready, on cooldown, or spawning soon. Favorites and readiness stay on your Home dashboard."
                    )
                    .tag(0)

                    OnboardingPageView(
                        symbol: "hand.draw.fill",
                        symbolColors: [Color.raidUrgent, Color.raidActive],
                        title: "Log kills in one swipe",
                        message: "Mark a kill from the boss list or Home, build a clean history, and get reminders before the next window. Notifications can be tuned anytime in Settings."
                    )
                    .tag(1)

                    OnboardingPageView(
                        symbol: "person.3.fill",
                        symbolColors: [Color.raidWaiting, Color.raidActive],
                        title: "Organize your runs",
                        message: "Group bosses by game, build raid groups for the night, and export or reset your data when you need a fresh start."
                    )
                    .tag(2)

                    scenarioPage
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                pageDots

                if page < lastPage {
                    primaryButton
                        .padding(.horizontal, 24)
                        .padding(.bottom, 28)
                        .padding(.top, 8)
                } else {
                    scenarioButtons
                        .padding(.horizontal, 24)
                        .padding(.bottom, 28)
                        .padding(.top, 8)
                }
            }
        }
    }

    private var scenarioPage: some View {
        VStack(spacing: 28) {
            Spacer(minLength: 12)

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.raidActive.opacity(0.35), Color.clear],
                            center: .center,
                            startRadius: 10,
                            endRadius: 120
                        )
                    )
                    .frame(width: 220, height: 220)

                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 76, weight: .medium))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.raidActive, Color.raidWaiting],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            VStack(alignment: .leading, spacing: 14) {
                Text("Try a full raid evening")
                    .font(.title.bold())
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Load five demo bosses, a raid group, raid-night schedule, and sample history for charts — perfect for exploring Plan and statistics.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(22)
            .raidElevatedCard(cornerRadius: 22, accent: Color.raidActive)
            .padding(.horizontal, 20)

            Spacer(minLength: 24)
        }
    }

    private var scenarioButtons: some View {
        VStack(spacing: 12) {
            Button {
                viewModel.seedOnboardingEveningScenario()
                onComplete()
            } label: {
                Text("Load sample raid night")
                    .font(.headline.weight(.bold))
                    .foregroundColor(Color(red: 0.04, green: 0.06, blue: 0.1))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color.raidActive, Color.raidActive.opacity(0.82)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)

            Button {
                onComplete()
            } label: {
                Text("Start with empty slate")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.raidActive)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.plain)
        }
    }

    private var pageDots: some View {
        HStack(spacing: 10) {
            ForEach(0...lastPage, id: \.self) { index in
                Capsule()
                    .fill(index == page ? Color.raidActive : Color.white.opacity(0.22))
                    .frame(width: index == page ? 24 : 8, height: 8)
                    .animation(.easeInOut(duration: 0.25), value: page)
            }
        }
        .padding(.vertical, 16)
    }

    private var primaryButton: some View {
        Button {
            if page < lastPage {
                withAnimation(.easeInOut) {
                    page += 1
                }
            }
        } label: {
            Text("Next")
                .font(.headline.weight(.bold))
                .foregroundColor(Color(red: 0.04, green: 0.06, blue: 0.1))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [Color.raidActive, Color.raidActive.opacity(0.82)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.28), lineWidth: 1)
                )
                .shadow(color: Color.raidActive.opacity(0.45), radius: 14, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Page

private struct OnboardingPageView: View {
    let symbol: String
    let symbolColors: [Color]
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 28) {
            Spacer(minLength: 12)

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                symbolColors.first?.opacity(0.35) ?? Color.raidActive.opacity(0.35),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 120
                        )
                    )
                    .frame(width: 220, height: 220)

                Image(systemName: symbol)
                    .font(.system(size: 76, weight: .medium))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(
                        LinearGradient(
                            colors: symbolColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: (symbolColors.first ?? .raidActive).opacity(0.5), radius: 20, x: 0, y: 8)
            }

            VStack(alignment: .leading, spacing: 14) {
                Text(title)
                    .font(.title.bold())
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)

                Text(message)
                    .font(.body)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(22)
            .raidElevatedCard(cornerRadius: 22, accent: symbolColors.first ?? .raidActive)
            .padding(.horizontal, 20)

            Spacer(minLength: 24)
        }
    }
}

