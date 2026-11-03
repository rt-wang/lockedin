import SwiftUI
import UIKit

struct HomeProfileLauncher: View {
  @Environment(\.foqosPalette) private var palette

  let activeProfile: BlockedProfiles?
  let displayTime: TimeInterval
  var isBreakActive = false
  var isPauseActive = false
  let onStartTapped: () -> Void
  var onActiveTapped: () -> Void = {}

  var body: some View {
    Group {
      if let activeProfile {
        activeProfileButton(activeProfile)
      } else {
        FoqosLineButton(title: "Start a session", action: onStartTapped)
          .accessibilityLabel("Start Profile")
      }
    }
    .padding(.horizontal, 24)
    .padding(.top, 18)
    .padding(.bottom, 8)
    .background {
      LinearGradient(
        stops: [
          .init(color: palette.background.opacity(0), location: 0),
          .init(color: palette.background, location: 0.2),
        ],
        startPoint: .top,
        endPoint: .bottom
      )
      .ignoresSafeArea(edges: .bottom)
    }
  }

  private func activeProfileButton(_ profile: BlockedProfiles) -> some View {
    Button(action: activeTapped) {
      VStack(alignment: .leading, spacing: 0) {
        FoqosHairline(isStrong: true)

        HStack(alignment: .firstTextBaseline, spacing: 12) {
          VStack(alignment: .leading, spacing: 4) {
            Text(activeStateTitle)
              .foqosText(.mark)
              .foregroundStyle(palette.mute)

            Text(profile.name)
              .foqosDisplay(size: 26)
              .lineLimit(1)
              .minimumScaleFactor(0.7)
          }

          Spacer(minLength: 12)

          Text(DateFormatters.formatDurationClock(displayTime))
            .foqosText(.cta)
            .monospacedDigit()
            .lineLimit(1)
            .contentTransition(.numericText())
            .animation(.default, value: displayTime)

          Text("→")
            .foqosText(.cta)
            .accessibilityHidden(true)
        }
        .padding(.top, 14)
        .padding(.bottom, 4)
      }
      .contentShape(Rectangle())
    }
    .buttonStyle(FoqosPressStyle())
    .accessibilityLabel(activeAccessibilityLabel(for: profile))
    .accessibilityValue(DateFormatters.formatDurationClock(displayTime))
  }

  private var activeStateTitle: String {
    if isPauseActive {
      return "Paused"
    }
    if isBreakActive {
      return "On a break"
    }
    return "Session active"
  }

  private func activeTapped() {
    UIImpactFeedbackGenerator(style: .light).impactOccurred()
    onActiveTapped()
  }

  private func activeAccessibilityLabel(for profile: BlockedProfiles) -> String {
    "\(activeStateTitle), profile \(profile.name)"
  }
}

#Preview("Inactive") {
  VStack {
    Spacer()
    HomeProfileLauncher(
      activeProfile: nil,
      displayTime: 0,
      onStartTapped: {}
    )
  }
  .foqosTheme(.cream)
}

#Preview("Active") {
  VStack {
    Spacer()
    HomeProfileLauncher(
      activeProfile: BlockedProfiles(
        name: "Work Focus",
        blockingStrategyId: ManualBlockingStrategy.id,
        enableLiveActivity: true,
        reminderTimeInSeconds: 3600,
        enableBreaks: true,
        domains: ["example.com", "social.example"]
      ),
      displayTime: 3665,
      onStartTapped: {}
    )
  }
  .foqosTheme(.cream)
}

#Preview("Paused") {
  VStack {
    Spacer()
    HomeProfileLauncher(
      activeProfile: BlockedProfiles(
        name: "Work Focus",
        blockingStrategyId: NFCPauseTimerBlockingStrategy.id,
        enableLiveActivity: true,
        reminderTimeInSeconds: 3600,
        enableBreaks: true,
        domains: ["example.com", "social.example"]
      ),
      displayTime: 900,
      isPauseActive: true,
      onStartTapped: {}
    )
  }
  .foqosTheme(.cream)
}
