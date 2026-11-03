import Foundation
import SwiftUI

struct SessionRow: View {
  @Environment(\.foqosPalette) private var palette

  var session: BlockedProfileSession

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(DateFormatters.formatSessionDate(session.startTime))
        .foqosText(.mark)
        .foregroundStyle(palette.mute)

      HStack(alignment: .firstTextBaseline, spacing: 8) {
        Text(DateFormatters.formatDurationHoursMinutes(session.duration))
          .foqosDisplay(size: 28)
          .foregroundStyle(palette.foreground)

        Text("total")
          .foqosDisplay(size: 20, italic: true)
          .foregroundStyle(palette.mute)

        Spacer()

        Text("→")
          .foqosText(.cta)
          .foregroundStyle(palette.mute)
          .accessibilityHidden(true)
      }

      if session.totalBreakDuration > 0 {
        HStack(spacing: 6) {
          Image(systemName: "cup.and.saucer")
            .font(.caption)
          Text("\(Int(session.totalBreakDuration / 60))m")
            .monospacedDigit()
        }
        .foqosText(.caption)
        .foregroundStyle(palette.mute)
      }
    }
    .padding(.vertical, 6)
    .frame(maxWidth: .infinity, alignment: .leading)
    .contentShape(Rectangle())
  }
}
