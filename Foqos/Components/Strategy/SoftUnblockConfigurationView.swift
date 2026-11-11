import SwiftUI

struct SoftUnblockConfigurationView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.foqosPalette) private var palette

  let profileName: String
  let actionTitle: String
  let onStart: (SoftUnblockStrategyData) -> Void

  @State private var maximumUnblockCount: Int
  @State private var accessDurationInMinutes: Int
  @State private var allowanceResetIntervalInHours: Int?
  @State private var lastAllowanceResetIntervalInHours: Int

  init(
    profileName: String,
    initialConfiguration: SoftUnblockStrategyData,
    actionTitle: String = "Start Blocking",
    onStart: @escaping (SoftUnblockStrategyData) -> Void
  ) {
    self.profileName = profileName
    self.actionTitle = actionTitle
    self.onStart = onStart
    _maximumUnblockCount = State(initialValue: initialConfiguration.maximumUnblockCount)
    _accessDurationInMinutes = State(
      initialValue: initialConfiguration.accessDurationInMinutes
    )
    _allowanceResetIntervalInHours = State(
      initialValue: initialConfiguration.allowanceResetIntervalInHours
    )
    _lastAllowanceResetIntervalInHours = State(
      initialValue: initialConfiguration.allowanceResetIntervalInHours
        ?? SoftUnblockStrategyData.defaultEnabledAllowanceResetIntervalInHours
    )
  }

  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        ScrollView {
          VStack(alignment: .leading, spacing: 32) {
            StrategySheetHeader(
              eyebrow: "Temporary access",
              title: "A few short opens",
              message: "Choose how many times blocked apps can open, and for how long."
            )

            VStack(alignment: .leading, spacing: 12) {
              StrategySectionLabel(
                title: "Allowed opens",
                detail: "Each time you open a blocked app or category, it uses one."
              )

              HStack(alignment: .center) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                  StrategyValueDisplay(
                    value: "\(maximumUnblockCount)", size: 44, alignment: .leading)
                  Text(maximumUnblockCount == 1 ? "open" : "opens")
                    .foqosText(.mark)
                    .foregroundStyle(palette.mute)
                }

                Spacer()

                StrategyStepButton(
                  symbol: "−",
                  accessibilityLabel: "Fewer opens",
                  isEnabled: maximumUnblockCount
                    > SoftUnblockStrategyData.unblockCountRange.lowerBound
                ) {
                  maximumUnblockCount -= 1
                }

                StrategyStepButton(
                  symbol: "+",
                  accessibilityLabel: "More opens",
                  isEnabled: maximumUnblockCount
                    < SoftUnblockStrategyData.unblockCountRange.upperBound
                ) {
                  maximumUnblockCount += 1
                }
              }
              .sensoryFeedback(.selection, trigger: maximumUnblockCount)
              .accessibilityElement(children: .contain)
              .accessibilityValue("\(maximumUnblockCount)")
            }

            VStack(alignment: .leading, spacing: 12) {
              StrategySectionLabel(title: "Open time")

              StrategyValueDisplay(value: formattedDuration, size: 44, alignment: .leading)

              Slider(
                value: durationBinding,
                in: Double(
                  SoftUnblockStrategyData.durationRange.lowerBound)...Double(
                    SoftUnblockStrategyData.durationRange.upperBound),
                step: 5
              )
              .tint(palette.foreground)
              .sensoryFeedback(.selection, trigger: accessDurationInMinutes)

              StrategyRangeLabels(lower: "5m", upper: "1h")
            }

            VStack(alignment: .leading, spacing: 12) {
              VStack(alignment: .leading, spacing: 0) {
                FoqosHairline()
                Toggle("Reset opens", isOn: resetEnabledBinding)
              }

              Text(resetDescription)
                .foqosText(.caption)
                .foregroundStyle(palette.mute)
                .fixedSize(horizontal: false, vertical: true)

              if allowanceResetIntervalInHours != nil {
                StrategyValueDisplay(
                  value: formattedResetInterval, size: 44, alignment: .leading)

                Slider(
                  value: resetIntervalBinding,
                  in: resetIntervalRange,
                  step: 1
                )
                .tint(palette.foreground)
                .sensoryFeedback(.selection, trigger: allowanceResetIntervalInHours)
                .accessibilityValue(formattedResetInterval)

                StrategyRangeLabels(lower: "1h", upper: "24h")
              }
            }
          }
          .padding(.horizontal, 24)
          .padding(.top, 24)
          .padding(.bottom, 16)
        }

        startButton
          .padding(.horizontal, 24)
          .padding(.top, 12)
          .padding(.bottom, 16)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .toolbarBackground(palette.background, for: .navigationBar)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button(action: { dismiss() }) {
            Image(systemName: "xmark")
          }
          .accessibilityLabel("Cancel")
        }
      }
      .strategySheetTheme()
    }
  }

  private var startButton: some View {
    ActionButton(
      title: actionTitle
    ) {
      onStart(
        SoftUnblockStrategyData(
          accessDurationInMinutes: accessDurationInMinutes,
          maximumUnblockCount: maximumUnblockCount,
          allowanceResetIntervalInHours: allowanceResetIntervalInHours
        )
      )
      dismiss()
    }
  }

  private var durationBinding: Binding<Double> {
    Binding(
      get: { Double(accessDurationInMinutes) },
      set: { accessDurationInMinutes = Int($0) }
    )
  }

  private var resetEnabledBinding: Binding<Bool> {
    Binding(
      get: { allowanceResetIntervalInHours != nil },
      set: { isEnabled in
        allowanceResetIntervalInHours = isEnabled ? lastAllowanceResetIntervalInHours : nil
      }
    )
  }

  private var resetIntervalBinding: Binding<Double> {
    Binding(
      get: { Double(allowanceResetIntervalInHours ?? lastAllowanceResetIntervalInHours) },
      set: { value in
        let interval = Int(value)
        allowanceResetIntervalInHours = interval
        lastAllowanceResetIntervalInHours = interval
      }
    )
  }

  private var resetIntervalRange: ClosedRange<Double> {
    let range = SoftUnblockStrategyData.allowanceResetIntervalRangeInHours
    return Double(range.lowerBound)...Double(range.upperBound)
  }

  private var formattedDuration: String {
    accessDurationInMinutes == 60 ? "1 hour" : "\(accessDurationInMinutes) minutes"
  }

  private var formattedResetInterval: String {
    let interval = allowanceResetIntervalInHours ?? lastAllowanceResetIntervalInHours
    return interval == 1 ? "1 hour" : "\(interval) hours"
  }

  private var resetDescription: String {
    guard let allowanceResetIntervalInHours else {
      return "Your opens do not reset during this session."
    }

    if allowanceResetIntervalInHours == 1 {
      return "You get all your opens back every hour."
    }

    return "You get all your opens back every \(allowanceResetIntervalInHours) hours."
  }
}

#Preview {
  SoftUnblockConfigurationView(
    profileName: "Deep Work",
    initialConfiguration: SoftUnblockStrategyData(
      accessDurationInMinutes: 15,
      maximumUnblockCount: 3,
      allowanceResetIntervalInHours: 6
    ),
    onStart: { _ in }
  )
}
