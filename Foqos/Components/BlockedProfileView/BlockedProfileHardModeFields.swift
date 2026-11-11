import SwiftUI

struct BlockedProfileHardModeFields: View {
  @Environment(\.foqosPalette) private var palette
  @ObservedObject var draft: BlockedProfileDraft
  var disabled: Bool

  var body: some View {
    CustomToggle(
      title: "Hard Mode",
      description: draft.selectedStrategyAllowsHardMode
        ? "Hide the Stop button for a set time."
        : "Unavailable for timers. Hide the Stop button instead.",
      isOn: $draft.enableHardMode,
      isDisabled: disabled || !draft.selectedStrategyAllowsHardMode
    )

    if draft.enableHardMode && draft.selectedStrategyAllowsHardMode {
      VStack(alignment: .leading, spacing: 10) {
        ProfileFormValueHeader(
          title: "Lock Duration",
          value: DateFormatters.formatMinutes(draft.hardModeDurationInMinutes)
        )

        Slider(
          value: Binding(
            get: { Double(draft.hardModeDurationInMinutes) },
            set: { draft.hardModeDurationInMinutes = Int($0) }
          ),
          in: 30...720,
          step: 30
        )
        .tint(palette.foreground)
        .accessibilityLabel("Hard Mode lock duration")
        .accessibilityValue(DateFormatters.formatMinutes(draft.hardModeDurationInMinutes))

        ProfileFormRangeLabels(lower: "30m", upper: "12h")
      }
      .disabled(disabled)
    }
  }
}

#Preview {
  Form {
    BlockedProfileHardModeFields(
      draft: BlockedProfileDraft(
        profile: BlockedProfiles(name: "Work", enableHardMode: true, hardModeDurationInMinutes: 90)
      ),
      disabled: false
    )
  }
  .foqosForm(.cream)
}
