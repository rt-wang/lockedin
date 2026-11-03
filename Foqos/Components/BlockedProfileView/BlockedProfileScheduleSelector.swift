import SwiftUI

struct BlockedProfileScheduleSelector: View {
  var schedule: BlockedProfileSchedule
  var buttonAction: () -> Void
  var disabled: Bool = false
  var disabledText: String?

  private var buttonText: String { "Set schedule" }

  private var daysCount: Int { schedule.days.count }

  var body: some View {
    Button(action: buttonAction) {
      ProfileFormActionRow(title: buttonText)
    }
    .buttonStyle(FoqosPressStyle())
    .disabled(disabled)

    if let disabledText = disabledText, disabled {
      ProfileFormCaption(disabledText, isWarning: true)
    } else if daysCount == 0 {
      ProfileFormCaption("No schedule set")
    } else {
      ProfileFormCaption(schedule.summaryText)
    }
  }
}

#Preview {
  VStack(spacing: 20) {
    BlockedProfileScheduleSelector(
      schedule: .init(
        days: [.monday, .wednesday, .friday], startHour: 9, startMinute: 0, endHour: 17,
        endMinute: 0, updatedAt: Date()),
      buttonAction: {}
    )

    BlockedProfileScheduleSelector(
      schedule: .init(
        days: [], startHour: 9, startMinute: 0, endHour: 17, endMinute: 0, updatedAt: Date()),
      buttonAction: {},
      disabled: true,
      disabledText: "Disable the current session to edit schedule"
    )
  }
  .padding()
  .foqosTheme(.cream)
}
