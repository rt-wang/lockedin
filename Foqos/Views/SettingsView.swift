import FamilyControls
import SwiftData
import SwiftUI

let TEMU_STORE_LINK =
  "https://www.temu.com/ca/nfc-sticker-with--blank-chip-operating-at-13-56mhz-is-a-rewritable-label-with-504--of-memory-compatible-with-nfc-enabled-smartphones-g-601102251435878.html"
let ALIEXPRESS_STORE_LINK = "https://www.aliexpress.com/item/1005010075431327.html"

struct SettingsView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var context
  @Environment(\.foqosPalette) private var palette
  @EnvironmentObject var requestAuthorizer: RequestAuthorizer
  @EnvironmentObject var strategyManager: StrategyManager

  @State private var showResetBlockingAlert = false
  @State private var showDebugView = false

  private var appVersion: String {
    Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
      ?? "1.0"
  }

  var body: some View {
    NavigationStack {
      Form {
        Section {
          VStack(alignment: .leading, spacing: 12) {
            Text("LockedIn")
              .foqosText(.eyebrow)
            Text("Settings")
              .foqosDisplay(size: 44)
              .accessibilityAddTraits(.isHeader)
          }
          .padding(.bottom, 8)
        }
        .foqosFormRows()
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 4, leading: 20, bottom: 0, trailing: 20))

        AppIconPicker()
          .foqosFormRows()

        Section {
          // TODO(LockedIn): add Help Center / "Block Safari & Settings" guide links once LockedIn
          // has its own support pages. The upstream Foqos pages were removed.
          Button {
            showDebugView = true
          } label: {
            SettingsRow(
              title: "Debug Mode",
              subtitle: "Inspect sessions, schedules, and timers.",
              trailing: "→"
            )
          }
          .buttonStyle(FoqosPressStyle())

          if !strategyManager.isBlocking {
            Button {
              showResetBlockingAlert = true
            } label: {
              SettingsRow(
                title: "Fix Stuck Blocking",
                subtitle: "Clear restrictions left behind after a session.",
                trailing: "→"
              )
            }
            .buttonStyle(FoqosPressStyle())
          }
        } header: {
          FoqosSectionHeader("Troubleshooting")
        }
        .foqosFormRows()

        Section {
          SettingsValueRow(title: "Version", value: "v\(appVersion)")

          HStack(alignment: .firstTextBaseline) {
            Text("Screen Time Access")
              .foqosText(.body)
            Spacer()
            HStack(spacing: 8) {
              Circle()
                .fill(
                  requestAuthorizer.getAuthorizationStatus() == .approved
                    ? FoqosColors.forest : Color.red
                )
                .frame(width: 6, height: 6)
              Text(
                requestAuthorizer.getAuthorizationStatus() == .approved
                  ? "Authorized" : "Not Authorized"
              )
              .foqosText(.mark)
              .foregroundStyle(palette.mute)
            }
          }
          .padding(.vertical, 6)
        } header: {
          FoqosSectionHeader("About")
        }
        .foqosFormRows()

        Section {
          Link(destination: URL(string: TEMU_STORE_LINK)!) {
            SettingsRow(title: "Temu", trailing: "↗")
          }

          Link(destination: URL(string: ALIEXPRESS_STORE_LINK)!) {
            SettingsRow(title: "AliExpress", trailing: "↗")
          }
        } header: {
          FoqosSectionHeader("Buy NFC Tags")
        }
        .foqosFormRows()
      }
      .foqosForm(.cream)
      .navigationTitle("Settings")
      .navigationBarTitleDisplayMode(.inline)
      .toolbarBackground(FoqosColors.cream, for: .navigationBar)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button(action: { dismiss() }) {
            Image(systemName: "xmark")
          }
          .accessibilityLabel("Close")
        }
      }
      .tint(FoqosColors.forest)
      .alert("Fix Stuck Blocking?", isPresented: $showResetBlockingAlert) {
        Button("Cancel", role: .cancel) {}
        Button("Fix Blocking", role: .destructive) {
          strategyManager.resetBlockingState(context: context)
        }
      } message: {
        Text(
          "Clear stuck restrictions on this iPhone and your synced Mac. Your profiles and history will be kept."
        )
      }
      .sheet(isPresented: $showDebugView) {
        DebugView()
      }
      #if DEBUG
        .onAppear {
          if ProcessInfo.processInfo.arguments.contains("--open-debug") { showDebugView = true }
        }
      #endif
    }
  }
}

private struct SettingsRow: View {
  @Environment(\.foqosPalette) private var palette

  let title: String
  var subtitle: String? = nil
  var trailing: String? = nil

  // Mirrors the home screen's row actions: bold uppercase title, caption, trailing arrow.
  var body: some View {
    HStack(alignment: .firstTextBaseline, spacing: 12) {
      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .foqosText(.toggle)
          .foregroundStyle(palette.foreground)
        if let subtitle {
          Text(subtitle)
            .foqosText(.caption)
            .foregroundStyle(palette.mute)
            .fixedSize(horizontal: false, vertical: true)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      if let trailing {
        Text(trailing)
          .foqosText(.cta)
          .foregroundStyle(palette.foreground)
          .accessibilityHidden(true)
      }
    }
    .padding(.vertical, 10)
    .contentShape(Rectangle())
  }
}

private struct SettingsValueRow: View {
  @Environment(\.foqosPalette) private var palette

  let title: String
  let value: String

  var body: some View {
    HStack(alignment: .firstTextBaseline) {
      Text(title)
        .foqosText(.body)
      Spacer()
      Text(value)
        .foqosText(.caption)
        .foregroundStyle(palette.mute)
    }
    .padding(.vertical, 6)
  }
}

#Preview {
  SettingsView()
    .environmentObject(RequestAuthorizer())
    .environmentObject(StrategyManager.shared)
    .modelContainer(for: BlockedProfiles.self, inMemory: true)
}
