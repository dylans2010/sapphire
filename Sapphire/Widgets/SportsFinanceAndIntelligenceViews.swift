//
//  SportsFinanceAndIntelligenceViews.swift
//  Sapphire
//

import SwiftUI

struct SportsWidgetView: View {
    @EnvironmentObject private var settings: SettingsModel

    private var teamName: String {
        settings.settings.currentSportsTeam() ?? "Sports"
    }

    var body: some View {
        CompactNotchTile(
            systemImage: "sportscourt.fill",
            title: teamName,
            subtitle: "Scores",
            accent: Color.orange
        )
    }
}

struct FinanceWidgetView: View {
    @EnvironmentObject private var settings: SettingsModel

    private var symbol: String {
        settings.settings.currentFinanceFavoriteSymbol()?.uppercased() ?? "Markets"
    }

    var body: some View {
        CompactNotchTile(
            systemImage: "chart.line.uptrend.xyaxis",
            title: symbol,
            subtitle: "Quote",
            accent: Color.green
        )
    }
}

struct SportsPlayerView: View {
    @Binding var navigationStack: [NotchWidgetMode]
    @EnvironmentObject private var settings: SettingsModel

    private var teamName: String {
        settings.settings.currentSportsTeam() ?? "Favorite Team"
    }

    var body: some View {
        DetailNotchPanel(
            title: "Sports",
            subtitle: teamName,
            systemImage: "sportscourt.fill",
            accent: Color.orange,
            navigationStack: $navigationStack
        ) {
            Text("Live scores will appear here when available.")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
        }
    }
}

struct FinancePlayerView: View {
    @Binding var navigationStack: [NotchWidgetMode]
    @EnvironmentObject private var settings: SettingsModel

    private var symbol: String {
        settings.settings.currentFinanceFavoriteSymbol()?.uppercased() ?? "Markets"
    }

    var body: some View {
        DetailNotchPanel(
            title: "Finance",
            subtitle: symbol,
            systemImage: "chart.line.uptrend.xyaxis",
            accent: Color.green,
            navigationStack: $navigationStack
        ) {
            Text("Market quotes will appear here when available.")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
        }
    }
}

struct IntelligenceNotchView: View {
    @Binding var navigationStack: [NotchWidgetMode]
    @EnvironmentObject private var intelligenceVM: IntelligenceNotchViewModel

    var body: some View {
        DetailNotchPanel(
            title: "Blip",
            subtitle: "Intelligence",
            systemImage: "sparkle",
            accent: Color.cyan,
            navigationStack: $navigationStack
        ) {
            TextField("Ask Blip…", text: $intelligenceVM.taskInput)
                .textFieldStyle(.plain)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
}

struct BlipHubView: View {
    @Binding var navigationStack: [NotchWidgetMode]

    var body: some View {
        DetailNotchPanel(
            title: "Blip Hub",
            subtitle: "Quick actions",
            systemImage: "sparkles.rectangle.stack.fill",
            accent: Color.purple,
            navigationStack: $navigationStack
        ) {
            HStack(spacing: 10) {
                Button("Ask") { navigationStack.append(.agentS) }
                Button("Search") { navigationStack.append(.circleToSearch) }
            }
            .buttonStyle(.borderless)
            .foregroundStyle(.white)
        }
    }
}

struct CircleToSearchResultsView: View {
    @Binding var navigationStack: [NotchWidgetMode]

    var body: some View {
        DetailNotchPanel(
            title: "Circle to Search",
            subtitle: "Results",
            systemImage: "viewfinder.circle.fill",
            accent: Color.blue,
            navigationStack: $navigationStack
        ) {
            Text("Search results will appear here after selecting an area.")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
        }
    }
}

private struct CompactNotchTile: View {
    let systemImage: String
    let title: String
    let subtitle: String
    let accent: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(accent)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text(subtitle)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.6))
                    .lineLimit(1)
            }
        }
        .frame(width: 110, height: 46)
    }
}

private struct DetailNotchPanel<Content: View>: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let accent: Color
    @Binding var navigationStack: [NotchWidgetMode]
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Button {
                    if navigationStack.count > 1 {
                        navigationStack.removeLast()
                    } else {
                        navigationStack = [.defaultWidgets]
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 13, weight: .bold))
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white.opacity(0.85))

                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(accent)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                }

                Spacer(minLength: 0)
            }

            content
        }
        .frame(width: 360)
        .padding(18)
    }
}
