import Foundation
import CoreHaptics
import UIKit

class HapticService: ObservableObject {
    private var engine: CHHapticEngine?
    private let settings = Settings.shared

    @Published var isHapticsAvailable: Bool = false

    init() {
        setupHapticEngine()
    }

    private func setupHapticEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            isHapticsAvailable = false
            return
        }

        do {
            engine = try CHHapticEngine()
            try engine?.start()
            isHapticsAvailable = true

            // Handle engine reset
            engine?.resetHandler = { [weak self] in
                do {
                    try self?.engine?.start()
                } catch {
                    print("Failed to restart haptic engine: \(error)")
                }
            }
        } catch {
            print("Failed to create haptic engine: \(error)")
            isHapticsAvailable = false
        }
    }

    func playImpactHaptic(for event: ImpactEvent) {
        guard settings.hapticFeedbackEnabled else { return }

        switch event.type {
        case .slap:
            playSlapHaptic(intensity: event.magnitude)
        case .shake:
            playShakeHaptic()
        case .thrown:
            playThrowHaptic()
        }
    }

    private func playSlapHaptic(intensity: Double) {
        // Use UIKit feedback for simplicity and reliability
        let normalizedIntensity = min(intensity / 5.0, 1.0)

        if normalizedIntensity > 0.7 {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.prepare()
            generator.impactOccurred(intensity: normalizedIntensity)
        } else if normalizedIntensity > 0.4 {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred(intensity: normalizedIntensity)
        } else {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.prepare()
            generator.impactOccurred(intensity: normalizedIntensity)
        }
    }

    private func playShakeHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }

    private func playThrowHaptic() {
        // Play a dramatic haptic pattern for throws
        guard let engine = engine else {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            return
        }

        do {
            let pattern = try throwHapticPattern()
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            // Fallback to simple haptic
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }

    private func throwHapticPattern() throws -> CHHapticPattern {
        var events: [CHHapticEvent] = []

        // Rising intensity followed by impact
        for i in 0..<5 {
            let intensity = Float(i + 1) / 5.0
            let event = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
                ],
                relativeTime: Double(i) * 0.05
            )
            events.append(event)
        }

        // Final big impact
        let finalImpact = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
            ],
            relativeTime: 0.25,
            duration: 0.2
        )
        events.append(finalImpact)

        return try CHHapticPattern(events: events, parameters: [])
    }

    func playButtonHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }

    func playSuccessHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    func playErrorHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
}
