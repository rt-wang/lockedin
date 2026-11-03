import Combine
import FamilyControls
import SwiftUI
import UIKit

struct ActiveProfileSessionView: View {
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject private var strategyManager: StrategyManager

  let profile: BlockedProfiles
  let elapsedTime: TimeInterval
  let displayTime: TimeInterval
  let isBreakAvailable: Bool
  let isBreakActive: Bool
  let isPauseActive: Bool
  let isCountdownExpired: Bool
  let onBreakTapped: () -> Void
  let onStopTapped: () -> Void
  let onExpiredCountdownReset: () -> Void

  @State private var showEmergencyView = false
  @State private var showingAlert = false
  @State private var alertMessage = ""
  @State private var focusMessageIndex = Self.initialFocusMessageIndex()

  private let focusMessageTimer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()

  private var showStopButton: Bool {
    profile.showStopButton(elapsedTime: elapsedTime) && !isHardModeActionLocked
  }

  private var stopButtonAction: BlockingStrategySessionAction {
    blockingStrategy?.activeSessionAction(isPauseActive: isPauseActive) ?? .stop()
  }

  private var activeSession: BlockedProfileSession? {
    guard let session = strategyManager.activeSession,
      session.blockedProfile.id == profile.id
    else { return nil }
    return session
  }

  private var isHardModeActionLocked: Bool {
    activeSession?.isSessionActionLockedByHardMode() ?? false
  }

  private var breakButtonTitle: String {
    "Hold to " + (isBreakActive ? "Stop Break" : "Start Break")
  }

  private var focusMessage: String {
    guard FocusMessages.messages.indices.contains(focusMessageIndex) else {
      return FocusMessages.getRandomMessage()
    }
    return FocusMessages.messages[focusMessageIndex]
  }

  private var strategyName: String {
    guard let strategyId = profile.blockingStrategyId else {
      return "No Strategy"
    }
    return StrategyManager.getStrategyFromId(id: strategyId).name
  }

  private var blockingStrategy: BlockingStrategy? {
    guard let strategyId = profile.blockingStrategyId else {
      return nil
    }
    return StrategyManager.getStrategyFromId(id: strategyId)
  }

