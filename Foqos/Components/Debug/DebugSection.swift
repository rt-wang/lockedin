import SwiftUI

/// Open section: uppercase eyebrow over a hairline, rows sitting directly on the page.
struct DebugSection<Content: View>: View {
  @Environment(\.foqosPalette) private var palette

  let title: String
  let content: Content

  init(title: String, @ViewBuilder content: () -> Content) {
    self.title = title
    self.content = content()
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(title)
        .foqosText(.eyebrow)
        .foregroundStyle(palette.foreground)

      FoqosHairline()

      VStack(alignment: .leading, spacing: 8) {
        content
      }
      .padding(.bottom, 12)
    }
  }
}

#Preview {
  DebugSection(title: "Session Information") {
    DebugRow(label: "Session ID", value: "ABC123-DEF456")
    DebugRow(label: "Is Active", value: "true")
    DebugRow(label: "Duration", value: "1h 23m 45s")
  }
  .padding()
  .foqosTheme(.cream)
}

#Preview("Multiple Sections") {
  ScrollView {
    VStack(spacing: 16) {
      DebugSection(title: "Profile Details") {
        DebugRow(label: "Name", value: "Work Focus")
        DebugRow(label: "Strategy", value: "NFC")
      }

      DebugSection(title: "Session Status") {
        DebugRow(label: "Is Active", value: "true")
        DebugRow(label: "Elapsed Time", value: "45m 12s")
      }
    }
    .padding()
  }
}
