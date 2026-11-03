import SwiftData
import SwiftUI

enum ProfilePasswordMode: String, Identifiable {
  case setup
  case unlock
  case change

  var id: String { rawValue }

  var title: String {
    switch self {
    case .setup: return "Protect Your Profile"
    case .unlock: return "A Little Help from a Friend"
    case .change: return "Choose a New Password"
    }
  }

  var buttonTitle: String {
    switch self {
    case .setup: return "Protect Profile"
    case .unlock: return "Unlock Profile"
    case .change: return "Update Password"
    }
  }
}

struct ProfilePasswordView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext
  @Environment(\.scenePhase) private var scenePhase
  @Environment(\.foqosPalette) private var palette
  @EnvironmentObject private var strategyManager: StrategyManager

  let profile: BlockedProfiles
  let mode: ProfilePasswordMode
  var authorization: ProfileEditAuthorization? = nil
  var onUnlock: (ProfileEditAuthorization) -> Void = { _ in }

  @State private var password = ""
  @State private var confirmation = ""
  @State private var errorMessage: String?
  @State private var operation: Task<Void, Never>?
  @FocusState private var focusedField: Field?

  private enum Field {
    case password
    case confirmation
  }

  private var isUnlocking: Bool { mode == .unlock }
  private var isWorking: Bool { operation != nil }
  private var isBlocking: Bool { strategyManager.activeSession?.isActive == true }
  private var canSubmit: Bool {
    ProfileLockUtil.isValidPassword(password)
      && (isUnlocking || password == confirmation)
      && !isBlocking
  }

  var body: some View {
    NavigationStack {
      Form {
        Section {
          ProfileSheetHeader(
            eyebrow: isUnlocking ? "Locked profile" : "Profile password",
            title: mode.title,
            message: description
          )
        }
        .profileSheetHeaderRow()

        passwordFields

        if let errorMessage {
          Section {
            Text(errorMessage)
              .foqosText(.caption)
              .foregroundStyle(.red)
              .accessibilityIdentifier("profilePasswordError")
          }
          .foqosFormRows()
        }

        Section {
          ActionButton(
            title: mode.buttonTitle,
            isLoading: isWorking,
            isDisabled: !canSubmit,
            action: submit
          )
          .accessibilityIdentifier("profilePasswordSubmit")
          .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
          .listRowBackground(Color.clear)
          .listRowSeparator(.hidden)
        } footer: {
          Text(protectionNote)
            .foqosText(.caption)
            .foregroundStyle(palette.mute)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.top, 8)
        }
      }
      .foqosForm(.cream)
      .scrollDismissesKeyboard(.interactively)
      .navigationTitle(isUnlocking ? "Unlock Profile" : "Profile Password")
      .navigationBarTitleDisplayMode(.inline)
      .profileSheetChrome()
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button(action: { dismiss() }) {
            Image(systemName: "xmark")
          }
          .accessibilityLabel("Cancel")
        }

      }
      .onChange(of: password) { _, _ in errorMessage = nil }
      .onChange(of: confirmation) { _, _ in errorMessage = nil }
      .onChange(of: scenePhase) { _, phase in
        if phase == .background {
          cancelOperation()
          dismiss()
        }
      }
      .onChange(of: isBlocking) { _, blocking in
        if blocking {
          cancelOperation()
          dismiss()
        }
      }
      .onDisappear { cancelOperation() }
    }
  }

  private var description: String {
    if isUnlocking {
      return "Enter the password for \(profile.name) to make changes. Your trusted person can help."
    }
    return
      "Let someone you trust choose a password for \(profile.name). You’ll need it to edit, duplicate, or delete this profile."
  }

  private var protectionNote: String {
    isUnlocking
      ? "Your profile locks again when you close the editor or leave the app."
      : "There’s no password recovery. Make sure someone you trust keeps it safe."
  }

  private var passwordFields: some View {
    Group {
      Section {
        SecureField("Password", text: $password)
          .textContentType(.none)
          .textInputAutocapitalization(.never)
          .autocorrectionDisabled()
          .focused($focusedField, equals: .password)
          .submitLabel(isUnlocking ? .go : .next)
          .onSubmit {
            if isUnlocking { submit() } else { focusedField = .confirmation }
          }
          .accessibilityIdentifier("profilePassword")
      } header: {
        FoqosSectionHeader(isUnlocking ? "Password" : "Choose a password")
      } footer: {
        Text("\(password.count)/\(ProfileLockUtil.maximumPasswordLength) characters")
          .foqosText(.mark)
          .foregroundStyle(
            password.count > ProfileLockUtil.maximumPasswordLength ? Color.red : palette.mute)
      }
      .foqosFormRows()

      if !isUnlocking {
        Section {
          SecureField("Enter it again", text: $confirmation)
            .textContentType(.none)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .focused($focusedField, equals: .confirmation)
            .submitLabel(.go)
            .onSubmit { submit() }
            .accessibilityIdentifier("profilePasswordConfirmation")
        } header: {
          FoqosSectionHeader("Confirm password")
        } footer: {
          if !confirmation.isEmpty && password != confirmation {
            Text("Passwords don’t match yet.")
              .foqosText(.caption)
              .foregroundStyle(palette.mute)
          }
        }
        .foqosFormRows()
      }
    }
    .disabled(isWorking)
    .privacySensitive()
  }

  private func submit() {
    guard canSubmit, !isWorking else { return }
    focusedField = nil
    errorMessage = nil
    let enteredPassword = password
    let previousCredential = profile.editLockCredential

    operation = Task { @MainActor in
      defer { operation = nil }
      do {
        if isUnlocking {
          let unlocked = try await ProfileLockUtil.unlock(profile, password: enteredPassword)
          guard !isBlocking else { return }
          onUnlock(unlocked)
        } else {
          let credential = try await Task.detached(priority: .userInitiated) {
            try ProfileLockUtil.createCredential(password: enteredPassword)
          }.value
          try Task.checkCancellation()
          guard !isBlocking, profile.editLockCredential == previousCredential else {
            throw ProfileLockError.unlockRequired
          }
          try ProfileLockUtil.setCredential(
            credential, for: profile, in: modelContext, authorization: authorization
          )
        }
        password = ""
        confirmation = ""
        dismiss()
      } catch is CancellationError {
        return
      } catch {
        errorMessage = error.localizedDescription
      }
    }
  }

  private func cancelOperation() {
    operation?.cancel()
    password = ""
    confirmation = ""
  }
}

#Preview("Protect Profile") {
  ProfilePasswordView(profile: BlockedProfiles(name: "Deep Work"), mode: .setup)
    .environmentObject(StrategyManager())
    .modelContainer(for: BlockedProfiles.self, inMemory: true)
}

#Preview("Unlock Profile") {
  ProfilePasswordView(profile: BlockedProfiles(name: "Deep Work"), mode: .unlock)
    .environmentObject(StrategyManager())
    .modelContainer(for: BlockedProfiles.self, inMemory: true)
}
