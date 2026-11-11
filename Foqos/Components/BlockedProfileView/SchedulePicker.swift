import SwiftUI

struct SchedulePicker: View {
  @Environment(\.foqosPalette) private var palette

  @Binding var schedule: BlockedProfileSchedule
  @Binding var isPresented: Bool

  private let hours12: [Int] = Array(1...12)
  private let minutes: [Int] = Array(stride(from: 0, through: 55, by: 5))

  @State private var startDisplayHour: Int = 9
  @State private var startMinute: Int = 0
  @State private var startIsPM: Bool = false
  @State private var endDisplayHour: Int = 10
  @State private var endMinute: Int = 0
  @State private var endIsPM: Bool = false
  @State private var selectedDays: [Weekday] = []
  @State private var showStartPicker: Bool = false
  @State private var showEndPicker: Bool = false

  private let minimumDurationMinutes: Int = 60

  private var startTotalMinutes: Int {
    hour12To24(startDisplayHour, isPM: startIsPM) * 60 + startMinute
  }
  private var endTotalMinutes: Int { hour12To24(endDisplayHour, isPM: endIsPM) * 60 + endMinute }

  private var durationMinutes: Int {
    // If end is before start, it's a cross-day schedule
    if endTotalMinutes <= startTotalMinutes {
      // Duration spans to next day: (minutes until midnight) + (minutes from midnight to end)
      return (24 * 60 - startTotalMinutes) + endTotalMinutes
    }
    return endTotalMinutes - startTotalMinutes
  }

  private var isValid: Bool {
    !selectedDays.isEmpty && durationMinutes >= minimumDurationMinutes
  }

  private var validationMessage: String? {
    guard !isValid else { return nil }

    if selectedDays.isEmpty {
      return ""
    }

    return "Schedule must be at least 1 hour long."
  }

  private var draftSchedule: BlockedProfileSchedule {
    BlockedProfileSchedule(
      days: selectedDays,
      startHour: hour12To24(startDisplayHour, isPM: startIsPM),
      startMinute: startMinute,
      endHour: hour12To24(endDisplayHour, isPM: endIsPM),
      endMinute: endMinute
    )
  }

  private var nextStartMessage: String? {
    draftSchedule.nextStartMessage()
  }

