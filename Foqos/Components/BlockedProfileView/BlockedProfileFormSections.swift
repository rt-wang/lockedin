import FamilyControls
import SwiftUI

private struct ProfileFieldDivider: View {
  var isVisible: Bool

  var body: some View {
    if isVisible {
      FoqosHairline()
    }
  }
}

struct BlockedProfileNameFields: View {
  @ObservedObject var draft: BlockedProfileDraft
  var disabled: Bool
  var showsFieldLabels: Bool = true

  var body: some View {
    TextField(
      showsFieldLabels ? "Profile Name" : "",
      text: $draft.name,
      prompt: Text("Profile Name")
    )
    .font(FoqosFont.ui(.body, size: 17, bold: false))
    .textContentType(.none)
    .disabled(disabled)
  }
}

struct BlockedProfileNameSection: View {
  @ObservedObject var draft: BlockedProfileDraft
  var disabled: Bool

  var body: some View {
    Section {
      BlockedProfileNameFields(draft: draft, disabled: disabled)
    } header: {
      FoqosSectionHeader("Name")
    }
    .foqosFormRows()
  }
}

struct BlockedProfileStrategyFields: View {
  @ObservedObject var draft: BlockedProfileDraft
  @Binding var showingStrategyPicker: Bool
  var disabled: Bool
  var showsSeparators: Bool = false

  var body: some View {
    Button(action: { showingStrategyPicker = true }) {
      ProfileFormActionRow(
        title: draft.selectedStrategy == nil ? "Choose strategy" : "Change strategy")
    }
    .buttonStyle(FoqosPressStyle())
    .disabled(disabled)

    if let selectedStrategy = draft.selectedStrategy {
      ProfileFieldDivider(isVisible: showsSeparators)

      StrategyRow(
        strategy: selectedStrategy,
        isSelected: false,
        onTap: {},
        accessoryStyle: .none
      )
      .allowsHitTesting(false)
    }
  }
}

struct BlockedProfileStrategySection: View {
  @ObservedObject var draft: BlockedProfileDraft
  @Binding var showingStrategyPicker: Bool
  var disabled: Bool
  var showsStartSettings: Bool = false
  var onUpdateStartSettings: ((StrategyStartSettingsKind) -> Void)?

  var body: some View {
    Section {
      BlockedProfileStrategyFields(
        draft: draft,
        showingStrategyPicker: $showingStrategyPicker,
        disabled: disabled
      )

      if showsStartSettings,
        let settingsKind = StrategyStartSettingsKind(strategy: draft.selectedStrategy)
      {
        Button {
          onUpdateStartSettings?(settingsKind)
        } label: {
          ProfileFormActionRow(title: "Update start settings")
        }
        .buttonStyle(FoqosPressStyle())
        .disabled(disabled)

        CustomToggle(
          title: "Ask Me Every Time",
          description: "Turn off to use the saved settings automatically.",
          isOn: $draft.askForStartSettings,
          isDisabled: disabled
        )
      }
    } header: {
      FoqosSectionHeader("Blocking Strategy")
    }
    .foqosFormRows()
  }
}

struct BlockedProfileAppsFields: View {
  @ObservedObject var draft: BlockedProfileDraft
  @Binding var showingActivityPicker: Bool
  var disabled: Bool
  var showsSeparators: Bool = false

  var body: some View {
    BlockedProfileAppSelector(
      selection: draft.selectedActivity,
      buttonAction: { showingActivityPicker = true },
      allowMode: draft.enableAllowMode,
      disabled: disabled
    )

    ProfileFieldDivider(isVisible: showsSeparators)

    CustomToggle(
      title: "Allow Only Selected Apps",
      description:
        "Only selected apps stay available during sessions. Turning this on clears your blocked-app selection.",
      isOn: $draft.enableAllowMode,
      isDisabled: disabled || !draft.selectedStrategySupportsAllowMode,
      errorMessage: draft.selectedStrategySupportsAllowMode
        ? nil : "Allow-only mode isn't supported with Temporary Access."
    )

    ProfileFieldDivider(isVisible: showsSeparators)

    CustomToggle(
      title: "Block Websites in Safari",
      description:
        "Also block selected websites in Safari. When off, Safari stays unrestricted.",
      isOn: $draft.enableSafariBlocking,
      isDisabled: disabled
    )
    .onChange(of: draft.enableAllowMode) { _, newValue in
      draft.selectedActivity = FamilyActivitySelection(includeEntireCategory: newValue)
    }
  }
}

struct BlockedProfileAppsSection: View {
  @ObservedObject var draft: BlockedProfileDraft
  @Binding var showingActivityPicker: Bool
  var disabled: Bool

