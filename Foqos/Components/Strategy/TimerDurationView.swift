import SwiftUI

struct TimerDurationView: View {
  @Environment(\.foqosPalette) private var palette
  @Environment(\.dismiss) private var dismiss

  let profileName: String
  let actionTitle: String
  let onDurationSelected: (StrategyTimerData) -> Void

  // State for slider-based duration selection
  @State private var durationMinutes: Double
  @State private var isSliding = false
  @State private var hideStopButton: Bool

  // Constants
  private let minMinutes: Double = 15
  private let maxMinutes: Double = 1439  // 23h 59m
  private let smallIncrement: Double = 5
  private let largeIncrement: Double = 15

  // Common snap points (in minutes)
  private let snapPoints: [Double] = [15, 30, 45, 60, 90, 120, 180, 240, 360, 480, 720, 1440]
  private let snapThreshold: Double = 10  // How close to snap (in minutes)

  init(
    profileName: String,
    initialConfiguration: StrategyTimerData = .defaultConfiguration,
    actionTitle: String = "Set Duration",
    onDurationSelected: @escaping (StrategyTimerData) -> Void
  ) {
    self.profileName = profileName
    self.actionTitle = actionTitle
    self.onDurationSelected = onDurationSelected
    _durationMinutes = State(initialValue: Double(initialConfiguration.durationInMinutes))
    _hideStopButton = State(initialValue: initialConfiguration.hideStopButton)
  }

  var body: some View {
    VStack(spacing: 28) {
      StrategySheetHeader(
        eyebrow: "Timer",
        title: "How long?",
        message: "Select how long you want \(profileName) to last."
      )
      .padding(.top, 16)

      // Large time display
      timeDisplay

      // Slider with +/- buttons
      sliderControls

      // Hide stop button toggle
      hideStopButtonToggle

      // Confirm button
      ActionButton(
        title: actionTitle
      ) {
        handleConfirm()
      }
    }
    .padding(24)
    .strategySheetTheme()
  }

  private var timeDisplay: some View {
    StrategyValueDisplay(value: formattedDuration)
      .animation(.spring(response: 0.3, dampingFraction: 0.8), value: durationMinutes)
      .frame(maxWidth: .infinity)
      .padding(.vertical, 8)
  }

  private var sliderControls: some View {
    HStack(alignment: .top, spacing: 8) {
      StrategyStepButton(
        symbol: "−",
        accessibilityLabel: "Decrease duration",
        isEnabled: durationMinutes > minMinutes,
        action: decrementDuration
      )
      .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.5), trigger: durationMinutes)

      VStack(spacing: 8) {
        Slider(
          value: $durationMinutes,
          in: minMinutes...maxMinutes,
          step: 5,
          onEditingChanged: { editing in
            isSliding = editing
            if !editing {
              snapToNearestPreset()
            }
          }
        )
        .tint(palette.foreground)
        .sensoryFeedback(.selection, trigger: durationMinutes)

        StrategyRangeLabels(lower: "15m", upper: "24h")
      }
      .padding(.top, 6)

      StrategyStepButton(
        symbol: "+",
        accessibilityLabel: "Increase duration",
        isEnabled: durationMinutes < maxMinutes,
        action: incrementDuration
      )
      .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.5), trigger: durationMinutes)
    }
  }

  // MARK: - Helper Functions

  private var formattedDuration: String {
    let totalMinutes = Int(durationMinutes)
    let hours = totalMinutes / 60
    let minutes = totalMinutes % 60

    if hours == 0 {
      return "\(minutes)m"
    } else if minutes == 0 {
      return "\(hours)h"
    } else {
      return "\(hours)h \(minutes)m"
    }
  }

  private var descriptiveText: String {
    let totalMinutes = Int(durationMinutes)
    let hours = totalMinutes / 60
    let minutes = totalMinutes % 60

    if hours == 0 {
      return "\(minutes) minutes"
    } else if minutes == 0 {
      return hours == 1 ? "1 hour" : "\(hours) hours"
    } else {
      let hourText = hours == 1 ? "hour" : "hours"
      let minuteText = minutes == 1 ? "minute" : "minutes"
      return "\(hours) \(hourText) and \(minutes) \(minuteText)"
    }
  }

  private func incrementDuration() {
    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
      durationMinutes = min(durationMinutes + smallIncrement, maxMinutes)
    }
  }

  private func decrementDuration() {
    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
      durationMinutes = max(durationMinutes - smallIncrement, minMinutes)
    }
  }

  private func snapToNearestPreset() {
    // Find the closest snap point
    if let closest = snapPoints.min(by: { abs($0 - durationMinutes) < abs($1 - durationMinutes) }) {
      let distance = abs(closest - durationMinutes)
      if distance <= snapThreshold {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
          durationMinutes = closest
        }
      }
    }
  }

  private var hideStopButtonToggle: some View {
    VStack(alignment: .leading, spacing: 2) {
      FoqosHairline()
      Toggle("Disable stop button", isOn: $hideStopButton)
      Text("Prevent early stopping during timer sessions.")
        .foqosText(.caption)
        .foregroundStyle(palette.mute)
        .fixedSize(horizontal: false, vertical: true)
    }
  }

  private func handleConfirm() {
    let data = StrategyTimerData(
      durationInMinutes: Int(durationMinutes), hideStopButton: hideStopButton
    )
    onDurationSelected(data)
    dismiss()
  }
}

struct TimerDurationPreviewSheetHost: View {
  @State private var show: Bool = true

  var body: some View {
    Color.clear
      .sheet(isPresented: $show) {
        NavigationView {
          TimerDurationView(
            profileName: "Work Focus",
            onDurationSelected: { timerData in
              print("Selected duration: \(timerData.durationInMinutes) minutes")
            }
          )
        }
        .presentationDetents([.medium, .large])
      }
  }
}

#Preview {
  TimerDurationPreviewSheetHost()
}
