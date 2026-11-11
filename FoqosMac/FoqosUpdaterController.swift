import Foundation

#if canImport(Sparkle)
  import Sparkle
#endif

// TODO(LockedIn): Sparkle is not linked to the Mac target and there is no LockedIn appcast yet.
// Once both exist (re-add the Sparkle package product and set SUFeedURL / SUPublicEDKey in
// FoqosMac/Info.plist), this controller starts checking for updates automatically.
@MainActor
final class FoqosUpdaterController: ObservableObject {
  let isConfigured: Bool

  #if canImport(Sparkle)
    private let updaterController: SPUStandardUpdaterController
  #endif

  init(bundle: Bundle = .main) {
    #if canImport(Sparkle)
      isConfigured = Self.hasUpdateConfiguration(in: bundle)
      updaterController = SPUStandardUpdaterController(
        startingUpdater: isConfigured,
        updaterDelegate: nil,
        userDriverDelegate: nil
      )
    #else
      isConfigured = false
    #endif
  }

  func checkForUpdates() {
    guard isConfigured else {
      return
    }

    #if canImport(Sparkle)
      updaterController.checkForUpdates(nil)
    #endif
  }

  private static func hasUpdateConfiguration(in bundle: Bundle) -> Bool {
    guard
      let feedURL = bundle.object(forInfoDictionaryKey: "SUFeedURL") as? String,
      !feedURL.isEmpty,
      let publicKey = bundle.object(forInfoDictionaryKey: "SUPublicEDKey") as? String,
      !publicKey.isEmpty
    else {
      return false
    }

    return true
  }
}
