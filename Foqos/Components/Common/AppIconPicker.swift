import SwiftUI

struct AppIconPicker: View {
  @Environment(\.foqosPalette) private var palette

  @State private var selectedIconName = UIApplication.shared.alternateIconName
  @State private var isChangingIcon = false
  @State private var showError = false
  @State private var errorMessage = ""

  var body: some View {
    Section {
      HStack(alignment: .top, spacing: 6) {
        ForEach(AppIconOption.allCases) { icon in
          Button {
            select(icon)
          } label: {
            VStack(spacing: 8) {
              Image(icon.previewAssetName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay {
                  RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(palette.line, lineWidth: 1)
                }
                .opacity(isSelected(icon) ? 1 : 0.7)

              Text(icon.displayName)
                .foqosText(.mark)
                .foregroundStyle(isSelected(icon) ? palette.foreground : palette.mute)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.bottom, 4)
                .overlay(alignment: .bottom) {
                  Rectangle()
                    .fill(isSelected(icon) ? palette.foreground : .clear)
                    .frame(height: 1)
                }
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
          }
          .buttonStyle(FoqosPressStyle())
          .disabled(isChangingIcon || isSelected(icon))
          .accessibilityLabel("Use the \(icon.displayName) app icon")
          .accessibilityAddTraits(isSelected(icon) ? .isSelected : [])
        }
      }
      .padding(.vertical, 8)

      if !UIApplication.shared.supportsAlternateIcons {
        Text("Alternate app icons are not available on this device.")
          .foqosText(.caption)
          .foregroundStyle(palette.mute)
      }
    } header: {
      FoqosSectionHeader("App Icon")
    }
    .alert("Unable to Change App Icon", isPresented: $showError) {
      Button("OK") {}
    } message: {
      Text(errorMessage)
    }
    .onAppear {
      selectedIconName = UIApplication.shared.alternateIconName
    }
  }

  private func isSelected(_ icon: AppIconOption) -> Bool {
    selectedIconName == icon.alternateIconName
  }

  private func select(_ icon: AppIconOption) {
    guard UIApplication.shared.supportsAlternateIcons else {
      errorMessage = "Alternate app icons are not available on this device."
      showError = true
      return
    }

    isChangingIcon = true
    UIApplication.shared.setAlternateIconName(icon.alternateIconName) { error in
      Task { @MainActor in
        isChangingIcon = false

        if let error {
          errorMessage = error.localizedDescription
          showError = true
          selectedIconName = UIApplication.shared.alternateIconName
          return
        }

        selectedIconName = UIApplication.shared.alternateIconName
        if let session = StrategyManager.shared.activeSession {
          LiveActivityManager.shared.updateSessionActivity(session: session)
        }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
      }
    }
  }
}

#Preview {
  Form {
    AppIconPicker()
      .foqosFormRows()
  }
  .foqosForm(.cream)
}
