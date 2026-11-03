import StoreKit
import SwiftUI

private let threadsURL = URL(string: "https://www.threads.com/@softwarecuddler")!
private let twitterURL = URL(string: "https://x.com/softwarecuddler")!
private let redditURL = URL(string: "https://www.reddit.com/user/waseema393/")!
private let linkedinURL = URL(string: "https://www.linkedin.com/in/aliw")!

struct SupportView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Environment(\.scenePhase) private var scenePhase
  @EnvironmentObject var donationManager: TipManager
  @EnvironmentObject var themeManager: ThemeManager

  @State private var stampScale: CGFloat = 0.1
  @State private var stampRotation: Double = 0
  @State private var stampOpacity: Double = 0.0
  @State private var selectedProductID: String?
  @State private var celebrationStart: Date?
  @State private var hasPendingCelebration = false
  @State private var isShowingThankYou = false

  private var selectedProduct: Product? {
    donationManager.products.first { $0.id == selectedProductID } ?? donationManager.products.first
  }

  private var selectedTipEmoji: String {
    switch selectedProduct?.id {
    case "tip_developer_support_5": "🤑"
    case "tip_developer_support_10": "😱"
    default: "❤️"
    }
  }

  var body: some View {
    NavigationStack {
      GeometryReader { geometry in
        ScrollView {
          supportContent
            .frame(maxWidth: 600)
            .frame(minHeight: max(0, geometry.size.height - 40))
            .frame(maxWidth: .infinity)
            .padding(20)
        }
        .opacity(isShowingThankYou ? 0 : 1)
        .allowsHitTesting(!isShowingThankYou)
        .accessibilityHidden(isShowingThankYou)
        .overlay {
          if isShowingThankYou {
            TipThankYouView()
              .id(celebrationStart)
              .frame(maxWidth: .infinity, maxHeight: .infinity)
              .transition(.opacity)
          }
        }
      }
      .foqosTheme(.cream)
      .navigationTitle("Support")
      .navigationBarTitleDisplayMode(.inline)
      .toolbarBackground(FoqosColors.cream, for: .navigationBar)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button("Close", systemImage: "xmark") { dismiss() }
        }
      }
      .tint(FoqosColors.forest)
    }
    .overlay {
      if let celebrationStart, !reduceMotion {
        TipConfettiView(startDate: celebrationStart)
          .ignoresSafeArea()
          .allowsHitTesting(false)
          .accessibilityHidden(true)
      }
    }
    .onChange(of: donationManager.completedTipCount) {
      hasPendingCelebration = true
      celebrateIfReady()
    }
    .onChange(of: scenePhase) {
      celebrateIfReady()
    }
    .sensoryFeedback(.success, trigger: donationManager.completedTipCount)
    .task(id: celebrationStart) {
      guard celebrationStart != nil else { return }
      do {
        try await Task.sleep(for: .seconds(4))
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
          isShowingThankYou = false
        }
        try await Task.sleep(for: .seconds(1))
        celebrationStart = nil
      } catch {
        return
      }
    }
    .task {
      await donationManager.loadProducts()
      for await _ in Storefront.updates {
        await donationManager.loadProducts()
      }
    }
  }

  private func celebrateIfReady() {
    guard hasPendingCelebration, scenePhase == .active else { return }
    hasPendingCelebration = false
    celebrationStart = Date()
    withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
      isShowingThankYou = true
    }
  }

  private var supportContent: some View {
    VStack(alignment: .leading, spacing: 24) {
      Spacer()

      Image("ThankYouStamp")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 140, height: 140)
        .frame(maxWidth: .infinity, alignment: .center)
        .scaleEffect(stampScale)
        .rotationEffect(.degrees(stampRotation))
        .opacity(stampOpacity)
        .onAppear {
          withAnimation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.6)) {
            stampScale = 1
            stampRotation = 8
            stampOpacity = 1
          }
        }
        .padding(.bottom, 12)

      VStack(alignment: .leading, spacing: 10) {
        Text("Support")
          .foqosText(.eyebrow)
          .foregroundStyle(FoqosPalette.cream.mute)

        Text("Thank you for being here")
          .foqosDisplay(size: 40)
          .fixedSize(horizontal: false, vertical: true)
          .accessibilityAddTraits(.isHeader)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .fadeInSlide(delay: 0.3)

      VStack(alignment: .leading, spacing: 16) {
        Text(
          "Foqos started as a small attempt to make focus feel easier and more intentional. Every person who uses it, shares it, reviews it, or supports it helps keep that idea alive."
        )

        Text(
          "If this has helped you, consider leaving a review, telling a friend, or making a small donation."
        )
      }
      .foqosText(.body)
      .multilineTextAlignment(.leading)
      .foregroundStyle(FoqosPalette.cream.mute)
      .frame(maxWidth: .infinity, alignment: .leading)
      .fadeInSlide(delay: 0.3)

      FoqosHairline()

      VStack(alignment: .leading, spacing: 18) {
        Text(
          "For setup questions and common problems, start with the [Help Center](https://www.foqos.app/support.html). Follow along or share how Foqos fits into your day."
        )
        .foqosText(.body)
        .multilineTextAlignment(.leading)
        .foregroundStyle(FoqosPalette.cream.mute)
        .tint(FoqosColors.forest)

        HStack(alignment: .center, spacing: 20) {
          Link(destination: threadsURL) {
            Image("Threads")
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: 24, height: 24)
          }

          Link(destination: twitterURL) {
            Image("Twitter")
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: 24, height: 24)
          }
          Link(destination: redditURL) {
            Image("Reddit")
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: 24, height: 24)
          }

          Link(destination: linkedinURL) {
            Image("Linkedin")
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: 24, height: 24)
          }
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .fadeInSlide(delay: 0.4)

      Spacer()

      tipSection
        .fadeInSlide(delay: 0.6)
    }
  }

  private var tipSection: some View {
    VStack(spacing: 24) {
      if donationManager.isLoadingProducts {
        ProgressView("Loading tips…")
          .foqosText(.caption)
          .padding()
      } else if let error = donationManager.productLoadingError {
        Text(error)
          .foqosText(.caption)
          .foregroundStyle(FoqosPalette.cream.mute)
          .multilineTextAlignment(.center)
        FoqosTextLink("Try again", isMuted: false) {
          Task { await donationManager.loadProducts() }
        }
      } else if !donationManager.products.isEmpty {
        HStack(spacing: 0) {
          ForEach(donationManager.products) { product in
            Button {
              selectedProductID = product.id
            } label: {
              VStack(spacing: 8) {
                Text(product.displayPrice)
                  .foqosText(.cta)
                  .lineLimit(1)
                  .minimumScaleFactor(0.75)
                  .foregroundStyle(
                    selectedProduct?.id == product.id
                      ? FoqosPalette.cream.foreground : FoqosPalette.cream.mute
                  )

                Rectangle()
                  .fill(
                    selectedProduct?.id == product.id
                      ? FoqosPalette.cream.foreground : Color.clear
                  )
                  .frame(width: 24, height: 1)
              }
              .padding(.horizontal, 8)
              .frame(maxWidth: .infinity, minHeight: 44)
              .contentShape(Rectangle())
            }
            .buttonStyle(FoqosPressStyle())
            .accessibilityAddTraits(selectedProduct?.id == product.id ? .isSelected : [])
          }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Tip amount")
        .disabled(donationManager.loadingTip)
      }

      FoqosLineButton(
        title: donationManager.loadingTip
          ? "Processing…"
          : selectedProduct.map { "Tip \($0.displayPrice) \(selectedTipEmoji)" }
            ?? "Leave a tip"
      ) {
        guard let product = selectedProduct else { return }
        Task { await donationManager.tip(product) }
      }
      .disabled(
        selectedProduct == nil || donationManager.isLoadingProducts
          || donationManager.loadingTip
      )

      if let error = donationManager.purchaseError {
        Text(error)
          .foqosText(.caption)
          .foregroundStyle(.red)
          .multilineTextAlignment(.center)
      }

      if let message = donationManager.purchaseMessage {
        Text(message)
          .foqosText(.caption)
          .foregroundStyle(FoqosPalette.cream.mute)
          .multilineTextAlignment(.center)
      }

    }
    .frame(maxWidth: .infinity)
  }

}

#Preview("Support") {
  SupportView()
    .environmentObject(TipManager())
    .environmentObject(ThemeManager.shared)
}

#Preview("Dark") {
  SupportView()
    .environmentObject(TipManager())
    .environmentObject(ThemeManager.shared)
    .preferredColorScheme(.dark)
}
