import SwiftUI

struct ProfileActivityView: View {
  @Environment(\.foqosPalette) private var palette

  let selectedDate: Date
  let activities: [DashboardProfileActivity]
  let viewMode: InsightsViewMode
  let onInsightsTapped: (DashboardInsightsContext) -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      Text(DateFormatters.formatDashboardDate(selectedDate))
        .foqosText(.eyebrow)
        .foregroundStyle(palette.mute)
        .padding(.bottom, 10)

      FoqosHairline()

      ForEach(activities) { activity in
        profileActivityRow(for: activity)

        FoqosHairline()
      }
    }
    .padding(.top, 8)
    .padding(.bottom, 16)
    .transition(.move(edge: .bottom).combined(with: .opacity))
  }

  private func profileActivityRow(for activity: DashboardProfileActivity) -> some View {
    HStack(alignment: .firstTextBaseline, spacing: 12) {
      Text(activity.profile.name)
        .foqosDisplay(size: 22)
        .lineLimit(1)

      Spacer()

      Text(DateFormatters.formatDurationShort(activity.totalTime))
        .foqosText(.caption)
        .monospacedDigit()
        .foregroundStyle(palette.mute)

      Button {
        let context = DashboardInsightsContext(
          profile: activity.profile,
          viewMode: viewMode,
          selectedDate: selectedDate
        )
        onInsightsTapped(context)
      } label: {
        Text("View →")
          .foqosText(.mark)
          .frame(minHeight: 44)
          .contentShape(Rectangle())
      }
      .buttonStyle(FoqosPressStyle())
      .accessibilityLabel("View \(activity.profile.name) insights")
    }
    .padding(.vertical, 6)
  }
}

#Preview {
  let profile1 = BlockedProfiles(name: "Deep Work")
  let profile2 = BlockedProfiles(name: "Social Media Block")

  let activities = [
    DashboardProfileActivity(profile: profile1, totalTime: 7200, sessionCount: 2),
    DashboardProfileActivity(profile: profile2, totalTime: 3600, sessionCount: 1),
  ]

  return ProfileActivityView(
    selectedDate: Date(),
    activities: activities,
    viewMode: .week,
    onInsightsTapped: { _ in }
  )
  .environmentObject(ThemeManager.shared)
  .padding()
  .foqosTheme(.cream)
}
