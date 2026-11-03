import SwiftUI

/// Editorial empty state: small mark, serif headline, no illustration chrome.
struct EmptyView: View {
  @Environment(\.foqosPalette) private var palette

  let iconName: String
  let headingText: String
  var detailText: String? = nil

  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      Spacer()

      Image(systemName: iconName)
        .font(.system(size: 18, weight: .regular))
        .foregroundStyle(palette.mute)
        .accessibilityHidden(true)

      Text(headingText)
        .foqosDisplay(size: 30)
        .foregroundStyle(palette.foreground)
        .fixedSize(horizontal: false, vertical: true)

      if let detailText {
        Text(detailText)
          .foqosText(.body)
          .foregroundStyle(palette.mute)
          .fixedSize(horizontal: false, vertical: true)
      }

      Spacer()
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal, 24)
  }
}

#Preview {
  EmptyView(
    iconName: "person.crop.circle.badge.plus",
    headingText: "Create a profile before starting a focus session",
    detailText: "Profiles hold the apps and websites you want to lock."
  )
  .foqosTheme(.cream)
}
