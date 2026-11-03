import SwiftUI

struct StrategyDetailsSheet: View {
  @Environment(\.foqosPalette) private var palette

  let strategy: BlockingStrategy
  let isSelected: Bool
  let onCancel: () -> Void
  let onSelect: () -> Void

  var body: some View {
    NavigationStack {
      VStack(alignment: .leading, spacing: 22) {
        BlockingStrategyIconImage(strategy: strategy)
          .font(.system(size: 34))
          .foregroundStyle(palette.foreground)
          .frame(width: 64, height: 64, alignment: .leading)
          .accessibilityHidden(true)

        ProfileSheetHeader(
          eyebrow: isSelected ? "Current strategy" : "Strategy",
          title: strategy.name,
          message: strategy.description
        )

        Spacer(minLength: 12)

        ActionButton(
          title: isSelected ? "Selected" : "Use this strategy",
          isDisabled: isSelected,
          action: onSelect
        )
      }
      .padding(.horizontal, 24)
      .padding(.top, 8)
      .padding(.bottom, 16)
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
      .foqosTheme(.cream)
      .navigationTitle("Details")
      .navigationBarTitleDisplayMode(.inline)
      .profileSheetChrome()
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button(action: onCancel) {
            Image(systemName: "xmark")
          }
          .accessibilityLabel("Cancel")
        }
      }
    }
  }
}
