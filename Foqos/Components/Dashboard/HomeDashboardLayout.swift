import SwiftUI

struct HomeDashboardLayout<Profiles: View, Insights: View>: View {
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @Binding private var preferredCompactColumn: NavigationSplitViewColumn

  private let insights: Insights
  private let profiles: (Bool) -> Profiles

  init(
    preferredCompactColumn: Binding<NavigationSplitViewColumn>,
    @ViewBuilder profiles: @escaping (Bool) -> Profiles,
    @ViewBuilder insights: () -> Insights
  ) {
    _preferredCompactColumn = preferredCompactColumn
    self.insights = insights()
    self.profiles = profiles
  }

  var body: some View {
    GeometryReader { geometry in
      let showsProfileInsights =
        horizontalSizeClass == .regular && geometry.size.width > geometry.size.height

      if showsProfileInsights {
        NavigationSplitView(preferredCompactColumn: $preferredCompactColumn) {
          profiles(true)
            .background {
              FoqosColors.cream
                .ignoresSafeArea()
            }
            .overlay(alignment: .trailing) {
              Rectangle()
                .fill(FoqosPalette.cream.line)
                .frame(width: 1)
                .ignoresSafeArea(edges: .vertical)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
            }
        } detail: {
          insights
        }
        .navigationSplitViewStyle(.balanced)
      } else {
        NavigationStack {
          profiles(false)
        }
      }
    }
  }
}

#Preview {
  @Previewable @State var preferredColumn: NavigationSplitViewColumn = .sidebar

  HomeDashboardLayout(preferredCompactColumn: $preferredColumn) { _ in
    List {
      Button("Deep Work") { preferredColumn = .detail }
    }
    .navigationTitle("Profiles")
  } insights: {
    Text("Deep Work Insights")
      .navigationTitle("Insights")
  }
}
