import SwiftUI

struct DebugRow: View {
  @Environment(\.foqosPalette) private var palette

  let label: String
  let value: String

  var body: some View {
    HStack(alignment: .firstTextBaseline, spacing: 12) {
      Text(label)
        .foqosText(.caption)
        .foregroundStyle(palette.foreground)
        .frame(width: 150, alignment: .leading)

      Text(value)
        .font(.caption.monospaced())
        .foregroundStyle(palette.mute)
        .textSelection(.enabled)

      Spacer(minLength: 0)
    }
  }
}

#Preview {
  DebugRow(label: "Session ID", value: "ABC123-DEF456")
    .padding()
    .foqosTheme(.cream)
}

#Preview("Long Value") {
  DebugRow(
    label: "Profile ID",
    value: "550e8400-e29b-41d4-a716-446655440000"
  )
  .padding()
}

#Preview("Boolean Value") {
  VStack(spacing: 8) {
    DebugRow(label: "Is Active", value: "true")
    DebugRow(label: "Is Break Available", value: "false")
  }
  .padding()
}
