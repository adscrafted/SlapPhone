import Foundation
import UIKit
import Combine

class AccessoryService: ObservableObject {
    @Published var isPluggedIn: Bool = false

    private var cancellables = Set<AnyCancellable>()
    private var wasPluggedIn: Bool = false
    private let settings = Settings.shared

    let plugEventPublisher = PassthroughSubject<Bool, Never>()  // true = plugged in, false = unplugged

    init() {
        setupBatteryMonitoring()
    }

    private func setupBatteryMonitoring() {
        // Enable battery monitoring
        UIDevice.current.isBatteryMonitoringEnabled = true

        // Check initial state
        updateBatteryState()

        // Monitor for changes
        NotificationCenter.default.publisher(for: UIDevice.batteryStateDidChangeNotification)
            .sink { [weak self] _ in
                self?.updateBatteryState()
            }
            .store(in: &cancellables)
    }

    private func updateBatteryState() {
        let batteryState = UIDevice.current.batteryState
        let isCharging = batteryState == .charging || batteryState == .full

        // Detect transitions
        if isCharging != wasPluggedIn {
            isPluggedIn = isCharging

            if settings.usbMoanerEnabled {
                plugEventPublisher.send(isCharging)
            }

            wasPluggedIn = isCharging
        }
    }

    func checkCurrentState() {
        let batteryState = UIDevice.current.batteryState
        isPluggedIn = batteryState == .charging || batteryState == .full
        wasPluggedIn = isPluggedIn
    }
}
