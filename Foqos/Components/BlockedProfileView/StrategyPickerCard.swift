import SwiftUI

/// One strategy in the picker: icon, serif name, selection mark, trailing arrow. Sits on a hairline.
struct StrategyPickerCard: View {
  @Environment(\.foqosPalette) private var palette

  let strategy: BlockingStrategy
  let isSelected: Bool
  let onTap: () -> Void

  var body: some View {
    Button(action: onTap) {
      VStack(spacing: 0) {
        FoqosHairline()

        HStack(alignment: .center, spacing: 14) {
          BlockingStrategyIconImage(strategy: strategy)
            .font(.system(size: 20))
            .foregroundStyle(palette.foreground)
            .frame(width: 36, height: 36)

          VStack(alignment: .leading, spacing: 4) {
            Text(strategy.name)
              .foqosDisplay(size: 22)
              .foregroundStyle(palette.foreground)
              .lineLimit(2)
              .minimumScaleFactor(0.82)

            if isSelected {
              Text("Selected")
                .foqosText(.mark)
                .foregroundStyle(palette.mute)
            }
          }

          Spacer(minLength: 12)

          Text("→")
            .foqosText(.cta)
            .foregroundStyle(palette.foreground)
            .accessibilityHidden(true)
        }
        .padding(.vertical, 14)
      }
      .contentShape(Rectangle())
    }
    .buttonStyle(FoqosPressStyle())
    .accessibilityLabel(strategy.name)
    .accessibilityAddTraits(isSelected ? .isSelected : [])
    .accessibilityHint("Shows details for this blocking strategy")
  }
}

#Preview {
  VStack(spacing: 0) {
    StrategyPickerCard(strategy: NFCBlockingStrategy(), isSelected: true, onTap: {})
    StrategyPickerCard(strategy: QRCodeBlockingStrategy(), isSelected: false, onTap: {})
  }
  .padding(24)
  .foqosTheme(.cream)
}
