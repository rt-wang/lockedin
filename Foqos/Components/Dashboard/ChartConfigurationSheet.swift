import SwiftUI

struct ChartConfigurationSheet: View {
  @Binding var showHabitTracker: Bool
  @Binding var chartType: HabitChartType
  let onDismiss: () -> Void

  var body: some View {
    NavigationStack {
      List {
        Section {
          Toggle("Show Chart", isOn: $showHabitTracker)
        } header: {
          FoqosSectionHeader("Visibility")
        }
        .foqosFormRows()
        .listRowInsets(EdgeInsets(top: 8, leading: 24, bottom: 8, trailing: 24))

        Section {
          ForEach(HabitChartType.allCases, id: \.self) { type in
            Button {
              chartType = type
            } label: {
              chartTypeRow(type)
            }
            .buttonStyle(FoqosPressStyle())
          }
        } header: {
          FoqosSectionHeader("Chart Type")
        }
        .foqosFormRows()
        .listRowInsets(EdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24))
      }
      .listStyle(.plain)
      .foqosForm(.cream)
      .navigationTitle("Manage chart")
      .navigationBarTitleDisplayMode(.inline)
      .toolbarBackground(FoqosColors.cream, for: .navigationBar)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            onDismiss()
          } label: {
            Image(systemName: "checkmark")
          }
        }
      }
    }
  }

  private func chartTypeRow(_ type: HabitChartType) -> some View {
    let isSelected = chartType == type

    return HStack(alignment: .firstTextBaseline, spacing: 12) {
      VStack(alignment: .leading, spacing: 6) {
        Text(type.rawValue)
          .foqosDisplay(size: 24)

        Text(type.description)
          .foqosText(.caption)
          .foregroundStyle(FoqosPalette.cream.mute)
          .multilineTextAlignment(.leading)
          .fixedSize(horizontal: false, vertical: true)
      }
      .frame(maxWidth: .infinity, alignment: .leading)

      Text(isSelected ? "Selected" : "Select")
        .foqosText(.mark)
        .foregroundStyle(isSelected ? FoqosPalette.cream.foreground : FoqosPalette.cream.mute)
    }
    .opacity(isSelected ? 1 : 0.6)
    .contentShape(Rectangle())
    .accessibilityElement(children: .combine)
    .accessibilityAddTraits(isSelected ? [.isSelected] : [])
  }
}

#Preview {
  struct PreviewWrapper: View {
    @State private var showChart = true
    @State private var chartType: HabitChartType = .fourWeek

    var body: some View {
      ChartConfigurationSheet(
        showHabitTracker: $showChart,
        chartType: $chartType,
        onDismiss: {}
      )
    }
  }

  return PreviewWrapper()
}
