import SwiftUI

/// Primary call to action used by sheets and strategy flows. Renders as the design system's
/// line button (hairline rule, uppercase label, trailing arrow) instead of a filled pill.
struct ActionButton: View {
  let title: String
  let isLoading: Bool
  let isDisabled: Bool

  let action: () -> Void

  init(
    title: String,
    isLoading: Bool = false,
    isDisabled: Bool = false,
    action: @escaping () -> Void
  ) {
    self.title = title
    self.isLoading = isLoading
    self.isDisabled = isDisabled
    self.action = action
  }

  var body: some View {
    FoqosLineButton(
      title: isLoading ? "Working…" : title,
      trailing: isLoading ? nil : "→",
      action: action
    )
    .disabled(isLoading || isDisabled)
    .accessibilityLabel(title)
  }
}

#Preview {
  VStack(spacing: 24) {
    ActionButton(title: "Start session") {}
    ActionButton(title: "Export as CSV", isLoading: true) {}
    ActionButton(title: "Selected", isDisabled: true) {}
  }
  .padding(24)
  .foqosTheme(.cream)
}
