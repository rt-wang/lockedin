import SwiftUI

struct PauseDurationView: View {
  @Environment(\.foqosPalette) private var palette
  @Environment(\.dismiss) private var dismiss

  let profileName: String
  var title: String = "Pause duration"
  var description: String? = nil
  let actionTitle: String
  let onDurationSelected: (Int) -> Void

  // State for slider-based duration selection
  @State private var durationMinutes: Double
  @State private var isSliding = false

  // Constants - max 1 hour for pause duration
  private let minMinutes: Double = 5
  private let maxMinutes: Double = 60
  private let smallIncrement: Double = 5

  // Common snap points (in minutes)
  private let snapPoints: [Double] = [5, 10, 15, 20, 30, 45, 60]
  private let snapThreshold: Double = 3  // How close to snap (in minutes)

  init(
    profileName: String,
    title: String = "Pause duration",
    description: String? = nil,
    initialDurationMinutes: Int = StrategyPauseTimerData.defaultPauseDurationInMinutes,
    actionTitle: String = "Start Blocking",
    onDurationSelected: @escaping (Int) -> Void
  ) {
    self.profileName = profileName
    self.title = title
    self.description = description
    self.actionTitle = actionTitle
    self.onDurationSelected = onDurationSelected
    _durationMinutes = State(initialValue: Double(initialDurationMinutes))
  }

  var body: some View {
    VStack(spacing: 28) {
      StrategySheetHeader(
        eyebrow: "Pause",
        title: title,
        message: description
          ?? "Select how long you want to allow access when pausing \(profileName)."
      )
      .padding(.top, 16)

      // Large time display
      timeDisplay

      // Slider with +/- buttons
      sliderControls

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
    StrategyValueDisplay(value: formattedDuration, caption: "Access duration")
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

        StrategyRangeLabels(lower: "5m", upper: "1h")
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

  private func handleConfirm() {
    onDurationSelected(Int(durationMinutes))
    dismiss()
  }
}

struct PauseDurationPreviewSheetHost: View {
  @State private var show: Bool = true

  var body: some View {
    Color.clear
      .sheet(isPresented: $show) {
        NavigationView {
          PauseDurationView(
            profileName: "Work Focus",
            onDurationSelected: { minutes in
              print("Selected pause duration: \(minutes) minutes")
            }
          )
        }
        .presentationDetents([.medium, .large])
      }
  }
}

#Preview {
  PauseDurationPreviewSheetHost()
}