  var body: some View {
    NavigationStack {
      Form {
        Section {
          VStack(alignment: .leading, spacing: 14) {
            ProfileSheetHeader(
              eyebrow: "Schedule",
              title: "When should it run?",
              message:
                "Choose when this profile starts and ends. To end early, use the strategy you set up earlier. The schedule must be at least 1 hour long."
            )

            if let message = nextStartMessage {
              Text(message)
                .foqosText(.mark)
                .foregroundStyle(palette.foreground)
            }
          }
        }
        .profileSheetHeaderRow()

        Section {
          HStack(spacing: 0) {
            ForEach(Weekday.allCases, id: \.rawValue) { day in
              let isSelected = selectedDays.contains(day)
              Button(action: {
                if isSelected {
                  selectedDays.removeAll { $0 == day }
                } else {
                  selectedDays.append(day)
                }

                // Hide time pickers when no days are selected
                if selectedDays.isEmpty {
                  showStartPicker = false
                  showEndPicker = false
                }
              }) {
                Text(shortLabel(for: day))
                  .foqosText(.tab)
                  .foregroundStyle(isSelected ? palette.foreground : palette.mute)
                  .padding(.bottom, 6)
                  .overlay(alignment: .bottom) {
                    Rectangle()
                      .fill(isSelected ? palette.foreground : Color.clear)
                      .frame(height: 1)
                  }
                  .frame(maxWidth: .infinity, minHeight: 44)
                  .contentShape(Rectangle())
                  .accessibilityLabel(day.name)
                  .accessibilityAddTraits(isSelected ? .isSelected : [])
              }
              .buttonStyle(FoqosPressStyle())
            }
          }
        } header: {
          FoqosSectionHeader("Days")
        } footer: {
          if !selectedDays.isEmpty {
            Text("Schedules take 15 minutes to update")
              .foqosText(.caption)
              .foregroundStyle(palette.mute)
          }
        }
        .foqosFormRows()

        Section {
          Button(action: toggleStartPicker) {
            timeRow(
              title: "When to start",
              value: formattedTimeString(
                hour: startDisplayHour, minute: startMinute, isPM: startIsPM)
            )
          }
          .buttonStyle(FoqosPressStyle())
          .disabled(selectedDays.isEmpty)

          if showStartPicker {
            timePickers(hour: $startDisplayHour, minute: $startMinute, isPM: $startIsPM)
          }
        } header: {
          FoqosSectionHeader("Start time")
        }
        .foqosFormRows()

        Section {
          Button(action: toggleEndPicker) {
            timeRow(
              title: "When to end",
              value: formattedTimeString(hour: endDisplayHour, minute: endMinute, isPM: endIsPM)
            )
          }
          .buttonStyle(FoqosPressStyle())
          .disabled(selectedDays.isEmpty)

          if showEndPicker {
            timePickers(hour: $endDisplayHour, minute: $endMinute, isPM: $endIsPM)
          }
        } header: {
          FoqosSectionHeader("End time")
        } footer: {
          if let validationMessage {
            Text(validationMessage)
              .foqosText(.caption)
              .foregroundStyle(palette.foreground)
          }
        }
        .foqosFormRows()

        Section {
          Button {
            resetToDefault()

            applySelection()
            isPresented = false
          } label: {
            ProfileFormActionRow(title: "Remove schedule", isDestructive: true)
          }
          .buttonStyle(FoqosPressStyle())
        } footer: {
          Text("If you're looking for more granularity, you can use Shortcuts automations.")
            .foqosText(.caption)
            .foregroundStyle(palette.mute)
        }
        .foqosFormRows()
      }
      .foqosForm(.cream)
      .navigationTitle("Schedule")
      .navigationBarTitleDisplayMode(.inline)
      .profileSheetChrome()
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button(action: { isPresented = false }) {
            Image(systemName: "xmark")
          }
          .accessibilityLabel("Cancel")
        }

        ToolbarItem(placement: .topBarTrailing) {
          Button(action: {
            applySelection()
            isPresented = false
          }) {
            Image(systemName: "checkmark")
          }
          .disabled(!isValid)
          .accessibilityLabel("Save")
        }
      }
      .onAppear(perform: loadFromBinding)
    }
  }

  private func timeRow(title: String, value: String) -> some View {
    HStack(alignment: .firstTextBaseline) {
      Text(title)
        .foqosText(.body)
        .foregroundStyle(palette.foreground)
      Spacer()
      Text(value)
        .foqosText(.cta)
        .foregroundStyle(palette.foreground)
        .monospacedDigit()
    }
    .frame(minHeight: 36)
    .contentShape(Rectangle())
  }

  @ViewBuilder
  private func timePickers(hour: Binding<Int>, minute: Binding<Int>, isPM: Binding<Bool>)
    -> some View
  {
    HStack {
      Picker("Hour", selection: hour) {
        ForEach(hours12, id: \.self) { h in
          Text(String(format: "%02d", h)).tag(h)
        }
      }
      .labelsHidden()
      .pickerStyle(.wheel)
      .frame(maxWidth: .infinity)

      Text(":")
        .foqosText(.cta)
        .foregroundStyle(palette.mute)

      Picker("Minute", selection: minute) {
        ForEach(minutes, id: \.self) { m in
          Text(String(format: "%02d", m)).tag(m)
        }
      }
      .labelsHidden()
      .pickerStyle(.wheel)
      .frame(maxWidth: .infinity)

      Picker("AM/PM", selection: isPM) {
        Text("AM").tag(false)
        Text("PM").tag(true)
      }
      .labelsHidden()
      .pickerStyle(.wheel)
      .frame(maxWidth: .infinity)
    }
    .font(FoqosFont.ui(.title3, size: 20, bold: false))
  }

  private func loadFromBinding() {
    // Days
    selectedDays = schedule.days

    // Start time
    setDisplay(from24Hour: schedule.startHour, forStart: true)
    startMinute = roundedToFive(schedule.startMinute)

    // End time
    setDisplay(from24Hour: schedule.endHour, forStart: false)
    endMinute = roundedToFive(schedule.endMinute)
  }

  private func applySelection() {
    schedule.days = selectedDays.sorted { $0.rawValue < $1.rawValue }

    schedule.startHour = hour12To24(startDisplayHour, isPM: startIsPM)
    schedule.startMinute = startMinute
    schedule.endHour = hour12To24(endDisplayHour, isPM: endIsPM)
    schedule.endMinute = endMinute
  }

  private func roundedToFive(_ value: Int) -> Int {
    let remainder = value % 5
    let down = value - remainder
    let up = min(value + (5 - remainder), 55)
    // Choose the nearer multiple; tie rounds up
    if remainder == 0 { return value }
    if value - down < up - value { return down }
    return up
  }

  private func setDisplay(from24Hour hour24: Int, forStart: Bool) {
    let converted = from24ToDisplay(hour24)
    if forStart {
      startDisplayHour = converted.hour
      startIsPM = converted.isPM
    } else {
      endDisplayHour = converted.hour
      endIsPM = converted.isPM
    }
  }

  private func from24ToDisplay(_ hour24: Int) -> (hour: Int, isPM: Bool) {
    let isPM = hour24 >= 12
    var hour = hour24 % 12
    if hour == 0 { hour = 12 }
    return (hour, isPM)
  }

  private func hour12To24(_ hour12: Int, isPM: Bool) -> Int {
    if hour12 == 12 { return isPM ? 12 : 0 }
    return isPM ? hour12 + 12 : hour12
  }

  private func shortLabel(for day: Weekday) -> String {
    switch day {
    case .sunday: return "Su"
    case .monday: return "Mo"
    case .tuesday: return "Tu"
    case .wednesday: return "We"
    case .thursday: return "Th"
    case .friday: return "Fr"
    case .saturday: return "Sa"
    }
  }

  private func formattedTimeString(hour: Int, minute: Int, isPM: Bool) -> String {
    "\(hour):\(String(format: "%02d", minute)) \(isPM ? "PM" : "AM")"
  }

  private func toggleStartPicker() {
    withAnimation(.easeInOut) {
      showStartPicker.toggle()
      if showStartPicker { showEndPicker = false }
    }
  }

  private func toggleEndPicker() {
    withAnimation(.easeInOut) {
      showEndPicker.toggle()
      if showEndPicker { showStartPicker = false }
    }
  }

  private func resetToDefault() {
    // Reset to default values: empty days, 9AM-5PM
    selectedDays = []
    startDisplayHour = 9
    startMinute = 0
    startIsPM = false
    endDisplayHour = 5
    endMinute = 0
    endIsPM = true
  }
}

#Preview {
  @Previewable @State var isPresented: Bool = true
  @Previewable @State var schedule: BlockedProfileSchedule = .init(
    days: [],
    startHour: 9,
    startMinute: 0,
    endHour: 11,
    endMinute: 0,
    updatedAt: Date()
  )

  return SchedulePicker(schedule: $schedule, isPresented: $isPresented)
}
