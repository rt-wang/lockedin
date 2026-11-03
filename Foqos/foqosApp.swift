//
//  foqosApp.swift
//  foqos
//
//  Created by Ali Waseem on 2024-10-06.
//

import AppIntents
import BackgroundTasks
import SwiftData
import SwiftUI

@MainActor private let container: ModelContainer = {
  do {
    let container = try FoqosModelContainer.make()
    // Temporary backfill for users upgrading from the legacy NFC/QR fields.
    // Remove this in the next app version once the installed base has migrated.
    try PhysicalUnblockMigrationHelper.migrateOldPhysicalUnblockFields(
      in: container.mainContext
    )
    return container
  } catch {
    fatalError("Couldn't create ModelContainer: \(error)")
  }
}()

@main
struct foqosApp: App {
  @UIApplicationDelegateAdaptor(FoqosAppDelegate.self) private var appDelegate

  @StateObject private var requestAuthorizer = RequestAuthorizer()
  @StateObject private var navigationManager = NavigationManager()
  @StateObject private var nfcWriter = NFCWriter()
  @StateObject private var ratingManager = RatingManager()

  // Singletons for shared functionality
  @StateObject private var startegyManager = StrategyManager.shared
  @StateObject private var liveActivityManager = LiveActivityManager.shared
  @StateObject private var alertsManager = AlertsManager.shared

  @Environment(\.scenePhase) private var scenePhase

  init() {
    TimersUtil.registerBackgroundTasks()
    // The user-selectable theme color was removed; drop the stale preference from older installs.
    UserDefaults(suiteName: "group.sh.shen.lockedin")?
      .removeObject(forKey: "foqosThemeColorName")

    let asyncDependency: @Sendable () async -> (ModelContainer) = {
      @MainActor in
      return container
    }
    AppDependencyManager.shared.add(
      key: "ModelContainer",
      dependency: asyncDependency
    )
    FoqosShortcutsProvider.updateAppShortcutParameters()
  }

  var body: some Scene {
    WindowGroup {
      HomeView()
        .onReceive(NotificationCenter.default.publisher(for: ModelContext.didSave)) {
          notification in
          guard let context = notification.object as? ModelContext,
            context === container.mainContext
          else { return }
          FoqosShortcutsProvider.updateAppShortcutParameters()
        }
        .onOpenURL { url in
          handleUniversalLink(url)
        }
        .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) {
          userActivity in
          guard let url = userActivity.webpageURL else {
            return
          }
          handleUniversalLink(url)

        }
        .environmentObject(requestAuthorizer)
        .environmentObject(alertsManager)
        .environmentObject(startegyManager)
        .environmentObject(navigationManager)
        .environmentObject(nfcWriter)
        .environmentObject(ratingManager)
        .environmentObject(liveActivityManager)
    }
    .modelContainer(container)
    .onChange(of: scenePhase) { _, phase in
      if phase == .active {
        resetRemovedAlternateIcon()
      }
    }
  }

  // Upstream Foqos shipped alternate icons (Blue, Cat, Pop, Original) that LockedIn removed.
  // Anyone who had one selected is moved back to the default icon. This only works while the
  // app is active, so it runs on scene activation rather than at launch.
  private func resetRemovedAlternateIcon() {
    let application = UIApplication.shared
    guard application.supportsAlternateIcons,
      AppIconOption.isRemovedAlternate(application.alternateIconName)
    else { return }
    application.setAlternateIconName(nil) { error in
      if let error {
        print("Failed to reset removed alternate icon: \(error.localizedDescription)")
      }
    }
  }

  private func handleUniversalLink(_ url: URL) {
    navigationManager.handleLink(url)
  }
}
