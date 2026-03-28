import SwiftUI

@main
struct SlapPhoneApp: App {
    @StateObject private var paywallManager = PaywallManager()
    @StateObject private var statisticsManager = StatisticsManager()
    @StateObject private var impactDetectionService = ImpactDetectionService()
    @StateObject private var audioService = AudioService()
    @StateObject private var hapticService = HapticService()
    @StateObject private var accessoryService = AccessoryService()

    var body: some Scene {
        WindowGroup {
            AppCoordinatorView()
                .environmentObject(paywallManager)
                .environmentObject(statisticsManager)
                .environmentObject(impactDetectionService)
                .environmentObject(audioService)
                .environmentObject(hapticService)
                .environmentObject(accessoryService)
                .preferredColorScheme(.dark)
        }
    }
}
