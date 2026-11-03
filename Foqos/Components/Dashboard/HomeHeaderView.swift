import SwiftUI

struct HomeHeaderView: View {
  @Environment(\.foqosPalette) private var palette

  let onSupportTapped: () -> Void
  let onSettingsTapped: () -> Void

  var body: some View {
    HStack(alignment: .firstTextBaseline, spacing: 20) {
      Text("Focus")
        .foqosText(.tab)
        .padding(.bottom, 8)
        .overlay(alignment: .bottom) {
          Rectangle()
            .fill(palette.foreground)
            .frame(height: 1)
        }
        .accessibilityAddTraits(.isHeader)

      Spacer(minLength: 12)

      FoqosTextLink("Support", action: onSupportTapped)
      FoqosTextLink("Settings", action: onSettingsTapped)
    }
    .padding(.top, 8)
  }
}

#Preview {
  HomeHeaderView(onSupportTapped: {}, onSettingsTapped: {})
    .padding(.horizontal, 24)
    .foqosTheme(.cream)
}

#Preview("Sidebar") {
  HomeHeaderView(onSupportTapped: {}, onSettingsTapped: {})
    .padding(.horizontal, 24)
    .frame(width: 280)
    .foqosTheme(.cream)
}
