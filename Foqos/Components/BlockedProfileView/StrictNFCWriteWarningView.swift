import SwiftUI

struct StrictNFCWriteWarningView: View {
  @Environment(\.foqosPalette) private var palette

  let profileName: String
  let onCancel: () -> Void
  let onContinue: () -> Void

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        VStack(alignment: .leading, spacing: 14) {
          Text("NFC tag")
            .foqosText(.eyebrow)
            .foregroundStyle(palette.mute)

          Text("Before you write")
            .foqosDisplay(size: 40)
            .accessibilityAddTraits(.isHeader)

          strictModeWarning
            .font(FoqosFont.ui(.subheadline, size: 15, bold: false))
            .foregroundStyle(palette.foreground)
            .fixedSize(horizontal: false, vertical: true)

          Text(convenienceText)
            .foqosText(.caption)
            .foregroundStyle(palette.mute)
            .fixedSize(horizontal: false, vertical: true)
        }

        VStack(spacing: 4) {
          ActionButton(
            title: "Never mind"
          ) {
            onCancel()
          }

          FoqosLineButton(title: "Continue anyway", isMuted: true, action: onContinue)
        }
      }
      .padding(24)
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .foqosTheme(.cream)
  }

  private var strictModeWarning: Text {
    let baseText = Text(
      "You already use an NFC tag as a physical unlock for \(profileName). "
    )

    return baseText
      + Text("Do not write over that unlock tag")
      .fontWeight(.bold)
      + Text(
        ". Rewriting it can change what LockedIn reads later and may stop this profile from unlocking. You do not need to create another NFC tag for this profile."
      )
  }

  private var convenienceText: String {
    return
      "This only creates a convenience shortcut: scan the tag, tap the iOS notification, and LockedIn opens this profile for you."
  }
}

#Preview {
  StrictNFCWriteWarningView(
    profileName: "Deep Work",
    onCancel: {},
    onContinue: {}
  )
}
