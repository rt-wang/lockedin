import SwiftUI

/// Label + large serif duration shown above the weekly and monthly insight charts.
struct InsightsChartHeader: View {
  @Environment(\.foqosPalette) private var palette

  let label: String
  let value: String
  var showsTotalSuffix = false
  var onReset: (() -> Void)? = nil

  var body: some View {
    HStack(alignment: .top) {
      VStack(alignment: .leading, spacing: 4) {
        Text(label)
          .foqosText(.mark)
          .foregroundStyle(palette.mute)

        HStack(alignment: .firstTextBaseline, spacing: 8) {
          Text(value)
            .foqosDisplay(size: 44)
            .foregroundStyle(palette.foreground)
            .contentTransition(.numericText())
            .lineLimit(1)
            .minimumScaleFactor(0.6)

          if showsTotalSuffix {
            Text("total")
              .foqosDisplay(size: 24, italic: true)
              .foregroundStyle(palette.mute)
          }
        }
      }

      Spacer()

      if let onReset {
        FoqosTextLink("Reset", action: onReset)
          .accessibilityLabel("Clear day selection")
      }
    }
  }
}
