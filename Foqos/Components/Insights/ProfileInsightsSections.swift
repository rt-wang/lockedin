import SwiftUI

struct ProfileInsightsSections: View {
  @ObservedObject var weeklyViewModel: WeeklyInsightsUtil
  @ObservedObject var monthlyViewModel: MonthlyInsightsUtil
  @Binding var selectedWeekDay: WeeklyDayAggregate?
  @Binding var selectedMonthDay: MonthlyDayAggregate?

  let viewMode: InsightsViewMode
  let sessions: [BlockedProfileSession]
  let sessionsSectionTitle: String
  let showsSummary: Bool
  let totalFocusTime: TimeInterval
  let totalBreakTime: TimeInterval
  let profileId: UUID
  let onSelectSession: (BlockedProfileSession) -> Void
  let onDeleteSession: (BlockedProfileSession) -> Void

  var body: some View {
    if viewMode != .allSessions {
      Section {
        Group {
          if viewMode == .week {
            WeeklySessionChart(
              viewModel: weeklyViewModel, selectedDay: $selectedWeekDay, onDateSelected: nil
            )
          } else {
            MonthlySessionChart(
              viewModel: monthlyViewModel, selectedDay: $selectedMonthDay, onDateSelected: nil
            )
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
        .listRowInsets(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
      } header: {
        FoqosSectionHeader(viewMode == .week ? "Week" : "Month")
      }
      .foqosFormRows()
    }

    if !sessions.isEmpty {
      Section {
        ForEach(sessions) { session in
          Button {
            onSelectSession(session)
          } label: {
            SessionRow(session: session)
          }
          .buttonStyle(.plain)
          .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
              onDeleteSession(session)
            } label: {
              Label("Delete", systemImage: "trash")
            }
          }
        }
      } header: {
        FoqosSectionHeader(sessionsSectionTitle)
      }
      .foqosFormRows()
    }

    if showsSummary {
      Section {
        InsightsSummaryRow(
          icon: "clock.fill",
          label: "Total Focus Time",
          value: DateFormatters.formatDurationHoursMinutes(
            totalFocusTime)
        )

        InsightsSummaryRow(
          icon: "cup.and.saucer.fill",
          label: "Total Break Time",
          value: DateFormatters.formatDurationHoursMinutes(
            totalBreakTime)
        )

        InsightsSummaryRow(
          icon: "tag.fill",
          label: "Profile ID",
          value: String(profileId.uuidString.prefix(8)) + "..."
        )
      } header: {
        FoqosSectionHeader("Summary")
      }
      .foqosFormRows()
    }
  }
}
