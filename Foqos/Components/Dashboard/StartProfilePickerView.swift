import SwiftUI
import UIKit

struct StartProfilePickerView: View {
  @Environment(\.dismiss) private var dismiss

  let profiles: [BlockedProfiles]
  let isBlocking: Bool
  let activeSessionProfileId: UUID?
  let startingProfileId: UUID?
  let onGoTapped: (BlockedProfiles) -> Void

  @State private var selectedProfileId: UUID?

  init(
    profiles: [BlockedProfiles],
    isBlocking: Bool,
    activeSessionProfileId: UUID?,
    startingProfileId: UUID? = nil,
    onGoTapped: @escaping (BlockedProfiles) -> Void
  ) {
    self.profiles = profiles
    self.isBlocking = isBlocking
    self.activeSessionProfileId = activeSessionProfileId
    self.startingProfileId = startingProfileId
    self.onGoTapped = onGoTapped
    _selectedProfileId = State(
      initialValue: profiles.first(where: { $0.id == startingProfileId })?.id ?? profiles.first?.id)
  }

  private var selectedProfile: BlockedProfiles? {
    guard let selectedProfileId else { return nil }
    return profiles.first(where: { $0.id == selectedProfileId })
  }

  private var canGo: Bool {
    selectedProfile != nil && !isBlocking
  }

  var body: some View {
    NavigationStack {
      VStack(alignment: .leading, spacing: 0) {
        VStack(alignment: .leading, spacing: 10) {
          Text("Start a session")
            .foqosText(.eyebrow)
            .foregroundStyle(FoqosPalette.cream.mute)

          Text("Choose a profile")
            .foqosDisplay(size: 40)
            .accessibilityAddTraits(.isHeader)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 18)

        if profiles.isEmpty {
          EmptyView(
            iconName: "person.crop.circle.badge.plus",
            headingText: "Create a profile before starting a focus session"
          )
          .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
          ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
              if isBlocking {
                activeSessionNotice
              }

              FoqosHairline()

              ForEach(profiles) { profile in
                StartProfilePickerRow(
                  profile: profile,
                  isSelected: profile.id == selectedProfileId,
                  isActive: profile.id == activeSessionProfileId,
                  onTap: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.74)) {
                      selectedProfileId = profile.id
                    }
                  }
                )

                FoqosHairline()
              }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 12)
          }
        }

        goButton
      }
      .padding(.top, 30)
      .foqosTheme(.cream)
      .toolbarBackground(FoqosColors.cream, for: .navigationBar)

      .onChange(of: profiles) { _, newProfiles in
        if selectedProfile == nil {
          withAnimation(.spring(response: 0.28, dampingFraction: 0.74)) {
            selectedProfileId = newProfiles.first?.id
          }
        }
      }
      .onChange(of: startingProfileId) { _, newValue in
        if let newValue, profiles.contains(where: { $0.id == newValue }) {
          withAnimation(.spring(response: 0.28, dampingFraction: 0.74)) {
            selectedProfileId = newValue
          }
        }
      }
    }
  }

  private var activeSessionNotice: some View {
    HStack(alignment: .firstTextBaseline, spacing: 10) {
      Image(systemName: "lock.fill")
        .font(.subheadline)

      Text("A profile is already active. Stop it before starting another one.")
        .foqosText(.caption)
        .foregroundStyle(FoqosPalette.cream.mute)
        .fixedSize(horizontal: false, vertical: true)

      Spacer(minLength: 0)
    }
    .padding(.bottom, 16)
  }

  private var goButton: some View {
    FoqosLineButton(title: "Go", action: goTapped)
      .disabled(!canGo)
      .accessibilityLabel("Start selected profile")
      .padding(.horizontal, 24)
      .padding(.top, 10)
      .padding(.bottom, 16)
  }

  private func goTapped() {
    guard let selectedProfile, !isBlocking else { return }
    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    onGoTapped(selectedProfile)
    dismiss()
  }
}

private struct StartProfilePickerRow: View {
  @Environment(\.foqosPalette) private var palette

  let profile: BlockedProfiles
  let isSelected: Bool
  let isActive: Bool
  let onTap: () -> Void

  private var metadataText: String {
    let appCount = FamilyActivityUtil.countSelectedActivities(
      profile.selectedActivity,
      allowMode: profile.enableAllowMode
    )
    let domainCount = profile.domains?.count ?? 0
    return [
      "\(appCount) \(appCount == 1 ? "app" : "apps")",
      "\(domainCount) \(domainCount == 1 ? "domain" : "domains")",
    ].joined(separator: " · ")
  }

  var body: some View {
    Button(action: onTap) {
      HStack(alignment: .firstTextBaseline, spacing: 12) {
        VStack(alignment: .leading, spacing: 6) {
          HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(profile.name)
              .foqosDisplay(size: 28)
              .lineLimit(2)
              .multilineTextAlignment(.leading)

            if isActive {
              Text("Active")
                .foqosText(.mark)
            }
          }

          Text(metadataText)
            .foqosText(.caption)
            .foregroundStyle(palette.mute)
            .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)

        Text(isSelected ? "Selected" : "Select")
          .foqosText(.mark)
          .foregroundStyle(isSelected ? palette.foreground : palette.mute)
      }
      .padding(.vertical, 16)
      .opacity(isSelected ? 1 : 0.6)
      .contentShape(Rectangle())
    }
    .buttonStyle(FoqosPressStyle())
    .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    .animation(.easeOut(duration: 0.2), value: isSelected)
  }
}

#Preview {
  StartProfilePickerView(
    profiles: [
      BlockedProfiles(name: "Work"),
      BlockedProfiles(name: "Study"),
    ],
    isBlocking: false,
    activeSessionProfileId: nil,
    onGoTapped: { _ in }
  )
  .environmentObject(ThemeManager.shared)
  .foqosTheme(.cream)
}
