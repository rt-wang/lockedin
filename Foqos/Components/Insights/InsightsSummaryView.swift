import SwiftUI

struct InsightsSummaryRow: View {
  @Environment(\.foqosPalette) private var palette

  let icon: String
  let label: String
  let value: String

  var body: some View {
    HStack(alignment: .firstTextBaseline, spacing: 12) {
      Image(systemName: icon)
        .font(.footnote)
        .foregroundStyle(palette.mute)
        .frame(width: 20)
        .accessibilityHidden(true)

      Text(label)
        .foqosText(.body)
        .foregroundStyle(palette.foreground)

      Spacer()

      Text(value)
        .foqosText(.caption)
        .monospacedDigit()
        .foregroundStyle(palette.mute)
    }
    .padding(.vertical, 4)
  }
}

#Preview("Row") {
  List {
    Section {
      InsightsSummaryRow(
        icon: "clock.fill",
        label: "Total Focus Time",
        value: "5h 30m"
      )
      InsightsSummaryRow(
        icon: "cup.and.saucer.fill",
        label: "Total Break Time",
        value: "45m"
      )
      InsightsSummaryRow(
        icon: "tag.fill",
        label: "Profile ID",
        value: "abc12345..."
      )
    } header: {
      FoqosSectionHeader("Summary")
    }
    .foqosFormRows()
  }
  .foqosForm(.cream)
}