  private var isSoftUnblockStrategy: Bool {
    guard let strategyId = profile.blockingStrategyId else { return false }
    return [
      NFCSoftUnblockBlockingStrategy.id,
      QRSoftUnblockBlockingStrategy.id,
    ].contains(strategyId)
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      topControls

      GeometryReader { geometry in
        ScrollView(showsIndicators: false) {
          VStack(alignment: .leading, spacing: 0) {
            sessionCopy
              .padding(.top, 48)
            Spacer(minLength: 40)
            actionSection
          }
          .frame(minHeight: max(0, geometry.size.height - 16), alignment: .top)
          .padding(.bottom, 16)
        }
      }
    }
    .padding(.horizontal, 24)
    .padding(.top, 8)
    .foqosTheme(.forest)
    .sheet(isPresented: $showEmergencyView) {
      EmergencyView()
        .presentationDetents([.height(350), .large])
    }
    .sheet(isPresented: $strategyManager.showCustomStrategyView) {
      BlockingStrategyActionView(
        customView: strategyManager.customStrategyView,
        presentationDetents: strategyManager.customStrategyViewPresentationDetents
      )
    }
    .onReceive(focusMessageTimer) { _ in
      rotateFocusMessage()
    }
    .onReceive(strategyManager.$errorMessage) { errorMessage in
      guard let message = errorMessage else { return }
      alertMessage = message
      showingAlert = true
    }
    .alert("Whoops", isPresented: $showingAlert) {
      Button("OK", role: .cancel) {
        dismissAlert()
      }
    } message: {
      Text(alertMessage)
    }
  }

  private var topControls: some View {
    HStack(alignment: .top) {
      VStack(alignment: .leading, spacing: 8) {
        Text("Session active")
          .foqosText(.cta)

        Text(statusMessage ?? "Apps blocked")
          .foqosText(.tab)
          .foregroundStyle(FoqosPalette.forest.mute)
      }
      .accessibilityElement(children: .combine)
      .padding(.top, 10)

      Spacer()

      Button(action: { dismiss() }) {
        Image(systemName: "xmark")
          .font(.system(size: 17, weight: .regular))
          .frame(width: 44, height: 44)
          .contentShape(Rectangle())
      }
      .buttonStyle(FoqosPressStyle())
      .accessibilityLabel("Close")
    }
  }

  private var statusMessage: String? {
    if isPauseActive {
      return "Paused"
    }
    if isBreakActive {
      return "On a break"
    }
    return nil
  }

  private var scheduledEndTime: Date? {
    guard let session = strategyManager.activeSession,
      session.blockedProfile.id == profile.id
    else { return nil }

    return SessionTimeCalculator.scheduledEndTime(for: session)
  }

  private var sessionCopy: some View {
    VStack(alignment: .leading, spacing: 0) {
      Text(profile.name)
        .foqosDisplay(size: 64)
        .lineLimit(3)
        .minimumScaleFactor(0.6)
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityAddTraits(.isHeader)
        .padding(.bottom, 18)

      Text(focusMessage)
        .font(FoqosFont.ui(.callout, size: 16, bold: false))
        .foregroundStyle(FoqosPalette.forest.mute)
        .frame(maxWidth: 300, alignment: .leading)
        .multilineTextAlignment(.leading)
        .lineLimit(3)
        .fixedSize(horizontal: false, vertical: true)
        .contentTransition(.opacity)
        .animation(.easeInOut(duration: 0.35), value: focusMessage)

      VStack(alignment: .leading, spacing: 10) {
        FoqosHairline()
          .frame(maxWidth: 180)

        timer

        Text(sessionDetailText)
          .foqosText(.mark)
          .foregroundStyle(FoqosPalette.forest.mute)
      }
      .padding(.top, 32)

      if isSoftUnblockStrategy {
        SoftUnblockActiveGrantsCard(profileId: profile.id)
          .padding(.top, 28)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private var sessionDetailText: String {
    var parts = [strategyName]
    if let scheduledEndTime {
      parts.append("Ends \(scheduledEndTime.formatted(date: .omitted, time: .shortened))")
    }
    return parts.joined(separator: " · ")
  }

  private var timer: some View {
    Text(DateFormatters.formatDurationClock(displayTime))
      .font(FoqosFont.ui(.title2, size: 24, bold: true))
      .tracking(24 * 0.08)
      .monospacedDigit()
      .lineLimit(1)
      .minimumScaleFactor(0.5)
      .contentTransition(.numericText())
      .animation(.default, value: displayTime)
      .accessibilityLabel("Session time")
      .accessibilityValue(DateFormatters.formatDurationClock(displayTime))
  }

  private var actionSection: some View {
    VStack(alignment: .leading, spacing: 14) {
      if isCountdownExpired && (activeSession?.canResetExpiredCountdown() ?? true) {
        Text("This timer finished, but the session is still active.")
          .foqosText(.caption)
          .foregroundStyle(FoqosPalette.forest.mute)
          .frame(maxWidth: .infinity, alignment: .leading)

        ActiveSessionActionButton(
          title: "Reset session",
          role: .standard,
          action: onExpiredCountdownReset
        )
      } else {
        if !isPauseActive && isBreakAvailable {
          ActiveSessionActionButton(
            title: breakButtonTitle,
            role: .standard,
            requiresLongPress: true,
            action: onBreakTapped
          )
        }

        if showStopButton {
          ActiveSessionActionButton(
            title: stopButtonAction.title,
            role: .standard,
            action: onStopTapped
          )
        }

        if let session = activeSession, session.isStopLockedByHardMode(),
          let unlockTime = session.hardModeUnlockTime
        {
          Text(
            "Stop available at \(unlockTime.formatted(date: .omitted, time: .shortened))"
          )
          .foqosText(.caption)
          .foregroundStyle(FoqosPalette.forest.mute)
          .fixedSize(horizontal: false, vertical: true)
        }

        if profile.enableEmergencyUnblock {
          ActiveSessionActionButton(
            title: "Emergency unblock",
            role: .secondary,
            action: {
              showEmergencyView = true
            }
          )
        }
      }
    }
  }

  private func rotateFocusMessage() {
    guard !FocusMessages.messages.isEmpty else { return }
    withAnimation(.easeInOut(duration: 0.35)) {
      focusMessageIndex = (focusMessageIndex + 1) % FocusMessages.messages.count
    }
  }

  private func dismissAlert() {
    showingAlert = false
    strategyManager.errorMessage = nil
  }

  private static func initialFocusMessageIndex() -> Int {
    guard !FocusMessages.messages.isEmpty else { return 0 }
    return Int.random(in: 0..<FocusMessages.messages.count)
  }
}

private enum SoftUnblockActiveGrantResource {
  case stored(SoftUnblockResource)
  case preview(title: String, systemImageName: String)
}

private struct SoftUnblockActiveGrantDisplay: Identifiable {
  let id: UUID
  let resource: SoftUnblockActiveGrantResource
  let createdAt: Date
  let expiresAt: Date

  init(grant: SoftUnblockGrant) {
    id = grant.id
    resource = .stored(grant.resource)
    createdAt = grant.createdAt
    expiresAt = grant.expiresAt
  }

  init(
    id: UUID,
    title: String,
    systemImageName: String,
    createdAt: Date,
    expiresAt: Date
  ) {
    self.id = id
    resource = .preview(title: title, systemImageName: systemImageName)
    self.createdAt = createdAt
    self.expiresAt = expiresAt
  }
}

private enum SoftUnblockActiveGrantsSource {
  case live
  case preview([SoftUnblockActiveGrantDisplay])

  func activeGrants(for profileId: UUID, at date: Date) -> [SoftUnblockActiveGrantDisplay] {
    switch self {
    case .live:
      return SoftUnblockGrantStore.activeGrants(for: profileId, at: date).map {
        SoftUnblockActiveGrantDisplay(grant: $0)
      }
    case .preview(let grants):
      return grants.filter { $0.expiresAt > date }
    }
  }
}

private struct SoftUnblockActiveGrantsSourceKey: EnvironmentKey {
  static let defaultValue = SoftUnblockActiveGrantsSource.live
}

extension EnvironmentValues {
  fileprivate var softUnblockActiveGrantsSource: SoftUnblockActiveGrantsSource {
    get { self[SoftUnblockActiveGrantsSourceKey.self] }
    set { self[SoftUnblockActiveGrantsSourceKey.self] = newValue }
  }
}

private struct SoftUnblockActiveGrantsCard: View {
  private static let visibleGrantLimit = 3

  @Environment(\.softUnblockActiveGrantsSource) private var activeGrantsSource

  let profileId: UUID

  var body: some View {
    TimelineView(.periodic(from: .now, by: 1)) { timeline in
      let activeGrants = activeGrantsSource.activeGrants(for: profileId, at: timeline.date)
        .sorted { lhs, rhs in
          if lhs.expiresAt == rhs.expiresAt {
            return lhs.createdAt < rhs.createdAt
          }
          return lhs.expiresAt < rhs.expiresAt
        }
      let visibleGrants = Array(activeGrants.prefix(Self.visibleGrantLimit))
      let overflowCount = activeGrants.count - visibleGrants.count

      if !activeGrants.isEmpty {
        VStack(alignment: .leading, spacing: 0) {
          Text("Temporary access")
            .foqosText(.eyebrow)
            .foregroundStyle(FoqosPalette.forest.mute)
            .padding(.bottom, 10)

          FoqosHairline()

          ForEach(visibleGrants) { grant in
            SoftUnblockActiveGrantRow(
              grant: grant,
              date: timeline.date
            )

            FoqosHairline()
          }

          if overflowCount > 0 {
            Text("+\(overflowCount) more active")
              .font(.caption)
              .fontWeight(.medium)
              .foregroundStyle(.secondary)
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(.top, 4)
          }
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.easeInOut(duration: 0.25), value: activeGrants.map(\.id))
      }
    }
  }
}

private struct SoftUnblockActiveGrantRow: View {
  let grant: SoftUnblockActiveGrantDisplay
  let date: Date

  private var remainingSeconds: Int {
    max(Int(ceil(grant.expiresAt.timeIntervalSince(date))), 0)
  }

  private var countdownText: String {
    String(
      format: "%02d:%02d",
      remainingSeconds / 60,
      remainingSeconds % 60
    )
  }

  private var accessibilityCountdownText: String {
    let minutes = remainingSeconds / 60
    let seconds = remainingSeconds % 60
    let minuteLabel = minutes == 1 ? "minute" : "minutes"
    let secondLabel = seconds == 1 ? "second" : "seconds"
    return "\(minutes) \(minuteLabel), \(seconds) \(secondLabel) remaining"
  }

  var body: some View {
    HStack(spacing: 10) {
      resourceLabel
        .font(.subheadline)
        .fontWeight(.medium)
        .lineLimit(1)
        .minimumScaleFactor(0.8)

      Spacer(minLength: 8)

      Text(countdownText)
        .font(.system(.footnote, design: .monospaced, weight: .semibold))
        .foregroundStyle(.secondary)
        .contentTransition(.numericText(countsDown: true))
        .accessibilityLabel(accessibilityCountdownText)
    }
    .padding(.vertical, 12)
  }

  @ViewBuilder
  private var resourceLabel: some View {
    switch grant.resource {
    case .stored(.application(let token)):
      Label(token)
    case .stored(.category(let token)):
      Label(token)
    case .preview(let title, let systemImageName):
      Label(title, systemImage: systemImageName)
    }
  }
}

private enum ActiveSessionActionRole {
  case standard
  case secondary
}

private struct ActiveSessionActionButton: View {
  @Environment(\.foqosPalette) private var palette

  let title: String
  let role: ActiveSessionActionRole
  var requiresLongPress = false
  let action: () -> Void

  @State private var isPressed = false

  private let longPressDuration = 0.8

  var body: some View {
    if requiresLongPress {
      label
        .overlay(alignment: .topLeading) {
          // Fills the rule while holding so the long-press has visible progress.
          Rectangle()
            .fill(palette.foreground)
            .frame(height: 3)
            .scaleEffect(x: isPressed ? 1 : 0, anchor: .leading)
            .animation(
              isPressed ? .linear(duration: longPressDuration) : .easeOut(duration: 0.2),
              value: isPressed
            )
            .accessibilityHidden(true)
        }
        .onLongPressGesture(
          minimumDuration: longPressDuration,
          pressing: { pressing in
            isPressed = pressing
          },
          perform: triggerAction
        )
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityAction(.default, triggerAction)
    } else {
      Button(action: triggerAction) {
        label
      }
      .buttonStyle(FoqosPressStyle())
    }
  }

  private var label: some View {
    VStack(spacing: 0) {
      FoqosHairline(isStrong: role == .standard)

      HStack(alignment: .firstTextBaseline) {
        Text(title)
          .foqosText(.cta)
          .lineLimit(1)
          .minimumScaleFactor(0.76)

        Spacer(minLength: 12)

        Text("→")
          .foqosText(.cta)
          .accessibilityHidden(true)
      }
      .padding(.top, 18)
      .padding(.bottom, 4)
      .frame(minHeight: 44)
    }
    .foregroundStyle(role == .standard ? palette.foreground : palette.mute)
    .contentShape(Rectangle())
  }

  private func triggerAction() {
    UIImpactFeedbackGenerator(style: .light).impactOccurred()
    action()
  }
}

#Preview("Standard Session") {
  ActiveProfileSessionView(
    profile: BlockedProfiles(name: "Work Focus"),
    elapsedTime: 3665,
    displayTime: 3665,
    isBreakAvailable: true,
    isBreakActive: false,
    isPauseActive: false,
    isCountdownExpired: false,
    onBreakTapped: {},
    onStopTapped: {},
    onExpiredCountdownReset: {}
  )
  .environmentObject(StrategyManager())
  .environmentObject(ThemeManager())
}

#Preview("Temporary Access · One App") {
  let previewDate = Date()
  let profile = BlockedProfiles(
    id: UUID(uuidString: "8C58F66A-1F6E-45D7-97CC-95756AB663C2")!,
    name: "Deep Work",
    blockingStrategyId: NFCSoftUnblockBlockingStrategy.id,
    enableBreaks: false
  )

  ActiveProfileSessionView(
    profile: profile,
    elapsedTime: 733,
    displayTime: 733,
    isBreakAvailable: false,
    isBreakActive: false,
    isPauseActive: false,
    isCountdownExpired: false,
    onBreakTapped: {},
    onStopTapped: {},
    onExpiredCountdownReset: {}
  )
  .environment(
    \.softUnblockActiveGrantsSource,
    .preview([
      SoftUnblockActiveGrantDisplay(
        id: UUID(uuidString: "B0C1B326-E87C-4692-BE1E-04AEEDC04880")!,
        title: "Instagram",
        systemImageName: "camera.fill",
        createdAt: previewDate.addingTimeInterval(-38),
        expiresAt: previewDate.addingTimeInterval(262)
      )
    ])
  )
  .environmentObject(StrategyManager())
  .environmentObject(ThemeManager())
}

