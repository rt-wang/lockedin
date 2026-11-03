import SwiftData
import SwiftUI

struct HomeDashboardView: View {
  @EnvironmentObject private var strategyManager: StrategyManager

  let profiles: [BlockedProfiles]
  let sessions: [BlockedProfileSession]
  let alerts: [HomeAlert]
  let onSettingsTapped: () -> Void
  let onAlertTapped: (HomeAlert) -> Void
  let onGuidedCreationTapped: () -> Void
  let onAdvancedCreationTapped: () -> Void
  let onInsightsTapped: (DashboardInsightsContext) -> Void
  let onManageProfilesTapped: () -> Void
  let onStartProfile: (BlockedProfiles) -> Void
  let onStopProfile: (BlockedProfiles) -> Void
  let onEditProfile: (BlockedProfiles) -> Void
  let onProfileInsightsTapped: (BlockedProfiles) -> Void
  let onLauncherTapped: () -> Void
  let onActiveSessionTapped: () -> Void

  @State private var selectedProfileId: UUID?
  // Profile selection updates the expanded detail; closing the screen keeps Home on top.
  @State private var preferredCompactColumn: NavigationSplitViewColumn = .sidebar

  private var selectedProfile: BlockedProfiles? {
    profiles.first { $0.id == selectedProfileId } ?? profiles.first
  }

  var body: some View {
    HomeDashboardLayout(preferredCompactColumn: $preferredCompactColumn) { showsProfileInsights in
      dashboardContent(showsProfileInsights: showsProfileInsights)
    } insights: {
      profileInsights
        .toolbar(.visible, for: .navigationBar)
    }
  }

  private func dashboardContent(showsProfileInsights: Bool) -> some View {
    ScrollView(showsIndicators: false) {
      VStack(alignment: .leading, spacing: 0) {
        HomeHeaderView(onSettingsTapped: onSettingsTapped)
        .padding(.bottom, 22)

        hero(isCompact: showsProfileInsights)

        HomeAlertsView(alerts: alerts, onAlertTapped: onAlertTapped)
          .padding(.top, 22)

        if profiles.isEmpty {
          Welcome(
            onGuidedTap: createGuidedProfile,
            onAdvancedTap: createAdvancedProfile
          )
          .padding(.top, 8)
        } else {
          HomeProfilesListView(
            profiles: profiles,
            isBlocking: strategyManager.isBlocking,
            activeSessionProfileId: strategyManager.activeSession?.blockedProfile.id,
            elapsedTime: strategyManager.elapsedTime,
            isPauseActive: strategyManager.isPauseActive,
            isHardModeActionLocked:
              strategyManager.activeSession?.isSessionActionLockedByHardMode() ?? false,
            onManageTapped: onManageProfilesTapped,
            onStartTapped: onStartProfile,
            onStopTapped: onStopProfile,
            onEditTapped: onEditProfile,
            onStatsTapped: showsProfileInsights ? selectProfile : onProfileInsightsTapped,
            selectedProfileId: showsProfileInsights ? selectedProfile?.id : nil,
            onSelectProfile: showsProfileInsights ? selectProfile : nil
          )
          .padding(.top, 22)

          if !showsProfileInsights {
            BlockedSessionsHabitTracker(
              sessions: sessions,
              profiles: profiles,
              onInsightsTapped: onInsightsTapped
            )
            .padding(.top, 40)
          }
        }
      }
      .padding(.horizontal, 24)
      .padding(.bottom, 24)
    }
    .safeAreaInset(edge: .bottom) {
      if !profiles.isEmpty {
        HomeProfileLauncher(
          activeProfile: strategyManager.isBlocking
            ? strategyManager.activeSession?.blockedProfile : nil,
          displayTime: strategyManager.sessionDisplayTime,
          isBreakActive: strategyManager.isBreakActive,
          isPauseActive: strategyManager.isPauseActive,
          onStartTapped: onLauncherTapped,
          onActiveTapped: onActiveSessionTapped
        )
      }
    }
    .padding(.top, 1)
    .foqosTheme(.cream)
    .navigationTitle("Home")
    .toolbar(.hidden, for: .navigationBar)
  }

