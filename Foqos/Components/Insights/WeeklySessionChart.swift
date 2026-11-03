import Charts
import SwiftUI

struct WeeklySessionChart: View {
  @ObservedObject var viewModel: WeeklyInsightsUtil
  @Environment(\.foqosPalette) private var palette
  @Binding var selectedDay: WeeklyDayAggregate?
  let onDateSelected: ((Date?) -> Void)?
  @State private var selectionFeedbackTrigger = 0

  private var chartView: some View {
    Chart {
      ForEach(viewModel.weeklySummary.days) { day in
        BarMark(
          x: .value("Day", day.displayLabel),
          y: .value("Duration", day.totalSessionTime)
        )
        .foregroundStyle(
          selectedDay?.displayLabel == day.displayLabel
            ? palette.foreground
            : palette.foreground.opacity(selectedDay == nil ? 0.85 : 0.35)
        )
      }
    }
    .chartYAxis {
      AxisMarks(position: .trailing) { value in
        AxisGridLine().foregroundStyle(palette.line)
        AxisValueLabel {
          if let duration = value.as(TimeInterval.self) {
            Text(DateFormatters.formatDurationShort(duration))
              .foqosText(.mark)
              .foregroundStyle(palette.mute)
          }
        }
      }
    }
    .chartXAxis {
      AxisMarks { value in
        AxisValueLabel {
          if let label = value.as(String.self) {
            Text(label)
              .foqosText(.mark)
              .foregroundStyle(palette.mute)
          }
        }
      }
    }
    .chartPlotStyle { plotArea in
      plotArea
        .padding(.trailing, 10)
    }
  }

  private func selectDay(_ label: String) {
    selectedDay = viewModel.weeklySummary.days.first { $0.displayLabel == label }
    if let day = selectedDay {
      onDateSelected?(day.date)
      selectionFeedbackTrigger += 1
    }
  }

  private func clearSelection() {
    selectedDay = nil
    onDateSelected?(nil)
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      Group {
        if let selectedDay = selectedDay {
          InsightsChartHeader(
            label: DateFormatters.formatSelectedDayHeader(selectedDay.date),
            value: DateFormatters.formatDurationHoursMinutes(selectedDay.totalSessionTime),
            showsTotalSuffix: true,
            onReset: clearSelection
          )
        } else {
          InsightsChartHeader(
            label: "Average focus session",
            value: DateFormatters.formatDurationHoursMinutes(
              viewModel.weeklySummary.averageSessionDuration)
          )
        }
      }
      .animation(.spring(response: 0.25, dampingFraction: 0.85), value: selectedDay)

      chartView
        .chartGesture { proxy in
          SpatialTapGesture()
            .onEnded { value in
              guard let label: String = proxy.value(atX: value.location.x) else { return }
              selectDay(label)
            }
        }
        .onChange(of: viewModel.selectedDate) { _, _ in
          clearSelection()
        }
        .sensoryFeedback(
          .impact(flexibility: .soft, intensity: 0.7),
          trigger: selectionFeedbackTrigger
        )
        .frame(maxWidth: .infinity)
        .frame(height: 210)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

#Preview {
  struct PreviewWrapper: View {
    @State private var selectedDay: WeeklyDayAggregate?
    let viewModel: WeeklyInsightsUtil

    init() {
      let profile = BlockedProfiles(name: "Work Focus")
      let calendar = Calendar.current
      let today = Date()
      let weekStart = WeeklySessionAggregator.startOfWeek(for: today, calendar: calendar)

      for dayOffset in 0..<7 {
        let sessionsCount = [3, 5, 2, 4, 6, 1, 2][dayOffset]
        let day = calendar.date(byAdding: .day, value: dayOffset, to: weekStart)!

        for sessionIndex in 0..<sessionsCount {
          let session = BlockedProfileSession(
            tag: "Focus Session \(sessionIndex + 1)", blockedProfile: profile)
          let startTime = calendar.date(byAdding: .hour, value: 8 + sessionIndex, to: day)!
          session.startTime = startTime
          session.endTime = calendar.date(
            byAdding: .minute, value: 45 + sessionIndex * 10, to: startTime)!
        }
      }

      viewModel = WeeklyInsightsUtil(profiles: [profile])
    }

    var body: some View {
      WeeklySessionChart(
        viewModel: viewModel,
        selectedDay: $selectedDay,
        onDateSelected: nil
      )
      .padding()
    }
  }

  return PreviewWrapper()
}
