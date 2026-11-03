import SwiftUI

struct BlockedProfileDomainSelector: View {
  var domains: [String]
  var buttonAction: () -> Void
  var allowMode: Bool = false
  var disabled: Bool = false
  var disabledText: String?

  private var title: String {
    return allowMode ? "Allowed" : "Blocked"
  }

  private var domainCount: Int {
    return domains.count
  }

  private var buttonText: String {
    return allowMode
      ? "Select Domains to Allow"
      : "Select Domains to Restrict"
  }

  var body: some View {
    Button(action: buttonAction) {
      ProfileFormActionRow(title: buttonText)
    }
    .buttonStyle(FoqosPressStyle())
    .disabled(disabled)

    if let disabledText = disabledText, disabled {
      ProfileFormCaption(disabledText, isWarning: true)
    } else if domainCount == 0 {
      ProfileFormCaption("No domains selected")
    } else {
      ProfileFormCaption("\(domainCount) \(domainCount == 1 ? "domain" : "domains") selected")
    }
  }
}

#Preview {
  VStack(spacing: 20) {
    BlockedProfileDomainSelector(
      domains: ["example.com", "test.org"],
      buttonAction: {}
    )

    BlockedProfileDomainSelector(
      domains: [],
      buttonAction: {},
      allowMode: true
    )

    BlockedProfileDomainSelector(
      domains: ["example.com"],
      buttonAction: {},
      disabled: true,
      disabledText: "Disable the current session to edit domains"
    )
  }
  .padding()
  .foqosTheme(.cream)
}
