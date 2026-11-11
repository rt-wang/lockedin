import SwiftUI

struct StrategyRow: View {
  @Environment(\.foqosPalette) private var palette

  enum AccessoryStyle {
    case selection
    case chevron
    case none
  }

  let strategy: BlockingStrategy
  let isSelected: Bool
  let onTap: () -> Void
  var accessoryStyle: AccessoryStyle = .selection

  var body: some View {
    Button(action: onTap) {
      VStack(alignment: .leading, spacing: 8) {
        HStack(alignment: .center, spacing: 12) {
          BlockingStrategyIconImage(strategy: strategy)
            .font(.subheadline)
            .foregroundStyle(palette.mute)
            .frame(width: 34, height: 34)

          Text(strategy.name)
            .foqosDisplay(size: 22)
            .foregroundStyle(palette.foreground)

          Spacer(minLength: 8)

          if accessoryStyle == .selection {
            ZStack {
              Circle()
                .stroke(isSelected ? palette.foreground : palette.line, lineWidth: 1)
                .frame(width: 16, height: 16)
              if isSelected {
                Circle()
                  .fill(palette.foreground)
                  .frame(width: 8, height: 8)
              }
            }
            .accessibilityHidden(true)
          } else if accessoryStyle == .chevron {
            Text("→")
              .foqosText(.cta)
              .foregroundStyle(palette.foreground)
              .accessibilityHidden(true)
          }
        }

        Text(strategy.description)
          .foqosText(.caption)
          .foregroundStyle(palette.mute)
          .lineLimit(2)

        if !strategy.tags.isEmpty {
          HStack(spacing: 12) {
            ForEach(strategy.tags, id: \.self) { tag in
              Text(tag.title)
                .foqosText(.mark)
                .foregroundStyle(tag == .beta ? palette.foreground : palette.mute)
            }
          }
        }
      }
      .padding(.vertical, 6)
      .contentShape(Rectangle())
    }
    .buttonStyle(FoqosPressStyle())
    .accessibilityAddTraits(isSelected ? .isSelected : [])
  }
}

#Preview {
  StrategyRow(strategy: NFCBlockingStrategy(), isSelected: true, onTap: {})
    .padding(24)
    .foqosTheme(.cream)
}