#Preview("Temporary Access · Multiple") {
  let previewDate = Date()
  let profile = BlockedProfiles(
    id: UUID(uuidString: "31C8D175-A37C-4C82-919E-6BB06E9C9B6B")!,
    name: "Study Session",
    blockingStrategyId: QRSoftUnblockBlockingStrategy.id,
    enableBreaks: false
  )

  ActiveProfileSessionView(
    profile: profile,
    elapsedTime: 1_254,
    displayTime: 1_254,
    isBreakAvailable: false,
    isBreakActive: false,
    isPauseActive: false,
    isCountdownExpired: false,
    onBreakTapped: {},
    onStopTapped: {},
    onExpiredCountdownReset: {}
  )
  .environment(
    \.softUnblockActiveGrantsSource,
    .preview([
      SoftUnblockActiveGrantDisplay(
        id: UUID(uuidString: "B00A56CF-F936-4B5C-875C-77943D503961")!,
        title: "Instagram",
        systemImageName: "camera.fill",
        createdAt: previewDate.addingTimeInterval(-61),
        expiresAt: previewDate.addingTimeInterval(119)
      ),
      SoftUnblockActiveGrantDisplay(
        id: UUID(uuidString: "7921AAAF-DCC0-41CC-82BC-8E5291C53B65")!,
        title: "Social",
        systemImageName: "person.2.fill",
        createdAt: previewDate.addingTimeInterval(-28),
        expiresAt: previewDate.addingTimeInterval(212)
      ),
      SoftUnblockActiveGrantDisplay(
        id: UUID(uuidString: "A792D79C-E42C-498F-9DEE-CA417F13D398")!,
        title: "YouTube",
        systemImageName: "play.rectangle.fill",
        createdAt: previewDate.addingTimeInterval(-23),
        expiresAt: previewDate.addingTimeInterval(397)
      ),
      SoftUnblockActiveGrantDisplay(
        id: UUID(uuidString: "41764C6B-1592-4A15-BB7E-8F5CB827B4BC")!,
        title: "Entertainment",
        systemImageName: "film.fill",
        createdAt: previewDate.addingTimeInterval(-10),
        expiresAt: previewDate.addingTimeInterval(530)
      ),
    ])
  )
  .environmentObject(StrategyManager())
  .environmentObject(ThemeManager())
}