  private func hero(isCompact: Bool) -> some View {
    VStack(alignment: .leading, spacing: 0) {
      Text("Foqos")
        .foqosText(.eyebrow)
        .padding(.bottom, 14)

      VStack(alignment: .leading, spacing: -2) {
        Text("Stay present")
        Text("until you return")
          .italic()
          .foregroundStyle(FoqosPalette.cream.mute)
      }
      .foqosDisplay(size: isCompact ? 40 : 54)
      .fixedSize(horizontal: false, vertical: true)
      .accessibilityElement(children: .combine)
      .accessibilityAddTraits(.isHeader)
      .padding(.bottom, 22)

      VStack(alignment: .leading, spacing: 8) {
        Text(heroStatusTitle)
          .foqosText(.tab)
          .foregroundStyle(FoqosPalette.cream.foreground)

        Text(heroStatusMessage)
          .font(FoqosFont.ui(.subheadline, size: 15, bold: false))
          .foregroundStyle(FoqosPalette.cream.mute)
          .frame(maxWidth: 280, alignment: .leading)
          .fixedSize(horizontal: false, vertical: true)
      }
      .padding(.bottom, profiles.isEmpty ? 20 : 0)
      .accessibilityElement(children: .combine)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private var heroStatusTitle: String {
    if strategyManager.isPauseActive { return "Paused" }
    if strategyManager.isBreakActive { return "On a break" }
    return strategyManager.isBlocking ? "Session active" : "Ready"
  }

  private var heroStatusMessage: String {
    if let activeProfile = strategyManager.activeSession?.blockedProfile,
      strategyManager.isBlocking
    {
      return "\(activeProfile.name) is running. Apps stay shielded until you end it."
    }
    if profiles.isEmpty {
      return "Create a profile to choose which apps to lock."
    }
    return "Choose a profile, then start a session to lock its apps."
  }

  private var profileInsights: some View {
    Group {
      if let selectedProfile {
        ProfileInsightsContent(profile: selectedProfile)
          .id(selectedProfile.id)
      } else {
        ContentUnavailableView(
          "No Profiles",
          systemImage: "chart.line.uptrend.xyaxis",
          description: Text("Create a profile to see its focus insights here.")
        )
      }
    }
  }

  private func selectProfile(_ profile: BlockedProfiles) {
    selectedProfileId = profile.id
  }

  private func createGuidedProfile() {
    guard !strategyManager.isBlocking else { return }
    onGuidedCreationTapped()
  }

  private func createAdvancedProfile() {
    guard !strategyManager.isBlocking else { return }
    onAdvancedCreationTapped()
  }
}

private struct HomeDashboardPreview: View {
  let hasProfiles: Bool
  private let container: ModelContainer
  private let profile: BlockedProfiles
  private let session: BlockedProfileSession

  init(hasProfiles: Bool) {
    self.hasProfiles = hasProfiles
    do {
      container = try ModelContainer(
        for: BlockedProfiles.self, BlockedProfileSession.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
      )
      profile = BlockedProfiles(
        name: "Deep Work",
        blockingStrategyId: ManualBlockingStrategy.id,
        domains: ["example.com"]
      )
      session = BlockedProfileSession(tag: ManualBlockingStrategy.id, blockedProfile: profile)
      session.startTime = Date().addingTimeInterval(-3600)
      session.endTime = Date()
      container.mainContext.insert(profile)
      container.mainContext.insert(session)
      try container.mainContext.save()
    } catch {
      fatalError("Failed to create dashboard preview: \(error)")
    }
  }

  var body: some View {
    HomeDashboardView(
      profiles: hasProfiles ? [profile] : [],
      sessions: hasProfiles ? [session] : [],
      alerts: [],
      onSettingsTapped: {},
      onAlertTapped: { _ in },
      onGuidedCreationTapped: {},
      onAdvancedCreationTapped: {},
      onInsightsTapped: { _ in },
      onManageProfilesTapped: {},
      onStartProfile: { _ in },
      onStopProfile: { _ in },
      onEditProfile: { _ in },
      onProfileInsightsTapped: { _ in },
      onLauncherTapped: {},
      onActiveSessionTapped: {}
    )
    .modelContainer(container)
    .environmentObject(StrategyManager())
    .defaultAppStorage(UserDefaults(suiteName: "home-dashboard-preview")!)
  }
}

#Preview("Dashboard") {
  HomeDashboardPreview(hasProfiles: true)
}

#Preview("Empty Dashboard") {
  HomeDashboardPreview(hasProfiles: false)
}
