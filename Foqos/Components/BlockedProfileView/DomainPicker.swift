import SwiftUI

struct DomainPicker: View {
  @Environment(\.foqosPalette) private var palette

  @Binding var domains: [String]
  @Binding var isPresented: Bool

  var allowMode: Bool = false

  @State private var newDomain: String = ""
  @State private var showingError: Bool = false
  @State private var errorMessage: String = ""

  private let maxDomains = 50

  private var message: String {
    return allowMode
      ? "Apple limits this to 50 domains. Add domains that you want to remain accessible during sessions."
      : "Apple limits this to 50 domains. Add domains that you want to restrict during sessions."
  }

  var body: some View {
    NavigationStack {
      Form {
        Section {
          ProfileSheetHeader(
            eyebrow: allowMode ? "Allowed domains" : "Blocked domains",
            title: allowMode ? "Keep these open" : "Websites to block",
            message:
              "Enter a domain like reddit.com. Every page under it is \(allowMode ? "allowed" : "blocked") too."
          )
        }
        .profileSheetHeaderRow()

        Section {
          HStack(alignment: .firstTextBaseline, spacing: 12) {
            TextField("example.com", text: $newDomain)
              .font(FoqosFont.ui(.body, size: 17, bold: false))
              .autocapitalization(.none)
              .keyboardType(.URL)
              .textContentType(.URL)
              .onSubmit {
                addDomain()
              }

            Button(action: addDomain) {
              Text("Add")
                .foqosText(.cta)
                .foregroundStyle(palette.foreground)
                .frame(minHeight: 44)
                .contentShape(Rectangle())
            }
            .buttonStyle(FoqosPressStyle())
            .disabled(newDomain.isEmpty || domains.count >= maxDomains)
          }
        } header: {
          FoqosSectionHeader("Add domain")
        }
        .foqosFormRows()

        Section {
          ForEach(domains, id: \.self) { domain in
            Text(domain)
              .foqosText(.body)
          }
          .onDelete(perform: deleteDomains)

          if domains.isEmpty {
            Text("No domains added")
              .foqosText(.caption)
              .foregroundStyle(palette.mute)
          }
        } header: {
          HStack(alignment: .firstTextBaseline) {
            FoqosSectionHeader(allowMode ? "Allowed domains" : "Blocked domains")
            Spacer()
            Text("\(domains.count)/\(maxDomains)")
              .foqosText(.mark)
              .foregroundStyle(palette.mute)
              .monospacedDigit()
          }
        } footer: {
          VStack(alignment: .leading, spacing: 6) {
            Text(message)
              .foqosText(.caption)
              .foregroundStyle(palette.mute)

            if domains.count >= maxDomains {
              Text("Maximum of 50 domains reached (Apple's limit).")
                .foqosText(.caption)
                .foregroundStyle(palette.foreground)
            }
          }
        }
        .foqosFormRows()
      }
      .foqosForm(.cream)
      .navigationTitle(allowMode ? "Allow Domains" : "Block Domains")
      .navigationBarTitleDisplayMode(.inline)
      .profileSheetChrome()
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button(action: { isPresented = false }) {
            Image(systemName: "checkmark")
          }
          .accessibilityLabel("Done")
        }
      }
      .alert("Error", isPresented: $showingError) {
        Button("OK") {}
      } message: {
        Text(errorMessage)
      }
    }
  }

  private func addDomain() {
    let trimmedDomain = newDomain.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

    guard !trimmedDomain.isEmpty else {
      showError("Please enter a domain")
      return
    }

    guard domains.count < maxDomains else {
      showError("Maximum number of domains (\(maxDomains)) reached")
      return
    }

    guard !domains.contains(trimmedDomain) else {
      showError("Domain already exists")
      return
    }

    guard isValidDomain(trimmedDomain) else {
      showError(
        "Enter a valid domain without https:// or www. (e.g., google.com, reddit.com, facebook.com)"
      )
      return
    }

    domains.append(trimmedDomain)
    newDomain = ""
  }

  private func deleteDomains(at offsets: IndexSet) {
    domains.remove(atOffsets: offsets)
  }

  private func showError(_ message: String) {
    errorMessage = message
    showingError = true
  }

  private func isValidDomain(_ domain: String) -> Bool {
    // Basic domain validation
    let domainRegex =
      #"^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"#
    let predicate = NSPredicate(format: "SELF MATCHES %@", domainRegex)

    // Additional checks
    guard domain.count <= 253 else { return false }  // Max domain length
    guard !domain.hasPrefix(".") && !domain.hasSuffix(".") else { return false }
    guard !domain.contains("..") else { return false }  // No consecutive dots
    guard domain.contains(".") else { return false }  // Must have at least one dot

    return predicate.evaluate(with: domain)
  }
}

#Preview {
  @Previewable @State var domains: [String] = ["example.com", "test.org"]

  VStack(spacing: 20) {
    DomainPicker(
      domains: $domains,
      isPresented: .constant(true)
    )

    DomainPicker(
      domains: $domains,
      isPresented: .constant(true),
      allowMode: true
    )
  }
}
