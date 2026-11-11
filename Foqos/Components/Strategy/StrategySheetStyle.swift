import SwiftUI

// Shared building blocks for strategy configuration sheets (timer, pause, temporary access).

/// Eyebrow + serif title + muted description, matching the home hero.
struct StrategySheetHeader: View {
  @Environment(\.foqosPalette) private var palette

  var eyebrow: String? = nil
  let title: String
  let message: String

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      if let eyebrow {
        Text(eyebrow)
          .foqosText(.eyebrow)
          .foregroundStyle(palette.mute)
      }

      Text(title)
        .foqosDisplay(size: 34)
        .foregroundStyle(palette.foreground)
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityAddTraits(.isHeader)

      Text(message)
        .font(FoqosFont.ui(.subheadline, size: 15, bold: false))
        .foregroundStyle(palette.mute)
        .fixedSize(horizontal: false, vertical: true)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

/// Large serif value readout (e.g. "45m") with an optional uppercase caption.
struct StrategyValueDisplay: View {
  @Environment(\.foqosPalette) private var palette

  let value: String
  var caption: String? = nil
  var size: CGFloat = 56
  var alignment: HorizontalAlignment = .center

  var body: some View {
    VStack(alignment: alignment, spacing: 6) {
      Text(value)
        .foqosDisplay(size: size)
        .foregroundStyle(palette.foreground)
        .contentTransition(.numericText())
        .lineLimit(1)
        .minimumScaleFactor(0.6)

      if let caption {
        Text(caption)
          .foqosText(.mark)
          .foregroundStyle(palette.mute)
      }
    }
  }
}

/// Text-only − / + control with a 44pt hit target.
struct StrategyStepButton: View {
  @Environment(\.foqosPalette) private var palette

  let symbol: String
  let accessibilityLabel: String
  let isEnabled: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Text(symbol)
        .font(FoqosFont.ui(.title2, size: 26, bold: false))
        .foregroundStyle(isEnabled ? palette.foreground : palette.line)
        .frame(width: 44, height: 44)
        .contentShape(Rectangle())
    }
    .buttonStyle(FoqosPressStyle())
    .disabled(!isEnabled)
    .accessibilityLabel(accessibilityLabel)
  }
}

/// Min / max captions under a slider.
struct StrategyRangeLabels: View {
  @Environment(\.foqosPalette) private var palette

  let lower: String
  let upper: String

  var body: some View {
    HStack {
      Text(lower)
      Spacer()
      Text(upper)
    }
    .foqosText(.mark)
    .foregroundStyle(palette.mute)
  }
}

/// Section label + hairline, used between groups inside a strategy sheet.
struct StrategySectionLabel: View {
  @Environment(\.foqosPalette) private var palette

  let title: String
  var detail: String? = nil

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title)
        .foqosText(.eyebrow)
        .foregroundStyle(palette.foreground)
      FoqosHairline()
      if let detail {
        Text(detail)
          .foqosText(.caption)
          .foregroundStyle(palette.mute)
          .fixedSize(horizontal: false, vertical: true)
      }
    }
  }
}

private struct StrategySheetThemeModifier: ViewModifier {
  @Environment(\.foqosPalette) private var palette

  func body(content: Content) -> some View {
    content
      .toggleStyle(FoqosLineToggleStyle())
      .foqosTheme(palette)
  }
}

extension View {
  /// Follows the palette in the environment (cream by default, forest over an active session).
  func strategySheetTheme() -> some View {
    modifier(StrategySheetThemeModifier())
  }
}
