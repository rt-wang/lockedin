import SwiftData
import SwiftUI

struct SessionDetailsView: View {
  @Environment(\.dismiss) private var dismiss

  let session: BlockedProfileSession

  var body: some View {
    NavigationStack {
      Form {
        Section {
          VStack(alignment: .leading, spacing: 6) {
            Text("Session")
              .foqosText(.eyebrow)
              .foregroundStyle(FoqosPalette.cream.mute)
            Text(session.blockedProfile.name)
              .foqosDisplay(size: 40)
              .fixedSize(horizontal: false, vertical: true)
              .accessibilityAddTraits(.isHeader)
            Text(DateFormatters.formatDurationHoursMinutes(session.duration))
              .foqosDisplay(size: 28, italic: true)
              .foregroundStyle(FoqosPalette.cream.mute)
          }
          .padding(.vertical, 4)
        }
        .foqosFormRows()
        .listRowSeparator(.hidden)

        SessionInfoSection(session: session)
        TimingSection(session: session)

        if session.totalBreakDuration > 0 {
          BreakSection(session: session)
        }

        if session.pauseStartTime != nil && session.pauseEndTime != nil {
          PauseSection(session: session)
        }
      }
      .foqosForm(.cream)
      .navigationTitle("Session details")
      .navigationBarTitleDisplayMode(.inline)
      .toolbarBackground(FoqosColors.cream, for: .navigationBar)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button(action: { dismiss() }) {
            Image(systemName: "xmark")
          }
          .accessibilityLabel("Close")
        }
      }
    }
  }
}

// MARK: - Session Info Section

private struct SessionInfoSection: View {
  let session: BlockedProfileSession

  var body: some View {
    Section {
      InfoRow(label: "Tag", value: session.tag)
      InfoRow(label: "Profile", value: session.blockedProfile.name)
      InfoRow(label: "Force Started", value: session.forceStarted ? "Yes" : "No")
    } header: {
      FoqosSectionHeader("Session info")
    }
    .foqosFormRows()
  }
}

// MARK: - Timing Section

private struct TimingSection: View {
  let session: BlockedProfileSession

  var body: some View {
    Section {
      InfoRow(
        label: "Started",
        value: DateFormatters.formatDate(session.startTime)
      )

      if let endTime = session.endTime {
        InfoRow(
          label: "Ended",
          value: DateFormatters.formatDate(endTime)
        )
      } else {
        InfoRow(label: "Ended", value: "In progress")
      }

      InfoRow(
        label: "Duration",
        value: DateFormatters.formatDurationHoursMinutes(session.duration)
      )
    } header: {
      FoqosSectionHeader("Timing")
    }
    .foqosFormRows()
  }
}

// MARK: - Break Section

private struct BreakSection: View {
  let session: BlockedProfileSession

  var body: some View {
    Section {
      if let breakStartTime = session.breakStartTime {
        InfoRow(
          label: "Started",
          value: DateFormatters.formatDate(breakStartTime)
        )
      }

      if let breakEndTime = session.breakEndTime {
        InfoRow(
          label: "Ended",
          value: DateFormatters.formatDate(breakEndTime)
        )
      }

      if session.totalBreakDuration > 0 {
        InfoRow(
          label: "Total Duration",
          value: "\(Int(session.totalBreakDuration / 60))m"
        )
      }
    } header: {
      FoqosSectionHeader("Break")
    }
    .foqosFormRows()
  }
}

// MARK: - Pause Section

private struct PauseSection: View {
  let session: BlockedProfileSession

  var pauseDuration: TimeInterval? {
    guard let pauseStartTime = session.pauseStartTime,
      let pauseEndTime = session.pauseEndTime
    else {
      return nil
    }
    return pauseEndTime.timeIntervalSince(pauseStartTime)
  }

  var body: some View {
    Section {
      if let pauseStartTime = session.pauseStartTime {
        InfoRow(
          label: "Started",
          value: DateFormatters.formatDate(pauseStartTime)
        )
      }

      if let pauseEndTime = session.pauseEndTime {
        InfoRow(
          label: "Ended",
          value: DateFormatters.formatDate(pauseEndTime)
        )
      }

      if let pauseDuration = pauseDuration {
        InfoRow(
          label: "Duration",
          value: DateFormatters.formatDurationShort(pauseDuration)
        )
      }
    } header: {
      FoqosSectionHeader("Pause")
    }
    .foqosFormRows()
  }
}

// MARK: - Info Row Component

private struct InfoRow: View {
  @Environment(\.foqosPalette) private var palette

  let label: String
  let value: String

  var body: some View {
    HStack(alignment: .firstTextBaseline) {
      Text(label)
        .foqosText(.body)
        .foregroundStyle(palette.foreground)
      Spacer()
      Text(value)
        .foqosText(.caption)
        .foregroundStyle(palette.mute)
        .multilineTextAlignment(.trailing)
    }
  }
}

// MARK: - Previews

#Preview("Active Session") {
  struct PreviewWrapper: View {
    let profile: BlockedProfiles
    let session: BlockedProfileSession

    init() {
      let profile = BlockedProfiles(name: "Work Focus")
      let session = BlockedProfileSession(
        tag: "Morning Session",
        blockedProfile: profile,
        forceStarted: false
      )
      self.profile = profile
      self.session = session
    }

    var body: some View {
      SessionDetailsView(session: session)
    }
  }

  return PreviewWrapper()
    .modelContainer(for: [BlockedProfiles.self, BlockedProfileSession.self])
}

#Preview("Active Session with Break") {
  struct PreviewWrapper: View {
    let profile: BlockedProfiles
    let session: BlockedProfileSession

    init() {
      let profile = BlockedProfiles(
        name: "Deep Work",
        enableBreaks: true
      )
      let session = BlockedProfileSession(
        tag: "Focus Time",
        blockedProfile: profile,
        forceStarted: false
      )
      session.startBreak()
      self.profile = profile
      self.session = session
    }

    var body: some View {
      SessionDetailsView(session: session)
    }
  }

  return PreviewWrapper()
    .modelContainer(for: [BlockedProfiles.self, BlockedProfileSession.self])
}

#Preview("Completed Session with Break and Pause") {
  struct PreviewWrapper: View {
    let profile: BlockedProfiles
    let session: BlockedProfileSession

    init() {
      let profile = BlockedProfiles(
        name: "Study Session",
        enableBreaks: true
      )
      let session = BlockedProfileSession(
        tag: "Exam Prep",
        blockedProfile: profile,
        forceStarted: true
      )

      // Simulate a completed session
      session.endTime = Date().addingTimeInterval(-3600)

      // Add a break
      session.breakStartTime = Date().addingTimeInterval(-2700)
      session.breakEndTime = Date().addingTimeInterval(-2400)

      // Add a pause
      session.pauseStartTime = Date().addingTimeInterval(-1800)
      session.pauseEndTime = Date().addingTimeInterval(-1500)

      self.profile = profile
      self.session = session
    }

    var body: some View {
      SessionDetailsView(session: session)
    }
  }

  return PreviewWrapper()
    .modelContainer(for: [BlockedProfiles.self, BlockedProfileSession.self])
}
