import SwiftUI
import UIKit

// MARK: - Palette

/// Two-tone editorial palette: cream on forest, or forest on cream.
struct FoqosPalette: Equatable {
  let background: Color
  let foreground: Color
  let mute: Color
  let line: Color
  let colorScheme: ColorScheme

  static let cream = FoqosPalette(
    background: FoqosColors.cream,
    foreground: FoqosColors.forest,
    mute: FoqosColors.forest.opacity(0.48),
    line: FoqosColors.forest.opacity(0.22),
    colorScheme: .light
  )

  static let forest = FoqosPalette(
    background: FoqosColors.forest,
    foreground: FoqosColors.cream,
    mute: FoqosColors.cream.opacity(0.55),
    line: FoqosColors.cream.opacity(0.28),
    colorScheme: .dark
  )
}

enum FoqosColors {
  static let cream = BrandColors.cream
  static let forest = BrandColors.forest
}

private struct FoqosPaletteKey: EnvironmentKey {
  static let defaultValue = FoqosPalette.cream
}

extension EnvironmentValues {
  var foqosPalette: FoqosPalette {
    get { self[FoqosPaletteKey.self] }
    set { self[FoqosPaletteKey.self] = newValue }
  }
}

private struct FoqosThemeModifier: ViewModifier {
  let palette: FoqosPalette
  let fillsBackground: Bool

  func body(content: Content) -> some View {
    content
      .environment(\.foqosPalette, palette)
      .environment(\.colorScheme, palette.colorScheme)
      .foregroundStyle(palette.foreground)
      .tint(palette.foreground)
      .background {
        if fillsBackground {
          palette.background.ignoresSafeArea()
        }
      }
  }
}

extension View {
  /// Applies the palette to the subtree. Native controls follow the matching color scheme.
  func foqosTheme(_ palette: FoqosPalette, fillsBackground: Bool = true) -> some View {
    modifier(FoqosThemeModifier(palette: palette, fillsBackground: fillsBackground))
  }
}

// MARK: - Typography

enum FoqosFont {
  // Suisse BP Int'l (design-ref/) is a commercial retail font. Once an app-embedding
  // license is in place, convert the files to .otf/.ttf, add them to UIAppFonts, and
  // set this to "SuisseBPIntl" to switch every UI label over.
  static let uiFamily: String? = nil

  static func ui(_ style: Font.TextStyle, size: CGFloat, bold: Bool) -> Font {
    if let uiFamily {
      return .custom("\(uiFamily)-\(bold ? "Bold" : "Regular")", size: size, relativeTo: style)
    }
    return .system(style, design: .default, weight: bold ? .bold : .regular)
  }
}

/// Uppercase/tracked label roles from the design reference.
enum FoqosTextRole {
  case eyebrow
  case tab
  case cta
  case mark
  case caption
  case toggle
  case body

  fileprivate var textStyle: Font.TextStyle {
    switch self {
    case .eyebrow: return .caption
    case .tab, .caption: return .footnote
    case .cta: return .subheadline
    case .mark: return .caption2
    case .toggle, .body: return .callout
    }
  }

  fileprivate var pointSize: CGFloat {
    switch self {
    case .eyebrow: return 12
    case .tab, .caption: return 13
    case .cta: return 14
    case .mark: return 11
    case .toggle, .body: return 16
    }
  }

  fileprivate var isBold: Bool {
    switch self {
    case .caption, .body: return false
    default: return true
    }
  }

  fileprivate var isUppercase: Bool {
    switch self {
    case .caption, .body: return false
    default: return true
    }
  }

  /// Letter-spacing in em, converted to points below.
  fileprivate var trackingEm: CGFloat {
    switch self {
    case .eyebrow: return 0.18
    case .tab: return 0.16
    case .cta, .mark: return 0.14
    case .caption, .toggle: return 0.04
    case .body: return 0
    }
  }
}

private struct FoqosTextModifier: ViewModifier {
  let role: FoqosTextRole

  func body(content: Content) -> some View {
    content
      .font(FoqosFont.ui(role.textStyle, size: role.pointSize, bold: role.isBold))
      .tracking(role.pointSize * role.trackingEm)
      .textCase(role.isUppercase ? .uppercase : nil)
  }
}

private struct FoqosDisplayModifier: ViewModifier {
  @ScaledMetric private var size: CGFloat
  let isItalic: Bool

  init(size: CGFloat, isItalic: Bool) {
    _size = ScaledMetric(wrappedValue: size, relativeTo: .largeTitle)
    self.isItalic = isItalic
  }

  func body(content: Content) -> some View {
    content
      .font(.system(size: size, weight: .regular, design: .serif))
      .italic(isItalic)
      .tracking(-size * 0.02)
  }
}

extension View {
  func foqosText(_ role: FoqosTextRole) -> some View {
    modifier(FoqosTextModifier(role: role))
  }

  /// High-contrast serif for sentence-case display titles.
  func foqosDisplay(size: CGFloat, italic: Bool = false) -> some View {
    modifier(FoqosDisplayModifier(size: size, isItalic: italic))
  }
}

// MARK: - Rules

struct FoqosHairline: View {
  @Environment(\.foqosPalette) private var palette
  var isStrong = false

  var body: some View {
    Rectangle()
      .fill(isStrong ? palette.foreground : palette.line)
      .frame(height: 1)
      .accessibilityHidden(true)
  }
}

// MARK: - Buttons