  var body: some View {
    Section {
      BlockedProfileAppsFields(
        draft: draft,
        showingActivityPicker: $showingActivityPicker,
        disabled: disabled
      )
    } header: {
      FoqosSectionHeader((draft.enableAllowMode ? "Allowed" : "Blocked") + " Apps")
    }
    .foqosFormRows()
  }
}

struct BlockedProfileDomainsFields: View {
  @ObservedObject var draft: BlockedProfileDraft
  @Binding var showingDomainPicker: Bool
  var disabled: Bool
  var showsSeparators: Bool = false

  var body: some View {
    BlockedProfileDomainSelector(
      domains: draft.domains,
      buttonAction: { showingDomainPicker = true },
      allowMode: draft.enableAllowModeDomain,
      disabled: disabled
    )

    ProfileFieldDivider(isVisible: showsSeparators)

    CustomToggle(
      title: "Sync to Mac",
      description:
        "Block the same selected domains on your Mac with the LockedIn for Mac app.",
      isOn: $draft.enableMacSync,
      isDisabled: disabled
        // TODO(LockedIn): add a learnMoreURL once LockedIn has its own Mac setup page.
    )
    .onChange(of: draft.enableMacSync) { _, newValue in
      if newValue {
        draft.enableAllowModeDomain = false
        draft.enableAdultContentBlocking = false
      }
    }

    ProfileFieldDivider(isVisible: showsSeparators)

    CustomToggle(
      title: "Allow Only Selected Domains",
      description:
        "Only selected domains stay available during sessions.",
      isOn: $draft.enableAllowModeDomain,
      isDisabled: disabled || draft.enableMacSync,
      errorMessage: draft.enableMacSync ? "Allow-only mode isn't supported on Mac." : nil
    )

    ProfileFieldDivider(isVisible: showsSeparators)

    CustomToggle(
      title: "Block Adult Websites",
      description:
        "Use Apple's adult-content filter during sessions. You can still add extra domains to block.",
      isOn: $draft.enableAdultContentBlocking,
      isDisabled: disabled || draft.enableMacSync,
      errorMessage: draft.enableMacSync ? "Adult website blocking isn't supported on Mac." : nil
    )
    .onChange(of: draft.enableAllowModeDomain) { _, newValue in
      if newValue {
        draft.enableAdultContentBlocking = false
      }
    }
    .onChange(of: draft.enableAdultContentBlocking) { _, newValue in
      if newValue {
        draft.enableAllowModeDomain = false
      }
    }
  }
}

struct BlockedProfileDomainsSection: View {
  @ObservedObject var draft: BlockedProfileDraft
  @Binding var showingDomainPicker: Bool
  var disabled: Bool

  var body: some View {
    Section {
      BlockedProfileDomainsFields(
        draft: draft,
        showingDomainPicker: $showingDomainPicker,
        disabled: disabled
      )
    } header: {
      FoqosSectionHeader((draft.enableAllowModeDomain ? "Allowed" : "Blocked") + " Domains")
    }
    .foqosFormRows()
  }
}

struct BlockedProfileStrictUnlocksFields: View {
  @ObservedObject var draft: BlockedProfileDraft
  var disabled: Bool

  var body: some View {
    BlockedProfilePhysicalUnblockSelector(
      physicalUnblockItems: $draft.physicalUnblockItems,
      disabled: disabled
    )
  }
}

struct BlockedProfileStrictUnlocksSection: View {
  @ObservedObject var draft: BlockedProfileDraft
  var disabled: Bool

  var body: some View {
    Section {
      BlockedProfileStrictUnlocksFields(draft: draft, disabled: disabled)
    } header: {
      FoqosSectionHeader("Physical Unlocks")
    }
    .foqosFormRows()
  }
}

struct BlockedProfileScheduleFields: View {
  @ObservedObject var draft: BlockedProfileDraft
  @Binding var showingSchedulePicker: Bool
  var disabled: Bool

  var body: some View {
    BlockedProfileScheduleSelector(
      schedule: draft.schedule,
      buttonAction: { showingSchedulePicker = true },
      disabled: disabled
    )
  }
}

struct BlockedProfileScheduleSection: View {
  @ObservedObject var draft: BlockedProfileDraft
  @Binding var showingSchedulePicker: Bool
  var disabled: Bool

  var body: some View {
    Section {
      BlockedProfileScheduleFields(
        draft: draft,
        showingSchedulePicker: $showingSchedulePicker,
        disabled: disabled
      )
    } header: {
      FoqosSectionHeader("Schedule")
    }
    .foqosFormRows()
  }
}

struct BlockedProfileBreaksFields: View {
  @Environment(\.foqosPalette) private var palette

  @ObservedObject var draft: BlockedProfileDraft
  var disabled: Bool
  var showsSeparators: Bool = false

