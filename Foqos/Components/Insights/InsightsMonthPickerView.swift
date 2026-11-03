import SwiftUI

struct InsightsMonthPickerView: View {
  @Environment(\.dismiss) private var dismiss
  @State private var draftDate: Date

  let onApply: (Date) -> Void

  init(selectedDate: Date, onApply: @escaping (Date) -> Void) {
    _draftDate = State(initialValue: selectedDate)
    self.onApply = onApply
  }

  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        DatePicker("", selection: $draftDate, displayedComponents: .date)
          .datePickerStyle(.graphical)
          .labelsHidden()
      }
      .padding(.horizontal, 16)
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
      .foqosTheme(.cream)
      .onChange(of: draftDate) { _, newValue in
        onApply(newValue)
        dismiss()
      }
    }
  }
}

#Preview {
  InsightsMonthPickerView(selectedDate: Date()) { _ in }
}
