import FamilyControls
import SwiftUI

struct BlockedProfileAppSelector: View {
  @Environment(\.foqosPalette) private var palette

  var selection: FamilyActivitySelection
  var buttonAction: () -> Void
  var allowMode: Bool = false
  var disabled: Bool = false
  var disabledText: String?

  private var title: String {
    return allowMode ? "Allowed" : "Blocked"
  }

  private var catAndAppCount: Int {
    return FamilyActivityUtil.countSelectedActivities(selection, allowMode: allowMode)
  }

  private var countDisplayText: String {
    return FamilyActivityUtil.getCountDisplayText(selection, allowMode: allowMode)
  }

  private var shouldShowWarning: Bool {
    return FamilyActivityUtil.shouldShowAllowModeWarning(selection, allowMode: allowMode)
  }

  private var buttonText: String {
    return allowMode
      ? "Select Apps to Allow"
      : "Select Apps to Restrict"
  }

  var body: some View {

    Button(action: buttonAction) {
      ProfileFormActionRow(title: buttonText)
    }
    .buttonStyle(FoqosPressStyle())
    .disabled(disabled)

    if let disabledText = disabledText, disabled {
      ProfileFormCaption(disabledText, isWarning: true)
    } else if catAndAppCount == 0 {
      ProfileFormCaption("No apps selected")
    } else {
      VStack(alignment: .leading, spacing: 6) {
        ProfileFormCaption("\(countDisplayText) selected")

        if shouldShowWarning {
          Text("Selected categories expand to individual apps. Apple's 50 app limit applies.")
            .foqosText(.caption)
            .foregroundStyle(palette.foreground)
        }
      }
    }

  }
}

#Preview {
  BlockedProfileAppSelector(
    selection: FamilyActivitySelection(),
    buttonAction: {},
    disabled: true,
    disabledText: "Disable the current session to edit apps for blocking"
  )

  BlockedProfileAppSelector(
    selection: FamilyActivitySelection(),
    buttonAction: {},
    allowMode: true,
    disabled: true,
    disabledText: "Disable the current session to edit apps for blocking"
  )
  .foqosTheme(.cream)
}
