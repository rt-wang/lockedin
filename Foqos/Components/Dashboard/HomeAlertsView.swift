import SwiftUI

struct HomeAlertsView: View {
  let alerts: [HomeAlert]
  let onAlertTapped: (HomeAlert) -> Void

  var body: some View {
    if !alerts.isEmpty {
      VStack(alignment: .leading, spacing: 0) {
        SectionTitle("Alerts")

        FoqosHairline()

        ForEach(alerts) { alert in
          Button {
            onAlertTapped(alert)
          } label: {
            HomeAlertRow(alert: alert)
          }
          .buttonStyle(FoqosPressStyle())

          FoqosHairline()
        }
      }
    }
  }
}

private struct HomeAlertRow: View {
  @Environment(\.foqosPalette) private var palette

  let alert: HomeAlert

  var body: some View {
    HStack(alignment: .firstTextBaseline, spacing: 12) {
      Image(systemName: alert.iconName)
        .font(.system(size: 15, weight: .semibold))
        .accessibilityHidden(true)

      VStack(alignment: .leading, spacing: 4) {
        Text(alert.title)
          .foqosText(.toggle)
          .multilineTextAlignment(.leading)

        Text(alert.message)
          .foqosText(.caption)
          .foregroundStyle(palette.mute)
          .multilineTextAlignment(.leading)
          .lineLimit(2)
      }
      .frame(maxWidth: .infinity, alignment: .leading)

      Text("→")
        .foqosText(.cta)
        .accessibilityHidden(true)
    }
    .padding(.vertical, 16)
    .contentShape(Rectangle())
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(alert.title)
    .accessibilityHint(alert.message)
  }
}

struct HomeAlertDetailView: View {
  @Environment(\.dismiss) private var dismiss

  let alert: HomeAlert
  let disabledReason: String?
  let onPrimaryAction: () -> Void

  private var canRunPrimaryAction: Bool { disabledReason == nil }

  var body: some View {
    NavigationStack {
      VStack(alignment: .leading, spacing: 0) {
        Image(systemName: alert.iconName)
          .font(.system(size: 28, weight: .regular))
          .accessibilityHidden(true)
          .padding(.top, 24)
          .padding(.bottom, 20)

        Text(alert.title)
          .foqosDisplay(size: 40)
          .fixedSize(horizontal: false, vertical: true)
          .accessibilityAddTraits(.isHeader)
          .padding(.bottom, 16)

        Text(alert.detailMessage)
          .foqosText(.body)
          .foregroundStyle(FoqosPalette.cream.mute)
          .fixedSize(horizontal: false, vertical: true)

        if let disabledReason {
          VStack(alignment: .leading, spacing: 12) {
            FoqosHairline()

            Text(disabledReason)
              .foqosText(.caption)
              .foregroundStyle(FoqosPalette.cream.mute)
              .fixedSize(horizontal: false, vertical: true)
          }
          .padding(.top, 24)
        }

        Spacer(minLength: 24)

        FoqosLineButton(title: alert.primaryActionTitle, action: runPrimaryAction)
          .disabled(!canRunPrimaryAction)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.horizontal, 24)
      .padding(.bottom, 16)
      .foqosTheme(.cream)
      .navigationTitle("Details")
      .navigationBarTitleDisplayMode(.inline)
      .toolbarBackground(FoqosColors.cream, for: .navigationBar)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button {
            dismiss()
          } label: {
            Image(systemName: "xmark")
          }
          .accessibilityLabel("Cancel")
        }
      }
    }
    .tint(FoqosColors.forest)
  }

  private func runPrimaryAction() {
    onPrimaryAction()
    dismiss()
  }
}

#Preview {
  HomeAlertsView(
    alerts: [
      HomeAlert(
        type: .screenTimeAccess,
        title: "Screen Time access needed",
        message: "Blocking is paused until access is restored.",
        detailMessage:
          "Foqos needs Screen Time access to block apps and websites. Grant access again to restore blocking.",
        primaryActionTitle: "Allow Screen Time Access",
        iconName: "exclamationmark.shield.fill"
      )
    ],
    onAlertTapped: { _ in }
  )
  .padding()
  .foqosTheme(.cream)
}
