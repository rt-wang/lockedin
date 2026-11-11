import AppIntents
import SwiftUI
import WidgetKit

struct ProfileControlWidget: Widget {
  let kind = "ProfileControlWidget"

  var body: some WidgetConfiguration {
    AppIntentConfiguration(
      kind: kind, intent: ProfileSelectionIntent.self, provider: ProfileControlProvider()
    ) { entry in
      ProfileWidgetEntryView(entry: entry)
        .containerBackground(for: .widget) {
          ProfileWidgetBackground()
        }
    }
    .configurationDisplayName("LockedIn Profile")
    .description(
      "Your focus, at a glance. Weekly charts, and a monthly activity grid for your profile."
    )
    .supportedFamilies([
      .systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular, .accessoryInline,
    ])
  }
}
