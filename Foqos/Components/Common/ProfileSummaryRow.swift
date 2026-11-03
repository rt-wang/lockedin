import Foundation
import SwiftUI

enum ProfileSummaryMetadata {
  case none
  case appsAndDomains
  case updatedAt(Date)

  var isVisible: Bool {
    switch self {
    case .none:
      return false
    case .appsAndDomains, .updatedAt:
      return true
    }
  }
}

enum ProfileSummaryLayout: Equatable {
  case dashboard
  case compact
}

enum ProfileSummaryStatusMode: Equatable {
  case scheduleOnly
  case scheduleOrIndicators
}

struct ProfileSummaryContent: View {
  @Environment(\.foqosPalette) private var palette

  let profile: BlockedProfiles
  let isActive: Bool
  let metadata: ProfileSummaryMetadata
  let showsStatusLine: Bool
  let layout: ProfileSummaryLayout
  let statusMode: ProfileSummaryStatusMode

  private var blockingStrategy: BlockingStrategy? {
    guard let strategyId = profile.blockingStrategyId else {
      return nil
    }
    return StrategyManager.getStrategyFromId(id: strategyId)
  }

  private var iconSize: CGFloat {
    switch layout {
    case .dashboard:
      return 34
    case .compact:
      return 26
    }
  }

  private var iconFontSize: CGFloat {
    switch layout {
    case .dashboard:
      return 17
    case .compact:
      return 15
    }
  }

  private var contentSpacing: CGFloat {
    switch layout {
    case .dashboard:
      return 6
    case .compact:
      return 4
    }
  }

  private var titleSize: CGFloat {
    switch layout {
    case .dashboard:
      return 26
    case .compact:
      return 22
    }
  }

  var body: some View {
    HStack(spacing: layout == .dashboard ? 12 : 10) {
      BlockingStrategyIconImage(strategy: blockingStrategy)
        .font(.system(size: iconFontSize, weight: .semibold))
        .foregroundStyle(palette.mute)
        .frame(width: iconSize, height: iconSize)

      VStack(alignment: .leading, spacing: contentSpacing) {
        ViewThatFits(in: .horizontal) {
          if isActive {
            HStack(spacing: 7) {
              profileTitle
              activeChip
            }
            .fixedSize(horizontal: true, vertical: false)
          }

          profileTitle
        }

        if metadata.isVisible {
          ProfileSummaryMetadataLine(profile: profile, metadata: metadata)
        }

        if showsStatusLine {
          ProfileSummaryStatusLine(profile: profile, mode: statusMode)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .layoutPriority(1)
    }
  }

  private var activeChip: some View {
    Text("Active")
      .foqosText(.mark)
      .foregroundStyle(palette.foreground)
      .padding(.bottom, 3)
      .overlay(alignment: .bottom) {
        Rectangle()
          .fill(palette.foreground)
          .frame(height: 1)
      }
  }

  private var profileTitle: some View {
    Text(profile.name)
      .foqosDisplay(size: titleSize)
      .foregroundStyle(palette.foreground)
      .lineLimit(1)
  }
}

private struct ProfileSummaryMetadataLine: View {
  @Environment(\.foqosPalette) private var palette

  let profile: BlockedProfiles
  let metadata: ProfileSummaryMetadata

  private var selectedItemsCount: Int {
    FamilyActivityUtil.countSelectedActivities(
      profile.selectedActivity,
      allowMode: profile.enableAllowMode
    )
  }

  private var domainsCount: Int {
    profile.domains?.count ?? 0
  }

  private var metadataText: String {
    switch metadata {
    case .none:
      return ""
    case .appsAndDomains:
      return
        "\(countLabel(selectedItemsCount, singular: "App", plural: "Apps")) · \(countLabel(domainsCount, singular: "Domain", plural: "Domains"))"
    case .updatedAt(let date):
      let formatter = RelativeDateTimeFormatter()
      formatter.unitsStyle = .short
      return "Updated \(formatter.localizedString(for: date, relativeTo: Date()))"
    }
  }

  var body: some View {
    Text(metadataText)
      .foqosText(.mark)
      .foregroundStyle(palette.mute)
      .lineLimit(1)
  }

  private func countLabel(_ count: Int, singular: String, plural: String) -> String {
    "\(count) \(count == 1 ? singular : plural)"
  }
}

private struct ProfileSummaryStatusLine: View {
  let profile: BlockedProfiles
  let mode: ProfileSummaryStatusMode

  var body: some View {
    if let schedule = profile.schedule, schedule.isActive {
      ProfileSummaryNextScheduleLine(schedule: schedule)
    } else if mode == .scheduleOrIndicators {
      ProfileSummaryCompactIndicators(
        enableLiveActivity: profile.enableLiveActivity,
        hasReminders: profile.reminderTimeInSeconds != nil,
        enableBreaks: profile.enableBreaks,
        enableStrictMode: profile.enableStrictMode
      )
    }
  }
}

private struct ProfileSummaryNextScheduleLine: View {
  @Environment(\.foqosPalette) private var palette

  let schedule: BlockedProfileSchedule

  var body: some View {
    if let message = schedule.nextStartMessage(includePrefix: false) {
      Text(message)
        .foqosText(.caption)
        .lineLimit(1)
        .minimumScaleFactor(0.82)
        .foregroundStyle(palette.mute)
    }
  }
}

private struct ProfileSummaryCompactIndicators: View {
  @Environment(\.foqosPalette) private var palette

  let enableLiveActivity: Bool
  let hasReminders: Bool
  let enableBreaks: Bool
  let enableStrictMode: Bool

  private var indicators: [String] {
    var values: [String] = []

    if enableBreaks {
      values.append("Breaks")
    }
    if enableStrictMode {
      values.append("Deletion Blocked")
    }
    if enableLiveActivity {
      values.append("Live Activity")
    }
    if hasReminders {
      values.append("Reminders")
    }

    return values
  }

  var body: some View {
    if !indicators.isEmpty {
      HStack(spacing: 12) {
        ForEach(Array(indicators.prefix(3)), id: \.self) { label in
          HStack(spacing: 5) {
            Circle()
              .fill(palette.foreground)
              .frame(width: 4, height: 4)

            Text(label)
              .foqosText(.caption)
              .foregroundStyle(palette.mute)
              .lineLimit(1)
          }
        }
      }
      .minimumScaleFactor(0.78)
    }
  }
}
