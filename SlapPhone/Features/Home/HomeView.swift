import SwiftUI
import Combine

struct HomeView: View {
    @EnvironmentObject var impactDetectionService: ImpactDetectionService
    @EnvironmentObject var audioService: AudioService
    @EnvironmentObject var hapticService: HapticService
    @EnvironmentObject var statisticsManager: StatisticsManager
    @EnvironmentObject var accessoryService: AccessoryService

    @StateObject private var viewModel = HomeViewModel()
    @State private var showSettings = false
    @State private var showVoicePacks = false
    @State private var isFlashing = false
    @State private var shakeTrigger = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                SlapColors.background
                    .ignoresSafeArea()

                // Flash overlay on impact
                FlashOverlay(isFlashing: isFlashing, color: SlapColors.primary)

                VStack(spacing: 0) {
                    // Top bar
                    topBar

                    Spacer()

                    // Main counter
                    SlapCounter(
                        count: statisticsManager.lifetimeSlaps,
                        label: "Lifetime Slaps"
                    )
                    .shake(trigger: shakeTrigger)
                    .padding(.bottom, 40)

                    // Impact visualizer
                    ImpactVisualizer(impact: impactDetectionService.lastImpact)
                        .frame(width: 250, height: 250)
                        .padding(.vertical, 20)

                    // Current sensitivity indicator
                    sensitivityIndicator
                        .padding(.top, 20)

                    Spacer()

                    // Bottom stats
                    StatCounterRow(
                        slaps: statisticsManager.lifetimeSlaps,
                        throwCount: statisticsManager.lifetimeThrows,
                        shakes: statisticsManager.lifetimeShakes
                    )
                    .padding(.bottom, 20)

                    // Bottom buttons
                    bottomBar
                }
                .padding(.horizontal)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showVoicePacks) {
                VoicePacksView()
            }
            .onAppear {
                startDetection()
            }
            .onDisappear {
                stopDetection()
            }
            .onReceive(impactDetectionService.impactPublisher) { impact in
                handleImpact(impact)
            }
            .onShake {
                impactDetectionService.handleShake()
            }
            .onReceive(accessoryService.plugEventPublisher) { isPlugIn in
                handlePlugEvent(isPlugIn: isPlugIn)
            }
        }
    }

    private func handlePlugEvent(isPlugIn: Bool) {
        audioService.playPlugSound(isPlugIn: isPlugIn)
        hapticService.playButtonHaptic()
        statisticsManager.recordPlugEvent()
    }

    private var topBar: some View {
        HStack {
            // Detection status
            HStack(spacing: 8) {
                Circle()
                    .fill(impactDetectionService.isDetecting ? SlapColors.success : SlapColors.text.opacity(0.3))
                    .frame(width: 10, height: 10)

                Text(impactDetectionService.isDetecting ? "Active" : "Paused")
                    .font(SlapFonts.caption)
                    .foregroundStyle(SlapColors.text.opacity(0.6))
            }

            Spacer()

            // Voice pack indicator
            Button {
                showVoicePacks = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: Settings.shared.selectedVoicePack.icon)
                        .font(.system(size: 14))
                    Text(Settings.shared.selectedVoicePack.name)
                        .font(SlapFonts.caption)
                }
                .foregroundStyle(SlapColors.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(SlapColors.secondary.opacity(0.15))
                .clipShape(Capsule())
            }
        }
        .padding(.top, 16)
    }

    private var sensitivityIndicator: some View {
        VStack(spacing: 4) {
            Text("Sensitivity: \(Int(Settings.shared.sensitivityLevel))")
                .font(SlapFonts.caption)
                .foregroundStyle(SlapColors.text.opacity(0.6))

            // Visual bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(SlapColors.text.opacity(0.1))

                    Capsule()
                        .fill(SlapColors.impactGradient)
                        .frame(width: geo.size.width * (Settings.shared.sensitivityLevel / 10))
                }
            }
            .frame(width: 100, height: 4)
        }
    }

    private var bottomBar: some View {
        HStack(spacing: 20) {
            // Settings button
            IconButton(icon: "gearshape.fill", action: { showSettings = true })

            Spacer()

            // Play/Pause detection
            Button {
                if impactDetectionService.isDetecting {
                    stopDetection()
                } else {
                    startDetection()
                }
            } label: {
                Image(systemName: impactDetectionService.isDetecting ? "pause.fill" : "play.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(SlapColors.primary)
                    .frame(width: 70, height: 70)
                    .background(SlapColors.primary.opacity(0.15))
                    .clipShape(Circle())
            }
            .buttonStyle(ScaleButtonStyle())

            Spacer()

            // Voice packs button
            IconButton(icon: "waveform", action: { showVoicePacks = true }, color: SlapColors.secondary)
        }
        .padding(.vertical, 20)
    }

    private func startDetection() {
        impactDetectionService.startDetection()
    }

    private func stopDetection() {
        impactDetectionService.stopDetection()
    }

    private func handleImpact(_ impact: ImpactEvent) {
        // Flash screen
        withAnimation(.easeOut(duration: 0.1)) {
            isFlashing = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeOut(duration: 0.15)) {
                isFlashing = false
            }
        }

        // Shake counter
        shakeTrigger.toggle()

        // Play audio
        audioService.playReaction(for: impact)

        // Play haptic
        hapticService.playImpactHaptic(for: impact)

        // Record stats
        statisticsManager.recordImpact(impact)
    }
}

// Shake gesture detection
extension View {
    func onShake(perform action: @escaping () -> Void) -> some View {
        self.modifier(ShakeDetector(onShake: action))
    }
}

struct ShakeDetector: ViewModifier {
    let onShake: () -> Void

    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.deviceDidShakeNotification)) { _ in
                onShake()
            }
    }
}

// Extend UIDevice to post shake notifications
extension UIDevice {
    static let deviceDidShakeNotification = Notification.Name(rawValue: "deviceDidShakeNotification")
}

// Extend UIWindow to detect shakes
extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(ImpactDetectionService())
        .environmentObject(AudioService())
        .environmentObject(HapticService())
        .environmentObject(StatisticsManager())
        .environmentObject(AccessoryService())
}