  private let minimumBreakDurationInMinutes = 5
  private let maximumBreakDurationInMinutes = 60

  @ViewBuilder
  var body: some View {
    if draft.selectedStrategyAllowsTimedBreaks {
      CustomToggle(
        title: "Allow Timed Breaks",
        description:
          "Take a break during your session. The break will automatically end after the selected duration.",
        isOn: $draft.enableBreaks,
        isDisabled: disabled
      )

      if draft.enableBreaks {
        ProfileFieldDivider(isVisible: showsSeparators)

        breakDurationPicker

        ProfileFieldDivider(isVisible: showsSeparators)

        CustomToggle(
          title: "Allow Multiple Breaks",
          description: "Take multiple breaks until your total break duration is used.",
          isOn: $draft.allowMultipleBreaks,
          isDisabled: disabled
        )
      }
    } else {
      ProfileFieldNotice(
        title: "Breaks are off for Temporary Access",
        message:
          "This strategy already gives short opens for blocked apps and categories, so timed breaks are not needed for this profile."
      )
    }
  }

  private var breakDurationPicker: some View {
    VStack(alignment: .leading, spacing: 10) {
      ProfileFormValueHeader(
        title: "Break Duration",
        value: DateFormatters.formatMinutes(draft.breakTimeInMinutes)
      )

      Slider(
        value: breakDurationBinding,
        in: Double(minimumBreakDurationInMinutes)...Double(maximumBreakDurationInMinutes),
        step: 5
      )
      .tint(palette.foreground)
      .accessibilityValue(DateFormatters.formatMinutes(draft.breakTimeInMinutes))

      ProfileFormRangeLabels(lower: "5m", upper: "1h")
    }
    .disabled(disabled)
  }

  private var breakDurationBinding: Binding<Double> {
    Binding(
      get: { Double(draft.breakTimeInMinutes) },
      set: { draft.breakTimeInMinutes = Int($0) }
    )
  }
}

struct BlockedProfileBreaksSection: View {
  @ObservedObject var draft: BlockedProfileDraft
  var disabled: Bool

  var body: some View {
    Section {
      BlockedProfileBreaksFields(draft: draft, disabled: disabled)
    } header: {
      FoqosSectionHeader("Breaks")
    }
    .foqosFormRows()
  }
}

private struct ProfileFieldNotice: View {
  @Environment(\.foqosPalette) private var palette

  let title: String
  let message: String

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text(title)
        .foqosText(.toggle)
        .foregroundStyle(palette.foreground)

      Text(message)
        .foqosText(.caption)
        .foregroundStyle(palette.mute)
        .fixedSize(horizontal: false, vertical: true)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.vertical, 4)
  }
}

struct BlockedProfileStrictSafeguardsFields: View {
  @ObservedObject var draft: BlockedProfileDraft
  var disabled: Bool
  var showsSeparators: Bool = false

  var body: some View {
    CustomToggle(
      title: "Prevent App Deletion",
      description:
        "Stop apps from being deleted during sessions, including LockedIn.",
      isOn: $draft.enableStrictMode,
      isDisabled: disabled
    )

    ProfileFieldDivider(isVisible: showsSeparators)

    CustomToggle(
      title: "Prevent New App Installs",
      description:
        "Stop new apps from being installed during sessions.",
      isOn: $draft.enableBlockAppInstallation,
      isDisabled: disabled
    )
  }
}

struct BlockedProfileSessionSafeguardsFields: View {
  @ObservedObject var draft: BlockedProfileDraft
  var disabled: Bool
  var showsSeparators: Bool = false

  @State private var showingEmergencyUnblockWarning = false

  var body: some View {
    BlockedProfileHardModeFields(draft: draft, disabled: disabled)

    ProfileFieldDivider(isVisible: showsSeparators)

    CustomToggle(
      title: "Require LockedIn to Stop",
      description:
        "Prevent this profile from being stopped by Control Center, Shortcuts, NFC links, or QR links outside the app.",
      isOn: $draft.disableBackgroundStops,
      isDisabled: disabled
    )

    ProfileFieldDivider(isVisible: showsSeparators)

    CustomToggle(
      title: "Emergency Unblock",
      description:
        "Allow limited emergency unblocks during active sessions.",
      isOn: emergencyUnblockBinding,
      isDisabled: disabled
    )
    .alert("You Could Lock Yourself Out", isPresented: $showingEmergencyUnblockWarning) {
      Button("Cancel", role: .cancel) {}
      Button("I Understand the Risks", role: .destructive) {
        draft.enableEmergencyUnblock = false
      }
    } message: {
      Text(
        "Turning off Emergency Unblock removes your backup way to end an active session. "
          + "If a required NFC tag, QR code, or barcode is lost, damaged, or unavailable, "
          + "you may be unable to stop the session and could be locked out of apps and "
          + "features on this phone."
      )
    }
  }

