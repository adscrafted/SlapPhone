import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var paywallManager: PaywallManager
    @EnvironmentObject var hapticService: HapticService

    let onPurchaseComplete: () -> Void

    @State private var isAnimating = false

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [SlapColors.background, SlapColors.accent.opacity(0.3), SlapColors.primary.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    Spacer(minLength: 40)

                    // Hero illustration
                    heroSection

                    // Feature list
                    featuresSection

                    // Price and purchase button
                    purchaseSection

                    // Restore purchases
                    restoreButton

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24)
            }
        }
        .onChange(of: paywallManager.isPurchased) { _, isPurchased in
            if isPurchased {
                hapticService.playSuccessHaptic()
                onPurchaseComplete()
            }
        }
    }

    private var heroSection: some View {
        VStack(spacing: 16) {
            // Phone being slapped illustration
            ZStack {
                Circle()
                    .fill(SlapColors.primary.opacity(0.2))
                    .frame(width: 180, height: 180)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)

                Image(systemName: "iphone")
                    .font(.system(size: 80, weight: .thin))
                    .foregroundStyle(SlapColors.text)

                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(SlapColors.primary)
                    .offset(x: isAnimating ? 10 : -20, y: -30)
                    .rotationEffect(.degrees(-20))
                    .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isAnimating)
            }
            .onAppear {
                isAnimating = true
            }

            Text("UNLOCK")
                .font(SlapFonts.largeTitle)
                .foregroundStyle(SlapColors.secondary)
            +
            Text(" SLAP")
                .font(SlapFonts.largeTitle)
                .foregroundStyle(SlapColors.primary)
            +
            Text("PHONE")
                .font(SlapFonts.largeTitle)
                .foregroundStyle(SlapColors.text)

            Text("Make your phone scream when you hit it")
                .font(SlapFonts.bodyMedium)
                .foregroundStyle(SlapColors.text.opacity(0.7))
                .multilineTextAlignment(.center)
        }
    }

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            FeatureRow(icon: "hand.raised.fill", title: "Slap Detection", description: "Instant reactions to impacts", color: SlapColors.primary)

            FeatureRow(icon: "arrow.up.right", title: "Throw Detection", description: "Knows when it's airborne", color: SlapColors.accent)

            FeatureRow(icon: "speaker.wave.3.fill", title: "4 Voice Packs", description: "32+ unique reactions", color: SlapColors.secondary)

            FeatureRow(icon: "bolt.fill", title: "USB Moaner", description: "Reacts to charging", color: SlapColors.success)

            FeatureRow(icon: "chart.bar.fill", title: "Lifetime Stats", description: "Track every impact", color: SlapColors.primary)
        }
        .padding(20)
        .background(SlapColors.text.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var purchaseSection: some View {
        VStack(spacing: 16) {
            // Price display - uses actual price from StoreKit
            if let product = paywallManager.product {
                Text(product.displayPrice)
                    .font(SlapFonts.heroTitle)
                    .foregroundStyle(SlapColors.text)
            } else {
                // Fallback while loading
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("$")
                        .font(SlapFonts.title)
                        .foregroundStyle(SlapColors.text.opacity(0.7))
                    Text("4.99")
                        .font(SlapFonts.heroTitle)
                        .foregroundStyle(SlapColors.text)
                }
            }

            Text("One-time purchase. No subscriptions.")
                .font(SlapFonts.caption)
                .foregroundStyle(SlapColors.text.opacity(0.5))

            // Purchase button
            SlapButton(
                title: "Unlock Full Version",
                action: {
                    Task {
                        await paywallManager.purchase()
                    }
                },
                isLoading: paywallManager.purchaseState == .purchasing
            )

            // Error message
            if let error = paywallManager.errorMessage {
                Text(error)
                    .font(SlapFonts.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }

            // Debug: Simulate purchase (remove for production)
            #if DEBUG
            Button("Debug: Simulate Purchase") {
                paywallManager.simulatePurchase()
            }
            .font(SlapFonts.caption)
            .foregroundStyle(SlapColors.text.opacity(0.3))
            #endif
        }
    }

    private var restoreButton: some View {
        Button {
            Task {
                await paywallManager.restorePurchases()
            }
        } label: {
            Text("Restore Purchases")
                .font(SlapFonts.bodyMedium)
                .foregroundStyle(SlapColors.text.opacity(0.6))
                .underline()
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(color)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(SlapFonts.bodyBold(size: 16))
                    .foregroundStyle(SlapColors.text)

                Text(description)
                    .font(SlapFonts.caption)
                    .foregroundStyle(SlapColors.text.opacity(0.6))
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(SlapColors.success)
        }
    }
}

#Preview {
    PaywallView(onPurchaseComplete: {})
        .environmentObject(PaywallManager())
        .environmentObject(HapticService())
}