/// Primary action: full-width label sitting under a hairline rule, arrow on the right.
struct FoqosLineButton: View {
  @Environment(\.foqosPalette) private var palette
  @Environment(\.isEnabled) private var isEnabled

  let title: String
  var trailing: String? = "→"
  var isMuted = false
  let action: () -> Void

  var body: some View {
    Button(action: tapped) {
      label
    }
    .buttonStyle(FoqosPressStyle())
  }

  private var label: some View {
    VStack(spacing: 0) {
      FoqosHairline(isStrong: !isMuted)

      HStack(alignment: .firstTextBaseline) {
        Text(title)
          .foqosText(.cta)
          .lineLimit(1)
          .minimumScaleFactor(0.75)

        Spacer(minLength: 12)

        if let trailing {
          Text(trailing)
            .foqosText(.cta)
            .accessibilityHidden(true)
        }
      }
      .padding(.top, 18)
      .padding(.bottom, 4)
      .frame(minHeight: 44)
    }
    .foregroundStyle(isMuted ? palette.mute : palette.foreground)
    .opacity(isEnabled ? 1 : 0.4)
    .contentShape(Rectangle())
  }

  private func tapped() {
    UIImpactFeedbackGenerator(style: .light).impactOccurred()
    action()
  }
}

/// Small uppercase text link used for secondary navigation (Settings, Manage…).
struct FoqosTextLink: View {
  @Environment(\.foqosPalette) private var palette

  let title: String
  var isMuted = true
  let action: () -> Void

  init(_ title: String, isMuted: Bool = true, action: @escaping () -> Void) {
    self.title = title
    self.isMuted = isMuted
    self.action = action
  }

  var body: some View {
    Button(action: action) {
      Text(title)
        .foqosText(.mark)
        .foregroundStyle(isMuted ? palette.mute : palette.foreground)
        .frame(minHeight: 44)
        .contentShape(Rectangle())
    }
    .buttonStyle(FoqosPressStyle())
  }
}

struct FoqosPressStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .opacity(configuration.isPressed ? 0.65 : 1)
  }
}

// MARK: - Toggle

/// Hairline track with a small dot, labelled in bold uppercase.
struct FoqosLineToggleStyle: ToggleStyle {
  func makeBody(configuration: Configuration) -> some View {
    FoqosLineToggle(configuration: configuration)
  }
}

private struct FoqosLineToggle: View {
  @Environment(\.foqosPalette) private var palette
  @Environment(\.isEnabled) private var isEnabled

  let configuration: ToggleStyleConfiguration

  var body: some View {
    Button {
      withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
        configuration.isOn.toggle()
      }
    } label: {
      HStack(spacing: 16) {
        configuration.label
          .foqosText(.toggle)
          .frame(maxWidth: .infinity, alignment: .leading)

        ZStack(alignment: configuration.isOn ? .trailing : .leading) {
          Rectangle()
            .fill(configuration.isOn ? palette.foreground : palette.line)
            .frame(width: 36, height: 2)

          Circle()
            .fill(palette.foreground)
            .frame(width: 10, height: 10)
        }
        .frame(width: 36, height: 10)
      }
      .frame(minHeight: 44)
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .foregroundStyle(palette.foreground)
    .opacity(isEnabled ? 1 : 0.4)
    .accessibilityAddTraits(.isToggle)
    .accessibilityValue(configuration.isOn ? "On" : "Off")
  }
}

// MARK: - Form styling

struct FoqosSectionHeader: View {
  @Environment(\.foqosPalette) private var palette
  let title: String

  init(_ title: String) {
    self.title = title
  }

  var body: some View {
    Text(title)
      .foqosText(.eyebrow)
      .foregroundStyle(palette.mute)
      .padding(.top, 12)
  }
}

private struct FoqosFormModifier: ViewModifier {
  let palette: FoqosPalette

  func body(content: Content) -> some View {
    content
      .scrollContentBackground(.hidden)
      .toggleStyle(FoqosLineToggleStyle())
      .foqosTheme(palette)
  }
}

private struct FoqosFormRowsModifier: ViewModifier {
  @Environment(\.foqosPalette) private var palette

  func body(content: Content) -> some View {
    content
      .listRowBackground(Color.clear)
      .listRowSeparatorTint(palette.line)
  }
}

extension View {
  /// Strips grouped-form chrome: page background shows through, toggles become line toggles.
  func foqosForm(_ palette: FoqosPalette = .cream) -> some View {
    modifier(FoqosFormModifier(palette: palette))
  }

  /// Apply to Form sections so rows sit directly on the page with hairline separators.
  func foqosFormRows() -> some View {
    modifier(FoqosFormRowsModifier())
  }
}

#Preview("Cream") {
  VStack(alignment: .leading, spacing: 18) {
    Text("Personal focus").foqosText(.eyebrow)
    Text("Stay present").foqosDisplay(size: 58)
    Text("until you return").foqosDisplay(size: 58, italic: true)
      .foregroundStyle(FoqosPalette.cream.mute)
    FoqosHairline()
    Toggle("Strict unlock", isOn: .constant(true))
      .toggleStyle(FoqosLineToggleStyle())
    Spacer()
    FoqosLineButton(title: "Start a session", action: {})
  }
  .padding(24)
  .foqosTheme(.cream)
}

#Preview("Forest") {
  VStack(alignment: .leading, spacing: 18) {
    Text("Session active").foqosText(.cta)
    Text("Deep Work").foqosDisplay(size: 64)
    Spacer()
    FoqosLineButton(title: "Stop session", action: {})
  }
  .padding(24)
  .foqosTheme(.forest)
}
