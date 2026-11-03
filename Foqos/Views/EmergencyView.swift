import SwiftUI

struct EmergencyView: View {
  @Environment(\.modelContext) private var context
  @Environment(\.dismiss) private var dismiss

  @EnvironmentObject var strategyManager: StrategyManager

  private var emergencyUnblocksRemaining: Int { strategyManager.getRemainingEmergencyUnblocks() }
  private var hasRemaining: Bool { strategyManager.getRemainingEmergencyUnblocks() > 0 }

  @State private var isPerformingEmergencyUnblock: Bool = false

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 28) {
        header

        statusCard
      }
      .padding(.horizontal, 24)
      .padding(.bottom, 24)
    }
    .foqosTheme(.cream)
    .onAppear {
      strategyManager.checkAndResetEmergencyUnblocks()
    }
  }

  private var header: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack(alignment: .firstTextBaseline) {
        Text("Emergency")
          .foqosText(.eyebrow)
          .foregroundStyle(FoqosPalette.cream.mute)

        Spacer()

        HStack(spacing: 8) {
          HStack(spacing: 6) {
            Image(systemName: "clock.arrow.circlepath")
              .font(.caption)

            Group {
              if let nextResetDate = strategyManager.getNextResetDate() {
                let timeUntilReset = nextResetDate.timeIntervalSinceNow
                if timeUntilReset <= 24 * 60 * 60 {  // Less than 24 hours
                  let hoursRemaining = max(1, Int(ceil(timeUntilReset / 3600)))
                  Text("Resets in \(hoursRemaining)h")
                } else {
                  Text("Resets \(nextResetDate, format: .dateTime.month().day())")
                }
              }
            }
            .foqosText(.mark)
          }
          .foregroundStyle(FoqosPalette.cream.mute)
          .padding(.vertical, 6)

          Menu {
            let currentPeriod = strategyManager.getResetPeriodInWeeks()

            Button {
              strategyManager.setResetPeriodInWeeks(2)
            } label: {
              if currentPeriod == 2 {
                Label("2 weeks", systemImage: "checkmark")
              } else {
                Text("2 weeks")
              }
            }

            Button {
              strategyManager.setResetPeriodInWeeks(4)
            } label: {
              if currentPeriod == 4 {
                Label("4 weeks", systemImage: "checkmark")
              } else {
                Text("4 weeks")
              }
            }

            Button {
              strategyManager.setResetPeriodInWeeks(6)
            } label: {
              if currentPeriod == 6 {
                Label("6 weeks", systemImage: "checkmark")
              } else {
                Text("6 weeks")
              }
            }

            Button {
              strategyManager.setResetPeriodInWeeks(8)
            } label: {
              if currentPeriod == 8 {
                Label("8 weeks", systemImage: "checkmark")
              } else {
                Text("8 weeks")
              }
            }
          } label: {
            Image(systemName: "gearshape")
              .font(.footnote)
              .foregroundStyle(FoqosPalette.cream.mute)
              .frame(width: 44, height: 44)
              .contentShape(Rectangle())
          }
          .accessibilityLabel("Reset period")
        }
      }

      Text("Emergency access")
        .foqosDisplay(size: 40)
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityAddTraits(.isHeader)

      Text(
        "Tap the glass to reveal the emergency unblock button. Use only when absolutely necessary."
      )
      .foqosText(.body)
      .foregroundStyle(FoqosPalette.cream.mute)
      .fixedSize(horizontal: false, vertical: true)
    }
    .padding(.top, 16)
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private var statusCard: some View {
    VStack(alignment: .leading, spacing: 14) {
      FoqosHairline()

      HStack(alignment: .firstTextBaseline) {
        Text("Unblocks remaining")
          .foqosText(.eyebrow)
          .foregroundStyle(FoqosPalette.cream.mute)
        Spacer()
        Text("\(emergencyUnblocksRemaining)")
          .foqosDisplay(size: 40)
          .foregroundStyle(hasRemaining ? FoqosPalette.cream.foreground : .red)
      }
      .accessibilityElement(children: .combine)

      Text("You have a limited number of emergency unblocks.")
        .foqosText(.caption)
        .foregroundStyle(FoqosPalette.cream.mute)

      BreakGlassButton(tapsToShatter: 3) {
        FoqosLineButton(
          title: isPerformingEmergencyUnblock ? "Unblocking…" : "Emergency unblock"
        ) {
          performEmergencyUnblock()
        }
        .disabled(isPerformingEmergencyUnblock || !hasRemaining)
      }
      .frame(height: 56)
      .padding(.top, 8)

      if !hasRemaining {
        Text("No emergency unblocks remaining. You're out of luck.")
          .foqosText(.caption)
          .foregroundStyle(.red)
      } else {
        Text("This will reduce your remaining count by 1.")
          .foqosText(.caption)
          .foregroundStyle(FoqosPalette.cream.mute)
      }
    }
  }

  private func performEmergencyUnblock() {
    isPerformingEmergencyUnblock = true

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
      strategyManager.emergencyUnblock(context: context)
      isPerformingEmergencyUnblock = false
      dismiss()
    }
  }
}

struct EmergencyPreviewSheetHost: View {
  @State private var show: Bool = true

  var body: some View {
    Color.clear
      .sheet(isPresented: $show) {
        NavigationView { EmergencyView() }
          .presentationDetents([.medium, .large])
          .presentationDragIndicator(.visible)
      }
  }
}

#Preview {
  EmergencyPreviewSheetHost()
    .environmentObject(StrategyManager())
    .defaultAppStorage(UserDefaults(suiteName: "preview")!)
}
