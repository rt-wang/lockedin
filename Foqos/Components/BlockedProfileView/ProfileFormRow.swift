import SwiftUI

/// Uppercase row action with a trailing arrow, matching the home screen's row actions.
/// Use as a Button label inside profile forms and pickers.
struct ProfileFormActionRow: View {
  @Environment(\.foqosPalette) private var palette
  @Environment(\.isEnabled) private var isEnabled

  let title: String
  var trailing: String = "→"
  var isDestructive = false

  var body: some View {
    HStack(alignment: .firstTextBaseline) {
      Text(title)
        .foqosText(.cta)
        .lineLimit(1)
        .minimumScaleFactor(0.8)
      Spacer(minLength: 12)
      Text(trailing)
        .foqosText(.cta)
        .accessibilityHidden(true)
    }
    .foregroundStyle(isDestructive ? Color.red : palette.foreground)
    .opacity(isEnabled ? 1 : 0.4)
    .frame(minHeight: 36)
    .contentShape(Rectangle())
  }
}

/// Muted caption under a row action ("3 apps selected", "No schedule set").
struct ProfileFormCaption: View {
  @Environment(\.foqosPalette) private var palette

  let text: String
  var isWarning = false

  init(_ text: String, isWarning: Bool = false) {
    self.text = text
    self.isWarning = isWarning
  }

  var body: some View {
    Text(text)
      .foqosText(.caption)
      .foregroundStyle(isWarning ? Color.red : palette.mute)
      .fixedSize(horizontal: false, vertical: true)
  }
}

/// Label + current value header used above sliders.
struct ProfileFormValueHeader: View {
  @Environment(\.foqosPalette) private var palette

  let title: String
  let value: String

  var body: some View {
    HStack(alignment: .firstTextBaseline) {
      Text(title)
        .foqosText(.toggle)
      Spacer()
      Text(value)
        .foqosText(.mark)
        .foregroundStyle(palette.mute)
        .contentTransition(.numericText())
    }
  }
}

/// Range end labels under a slider ("5m" … "1h").
struct ProfileFormRangeLabels: View {
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

/// Serif sheet title with an optional eyebrow and supporting copy, used at the top of pickers.
struct ProfileSheetHeader: View {
  @Environment(\.foqosPalette) private var palette

  var eyebrow: String? = nil
  let title: String
  var message: String? = nil

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      if let eyebrow {
        Text(eyebrow)
          .foqosText(.eyebrow)
          .foregroundStyle(palette.mute)
      }
      Text(title)
        .foqosDisplay(size: 40)
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityAddTraits(.isHeader)
      if let message {
        Text(message)
          .font(FoqosFont.ui(.subheadline, size: 15, bold: false))
          .foregroundStyle(palette.mute)
          .fixedSize(horizontal: false, vertical: true)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

extension View {
  /// Cream sheet chrome for a NavigationStack root: page background, matching nav bar, forest tint.
  func profileSheetChrome() -> some View {
    self
      .toolbarBackground(FoqosColors.cream, for: .navigationBar)
      .tint(FoqosColors.forest)
  }

  /// Insets for a header row placed in its own Form section.
  func profileSheetHeaderRow() -> some View {
    self
      .foqosFormRows()
      .listRowSeparator(.hidden)
      .listRowInsets(EdgeInsets(top: 4, leading: 20, bottom: 8, trailing: 20))
  }
}

#Preview {
  Form {
    Section {
      ProfileSheetHeader(eyebrow: "Profile", title: "Schedule", message: "Pick the days.")
    }
    .profileSheetHeaderRow()

    Section {
      Button {
      } label: {
        ProfileFormActionRow(title: "Select apps to restrict")
      }
      ProfileFormCaption("3 apps selected")
      ProfileFormValueHeader(title: "Break duration", value: "15 min")
      ProfileFormRangeLabels(lower: "5m", upper: "1h")
    } header: {
      FoqosSectionHeader("Blocked apps")
    }
    .foqosFormRows()
  }
  .foqosForm(.cream)
}