  private var emergencyUnblockBinding: Binding<Bool> {
    Binding(
      get: { draft.enableEmergencyUnblock },
      set: { newValue in
        guard !newValue, draft.enableEmergencyUnblock else {
          draft.enableEmergencyUnblock = newValue
          return
        }

        showingEmergencyUnblockWarning = true
      }
    )
  }
}

struct BlockedProfileStrictSafeguardsSection: View {
  @ObservedObject var draft: BlockedProfileDraft
  var disabled: Bool

  var body: some View {
    Section {
      BlockedProfileStrictSafeguardsFields(draft: draft, disabled: disabled)
    } header: {
      FoqosSectionHeader("Session Protection")
    }
    .foqosFormRows()
  }
}

struct BlockedProfileSessionSafeguardsSection: View {
  @ObservedObject var draft: BlockedProfileDraft
  var disabled: Bool

  var body: some View {
    Section {
      BlockedProfileSessionSafeguardsFields(draft: draft, disabled: disabled)
    } header: {
      FoqosSectionHeader("Stop Options")
    }
    .foqosFormRows()
  }
}

struct BlockedProfileNotificationsFields: View {
  @EnvironmentObject private var strategyManager: StrategyManager
  @Environment(\.foqosPalette) private var palette
  @FocusState private var isReminderTimeFocused: Bool

  @ObservedObject var draft: BlockedProfileDraft
  var profile: BlockedProfiles?
  var disabled: Bool
  var showsSeparators: Bool = false

  var body: some View {
    notificationFields
  }

  @ViewBuilder
  private var notificationFields: some View {
    CustomToggle(
      title: "Live Activity",
      description:
        "Show session progress on the Lock Screen.",
      isOn: $draft.enableLiveActivity,
      isDisabled: disabled
    )

    ProfileFieldDivider(isVisible: showsSeparators)

    CustomToggle(
      title: "Reminder",
      description:
        "Remind you to start this profile when it ends.",
      isOn: $draft.enableReminder,
      isDisabled: disabled
    )

    if draft.enableReminder {
      ProfileFieldDivider(isVisible: showsSeparators)

      HStack(alignment: .firstTextBaseline) {
        Text("Reminder time")
          .foqosText(.toggle)
        Spacer()
        TextField(
          "",
          value: $draft.reminderTimeInMinutes,
          format: .number
        )
        .keyboardType(.numberPad)
        .multilineTextAlignment(.center)
        .frame(width: 52)
        .padding(.bottom, 4)
        .overlay(alignment: .bottom) {
          Rectangle()
            .fill(isReminderTimeFocused ? palette.foreground : palette.line)
            .frame(height: 1)
        }
        .focused($isReminderTimeFocused)
        .disabled(disabled)
        .font(FoqosFont.ui(.body, size: 16, bold: false))
        .foregroundStyle(disabled ? palette.mute : palette.foreground)
        .accessibilityLabel("Reminder time in minutes")

        Text("minutes")
          .foqosText(.caption)
          .foregroundStyle(palette.mute)
      }
      .listRowSeparator(.visible)

      ProfileFieldDivider(isVisible: showsSeparators)

      VStack(alignment: .leading, spacing: 8) {
        Text("Reminder message")
          .foqosText(.toggle)
        TextField(
          "Reminder message",
          text: $draft.customReminderMessage,
          prompt: Text(strategyManager.defaultReminderMessage(forProfile: profile)),
          axis: .vertical
        )
        .font(FoqosFont.ui(.body, size: 16, bold: false))
        .foregroundStyle(palette.foreground)
        .lineLimit(...3)
        .onChange(of: draft.customReminderMessage) { _, newValue in
          if newValue.count > 178 {
            draft.customReminderMessage = String(newValue.prefix(178))
          }
        }
        .disabled(disabled)
      }
    }

    if !disabled {
      Button {
        if let url = URL(string: UIApplication.openSettingsURLString) {
          UIApplication.shared.open(url)
        }
      } label: {
        ProfileFormActionRow(title: "Manage notification settings", trailing: "↗")
      }
      .buttonStyle(FoqosPressStyle())
    }
  }
}

struct BlockedProfileNotificationsSection: View {
  @ObservedObject var draft: BlockedProfileDraft
  var profile: BlockedProfiles?
  var disabled: Bool

  var body: some View {
    Section {
      BlockedProfileNotificationsFields(
        draft: draft,
        profile: profile,
        disabled: disabled
      )
    } header: {
      FoqosSectionHeader("Notifications")
    }
    .foqosFormRows()
  }
}
