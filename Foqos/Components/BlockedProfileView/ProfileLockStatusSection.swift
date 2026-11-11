import SwiftUI

struct ProfileLockStatusSection: View {
  @Environment(\.foqosPalette) private var palette

  let isLocked: Bool
  let isBlocking: Bool
  let onUnlock: () -> Void
  let onLock: () -> Void

  var body: some View {
    Section {
      HStack(alignment: .firstTextBaseline, spacing: 12) {
        Image(systemName: isLocked ? "lock.fill" : "lock.open.fill")
          .font(.subheadline)
          .foregroundStyle(palette.foreground)

        VStack(alignment: .leading, spacing: 4) {
          Text(isLocked ? "Profile locked" : "Unlocked for editing")
            .foqosText(.toggle)
          Text(
            isLocked
              ? "Unlock with your password to make changes."
              : "Your password is still on. This profile locks again when you leave."
          )
          .foqosText(.caption)
          .foregroundStyle(palette.mute)
          .fixedSize(horizontal: false, vertical: true)
        }
      }
      .padding(.vertical, 4)

      Button(action: isLocked ? onUnlock : onLock) {
        ProfileFormActionRow(title: isLocked ? "Unlock profile" : "Lock now")
      }
      .buttonStyle(FoqosPressStyle())
      .disabled(isBlocking)
      .accessibilityIdentifier("profileLockAction")
    } header: {
      FoqosSectionHeader("Password")
    }
    .foqosFormRows()
  }
}

#Preview {
  Form {
    ProfileLockStatusSection(isLocked: true, isBlocking: false, onUnlock: {}, onLock: {})
    ProfileLockStatusSection(isLocked: false, isBlocking: false, onUnlock: {}, onLock: {})
  }
  .foqosForm(.cream)
}
