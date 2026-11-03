import SwiftUI

struct StrategyPicker: View {
  let strategies: [BlockingStrategy]
  @Binding var selectedStrategy: BlockingStrategy?
  @Binding var isPresented: Bool

  @State private var strategyDetails: StrategyDetailsPresentation?

  private var sections: [StrategyPickerSection] {
    return BlockingStrategyPickerCategory.allCases.compactMap { category in
      let categoryStrategies = strategies.filter { $0.pickerCategory == category }
      guard !categoryStrategies.isEmpty else { return nil }

      return StrategyPickerSection(
        title: category.title,
        description: category.description,
        strategies: categoryStrategies
      )
    }
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        LazyVStack(alignment: .leading, spacing: 36) {
          ProfileSheetHeader(
            eyebrow: "Blocking strategy",
            title: "How do you unlock?",
            message: "Pick how sessions start and stop for this profile."
          )

          ForEach(sections) { section in
            StrategyPickerHorizontalSection(
              section: section,
              selectedStrategyId: selectedStrategy?.getIdentifier(),
              onSelect: { strategy in
                strategyDetails = StrategyDetailsPresentation(strategy: strategy)
              }
            )
          }
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding(.bottom, 32)
      }
      .foqosTheme(.cream)
      .navigationTitle("Blocking Strategy")
      .navigationBarTitleDisplayMode(.inline)
      .profileSheetChrome()
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            isPresented = false
          } label: {
            Image(systemName: "checkmark")
          }
          .accessibilityLabel("Done")
        }
      }
      .sheet(item: $strategyDetails) { details in
        StrategyDetailsSheet(
          strategy: details.strategy,
          isSelected: selectedStrategy?.getIdentifier() == details.id,
          onCancel: {
            strategyDetails = nil
          },
          onSelect: {
            selectedStrategy = details.strategy
            strategyDetails = nil
            isPresented = false
          }
        )
        .presentationDetents([.medium, .large])
      }
    }
  }

}

#Preview {
  @Previewable @State var selectedStrategy: BlockingStrategy? = NFCBlockingStrategy()
  @Previewable @State var isPresented = true

  StrategyPicker(
    strategies: [
      NFCBlockingStrategy(),
      QRCodeBlockingStrategy(),
      ManualBlockingStrategy(),
      NFCManualBlockingStrategy(),
      QRManualBlockingStrategy(),
      NFCTimerBlockingStrategy(),
      QRTimerBlockingStrategy(),
      NFCPauseTimerBlockingStrategy(),
      QRPauseTimerBlockingStrategy(),
    ],
    selectedStrategy: $selectedStrategy,
    isPresented: $isPresented
  )
}
