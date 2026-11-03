import SwiftUI

struct Welcome: View {
  @Environment(\.foqosPalette) private var palette

  let onGuidedTap: () -> Void
  let onAdvancedTap: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      FoqosHairline()

      VStack(alignment: .leading, spacing: 10) {
        Text("Getting started")
          .foqosText(.eyebrow)
          .foregroundStyle(palette.mute)

        Text("Create your first profile")
          .foqosDisplay(size: 34)
          .fixedSize(horizontal: false, vertical: true)
          .accessibilityAddTraits(.isHeader)

        Text(
          "Pick the apps to lock and how you unlock them. Customize as much or as little as you like."
        )
        .font(FoqosFont.ui(.subheadline, size: 15, bold: false))
        .foregroundStyle(palette.mute)
        .frame(maxWidth: 300, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
      }
      .padding(.vertical, 22)

      FoqosLineButton(title: "Create profile", action: onGuidedTap)
        .accessibilityLabel("Start guided profile setup")

      FoqosTextLink("Use the full profile editor", action: onAdvancedTap)
        .padding(.top, 4)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

#Preview {
  Welcome(
    onGuidedTap: { print("Guided tapped") },
    onAdvancedTap: { print("Advanced tapped") }
  )
  .padding(.horizontal, 24)
  .frame(maxHeight: .infinity)
  .foqosTheme(.cream)
}
