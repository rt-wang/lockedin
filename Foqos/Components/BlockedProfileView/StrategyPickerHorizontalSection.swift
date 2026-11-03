import SwiftUI

/// A category of strategies: eyebrow title, muted description, then an open hairline list.
struct StrategyPickerHorizontalSection: View {
  @Environment(\.foqosPalette) private var palette

  let section: StrategyPickerSection
  let selectedStrategyId: String?
  let onSelect: (BlockingStrategy) -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      VStack(alignment: .leading, spacing: 6) {
        Text(section.title)
          .foqosText(.eyebrow)
          .foregroundStyle(palette.foreground)
          .accessibilityAddTraits(.isHeader)

        Text(section.description)
          .foqosText(.caption)
          .foregroundStyle(palette.mute)
          .fixedSize(horizontal: false, vertical: true)
      }

      VStack(spacing: 0) {
        ForEach(section.strategies, id: \.name) { strategy in
          StrategyPickerCard(
            strategy: strategy,
            isSelected: selectedStrategyId == strategy.getIdentifier(),
            onTap: {
              onSelect(strategy)
            }
          )
        }
        FoqosHairline()
      }
    }
  }
}
