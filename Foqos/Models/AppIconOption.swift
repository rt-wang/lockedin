enum AppIconOption: String, CaseIterable, Identifiable {
  case defaultIcon
  case cream
  case sage

  var id: String { rawValue }

  var displayName: String {
    switch self {
    case .defaultIcon: "Default"
    case .cream: "Cream"
    case .sage: "Sage"
    }
  }

  // Must match ASSETCATALOG_COMPILER_ALTERNATE_APPICON_NAMES.
  var alternateIconName: String? {
    switch self {
    case .defaultIcon: nil
    case .cream: "AppIcon-Cream"
    case .sage: "AppIcon-Sage"
    }
  }

  var previewAssetName: String {
    switch self {
    case .defaultIcon: "AppIconDefaultPreview"
    case .cream: "AppIconCreamPreview"
    case .sage: "AppIconSagePreview"
    }
  }

  var liveActivityAssetName: String {
    switch self {
    case .defaultIcon: "LiveActivityAppIconDefault"
    case .cream: "LiveActivityAppIconCream"
    case .sage: "LiveActivityAppIconSage"
    }
  }

  /// True when `name` is an alternate icon this build no longer ships (e.g. the old Foqos
  /// "foqos-icon-blue"), so the user should be moved back to the default icon.
  static func isRemovedAlternate(_ name: String?) -> Bool {
    guard let name else { return false }
    return !allCases.contains { $0.alternateIconName == name }
  }
}
