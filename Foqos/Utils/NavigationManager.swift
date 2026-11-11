import SwiftUI

class NavigationManager: ObservableObject {
  @Published var profileId: String? = nil
  @Published var link: URL? = nil

  @Published var navigateToProfileId: String? = nil

  func handleLink(_ url: URL) {
    let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
    guard let components else { return }

    // Universal links (https://shen.sh/profile/<id>, legacy foqos.app) carry the route in the
    // path; custom-scheme links (lockedin://profile/<id>, legacy foqos://) carry it in the host.
    var parts = components.path.split(separator: "/")
    let isWebLink = components.scheme == "https" || components.scheme == "http"
    if !isWebLink, let host = components.host, !host.isEmpty {
      parts.insert(Substring(host), at: 0)
    }
    if let basePath = parts[safe: 0], let profileId = parts[safe: 1] {
      switch String(basePath) {
      case "profile":
        self.profileId = String(profileId)
        self.link = url
      case "navigate":
        self.navigateToProfileId = String(profileId)
        self.link = url
      default:
        break
      }
    }
  }

  func clearNavigation() {
    profileId = nil
    link = nil
    navigateToProfileId = nil
  }
}
