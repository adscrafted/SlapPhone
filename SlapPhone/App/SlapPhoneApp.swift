import SwiftUI

@main
struct SlapPhoneApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var paywallManager = PaywallManager()
    @StateObject private var statisticsManager = StatisticsManager()
    @StateObject private var impactDetectionService = ImpactDetectionService()
    @StateObject private var audioService = AudioService()
    @StateObject private var hapticService = HapticService()
    @StateObject private var accessoryService = AccessoryService()
    @Environment(\.scenePhase) private var scenePhase

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
                .onChange(of: scenePhase) { oldPhase, newPhase in
                    handleScenePhaseChange(from: oldPhase, to: newPhase)
                }
        }
    }

    private func handleScenePhaseChange(from oldPhase: ScenePhase, to newPhase: ScenePhase) {
        switch newPhase {
        case .background:
            // Start background audio to keep app alive
            if impactDetectionService.isDetecting {
                audioService.startBackgroundMode()
            }
        case .active:
            // Stop background audio mode when returning to foreground
            audioService.stopBackgroundMode()
        case .inactive:
            break
        @unknown default:
            break
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
}
