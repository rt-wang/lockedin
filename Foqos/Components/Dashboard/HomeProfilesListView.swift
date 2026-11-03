import SwiftUI

struct HomeProfilesListView: View {
  let profiles: [BlockedProfiles]
  let isBlocking: Bool
  let activeSessionProfileId: UUID?
  let elapsedTime: TimeInterval
  let isPauseActive: Bool
  var isHardModeActionLocked: Bool = false
  let onManageTapped: () -> Void
  let onStartTapped: (BlockedProfiles) -> Void
  let onStopTapped: (BlockedProfiles) -> Void
  let onEditTapped: (BlockedProfiles) -> Void
  let onStatsTapped: (BlockedProfiles) -> Void
  var selectedProfileId: UUID? = nil
  var onSelectProfile: ((BlockedProfiles) -> Void)? = nil

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      SectionTitle(
        "Profiles",
        buttonText: "Manage",
        buttonAction: onManageTapped
      )

      FoqosHairline()

      ForEach(profiles) { profile in
        HomeProfileRow(
          profile: profile,
          isBlocking: isBlocking,
          isActive: profile.id == activeSessionProfileId,
          elapsedTime: elapsedTime,
          isPauseActive: isPauseActive,
          isHardModeActionLocked: isHardModeActionLocked,
          isSelected: profile.id == selectedProfileId,
          selectsInsights: onSelectProfile != nil,
          onSelected: {
            onSelectProfile?(profile)
          },
          onStartTapped: {
            onStartTapped(profile)
          },
          onStopTapped: {
            onStopTapped(profile)
          },
          onEditTapped: {
            onEditTapped(profile)
          },
          onStatsTapped: {
            onStatsTapped(profile)
          }
        )

        FoqosHairline()
      }
    }
  }
}

private struct HomeProfileRow: View {
  @Environment(\.foqosPalette) private var palette

  let profile: BlockedProfiles
  let isBlocking: Bool
  let isActive: Bool
  let elapsedTime: TimeInterval
  let isPauseActive: Bool
  let isHardModeActionLocked: Bool
  let isSelected: Bool
  let selectsInsights: Bool
  let onSelected: () -> Void
  let onStartTapped: () -> Void
  let onStopTapped: () -> Void
  let onEditTapped: () -> Void
  let onStatsTapped: () -> Void

  private var canStart: Bool {
    !isBlocking
  }

  private var canStop: Bool {
    profile.showStopButton(elapsedTime: elapsedTime) && !isHardModeActionLocked
  }

  private var blockingStrategy: BlockingStrategy? {
    guard let strategyId = profile.blockingStrategyId else { return nil }
    return StrategyManager.getStrategyFromId(id: strategyId)
  }

  private var activeAction: BlockingStrategySessionAction {
    blockingStrategy?.activeSessionAction(
      isPauseActive: isPauseActive,
      isEnabled: canStop
    ) ?? .stop(isEnabled: canStop)
  }

  private var metadataText: String {
    let appCount = FamilyActivityUtil.countSelectedActivities(
      profile.selectedActivity,
      allowMode: profile.enableAllowMode
    )
    let domainCount = profile.domains?.count ?? 0
    var parts = [
      countLabel(appCount, singular: "app", plural: "apps"),
      countLabel(domainCount, singular: "domain", plural: "domains"),
    ]
    if let blockingStrategy {
      parts.append(blockingStrategy.name)
    }
    return parts.joined(separator: " · ")
  }

  private var scheduleText: String? {
    guard let schedule = profile.schedule, schedule.isActive else { return nil }
    return schedule.nextStartMessage(includePrefix: false)
  }

  private var markText: String? {
    if isActive { return isPauseActive ? "Paused" : "Active" }
    if isSelected { return "Selected" }
    return nil
  }

  private var isDimmed: Bool {
    (selectsInsights && !isSelected) || (isBlocking && !isActive)
  }

  var body: some View {
    HStack(alignment: .firstTextBaseline, spacing: 12) {
      Button(action: selectsInsights ? onSelected : onEditTapped) {
        VStack(alignment: .leading, spacing: 6) {
          HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(profile.name)
              .foqosDisplay(size: 30)
              .lineLimit(2)
              .multilineTextAlignment(.leading)
              .frame(maxWidth: .infinity, alignment: .leading)

            if let markText {
              Text(markText)
                .foqosText(.mark)
            }
          }

          Text(metadataText)
            .foqosText(.caption)
            .foregroundStyle(palette.mute)
            .lineLimit(2)
            .multilineTextAlignment(.leading)

          if let scheduleText {
            Text(scheduleText)
              .foqosText(.caption)
              .foregroundStyle(palette.mute)
              .lineLimit(1)
              .minimumScaleFactor(0.82)
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
      }
      .buttonStyle(FoqosPressStyle())
      .accessibilityElement(children: .combine)
      .accessibilityLabel(
        selectsInsights ? "Show \(profile.name) insights" : "Edit \(profile.name)"
      )
      .accessibilityValue([markText, metadataText].compactMap { $0 }.joined(separator: ", "))
      .accessibilityAddTraits(isSelected ? [.isSelected] : [])

      actionMenu
    }
    .padding(.vertical, 14)
    .frame(maxWidth: .infinity)
    .opacity(isDimmed ? 0.5 : 1)
    .animation(.easeOut(duration: 0.25), value: isDimmed)
  }

  private func countLabel(_ count: Int, singular: String, plural: String) -> String {
    "\(count) \(count == 1 ? singular : plural)"
  }

  private var actionMenu: some View {
    Menu {

      Button(action: onStatsTapped) {
        Label("Insights", systemImage: "chart.line.uptrend.xyaxis")
      }

      Button(action: onEditTapped) {
        Label("Edit", systemImage: "pencil")
      }

      if isActive {
        Button(action: onStopTapped) {
          Label(activeAction.title, systemImage: activeAction.systemImageName)
        }
        .disabled(!canStop)
      } else {
        Button(action: onStartTapped) {
          Label("Start", systemImage: "play.fill")
        }
        .disabled(!canStart)
      }
    } label: {
      Image(systemName: "ellipsis")
        .font(.system(size: 15, weight: .regular))
        .foregroundStyle(palette.mute)
        .frame(width: 32, height: 44)
        .contentShape(Rectangle())
    }
    .accessibilityLabel("More actions for \(profile.name)")
  }
}
