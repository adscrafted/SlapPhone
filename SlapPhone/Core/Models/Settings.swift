import Foundation
import SwiftUI

class Settings: ObservableObject {
    static let shared = Settings()

    // Detection toggles
    @AppStorage("slapDetectionEnabled") var slapDetectionEnabled: Bool = true
    @AppStorage("throwDetectionEnabled") var throwDetectionEnabled: Bool = true
    @AppStorage("shakeDetectionEnabled") var shakeDetectionEnabled: Bool = true
    @AppStorage("usbMoanerEnabled") var usbMoanerEnabled: Bool = true
    @AppStorage("hapticFeedbackEnabled") var hapticFeedbackEnabled: Bool = true
    @AppStorage("backgroundModeEnabled") var backgroundModeEnabled: Bool = true

    // Sensitivity (1-10 scale, maps to g-force threshold)
    @AppStorage("sensitivityLevel") var sensitivityLevel: Double = 5.0

    // Cooldown (in seconds)
    @AppStorage("cooldownDuration") var cooldownDuration: Double = 1.0

    // Selected voice pack
    @AppStorage("selectedVoicePackId") var selectedVoicePackId: String = "default"

    // Volume (0-1)
    @AppStorage("volume") var volume: Double = 1.0

    // Computed properties
    var slapThreshold: Double {
        // Sensitivity 1 = 4.0g (least sensitive)
        // Sensitivity 10 = 1.0g (most sensitive)
        let minThreshold = 1.0
        let maxThreshold = 4.0
        return maxThreshold - ((sensitivityLevel - 1) / 9.0) * (maxThreshold - minThreshold)
    }

    var selectedVoicePack: VoicePack {
        VoicePack.allPacks.first { $0.id == selectedVoicePackId } ?? .default
    }

    func selectVoicePack(_ pack: VoicePack) {
        selectedVoicePackId = pack.id
    }
}
