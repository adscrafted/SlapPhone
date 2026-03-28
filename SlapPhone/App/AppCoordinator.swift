import SwiftUI

enum AppScreen {
    case splash
    case paywall
    case home
}

class AppCoordinator: ObservableObject {
    @Published var currentScreen: AppScreen = .splash

    func navigateToPaywall() {
        withAnimation(.easeInOut(duration: 0.5)) {
            currentScreen = .paywall
        }
    }

    func navigateToHome() {
        withAnimation(.easeInOut(duration: 0.5)) {
            currentScreen = .home
        }
    }
}

struct AppCoordinatorView: View {
    @StateObject private var coordinator = AppCoordinator()
    @EnvironmentObject var paywallManager: PaywallManager

    var body: some View {
        ZStack {
            SlapColors.background
                .ignoresSafeArea()

            switch coordinator.currentScreen {
            case .splash:
                SplashView()
                    .transition(.opacity)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            if paywallManager.isPurchased {
                                coordinator.navigateToHome()
                            } else {
                                coordinator.navigateToPaywall()
                            }
                        }
                    }

            case .paywall:
                PaywallView {
                    coordinator.navigateToHome()
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))

            case .home:
                HomeView()
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .environmentObject(coordinator)
    }
}
