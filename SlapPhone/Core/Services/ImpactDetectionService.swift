import Foundation
import CoreMotion
import Combine

class ImpactDetectionService: ObservableObject {
    private let motionManager = CMMotionManager()
    private let settings = Settings.shared
    private var lastImpactTime: Date = .distantPast

    @Published var isDetecting: Bool = false
    @Published var currentAcceleration: Double = 0
    @Published var lastImpact: ImpactEvent?

    // Publishers for impacts
    let impactPublisher = PassthroughSubject<ImpactEvent, Never>()

    // Throw detection state
    private var freefallStartTime: Date?
    private let freefallThreshold: Double = 0.3  // Near-zero g for freefall
    private let minFreefallDuration: TimeInterval = 0.2

    init() {
        setupMotionManager()
    }

    private func setupMotionManager() {
        guard motionManager.isAccelerometerAvailable else {
            print("Accelerometer not available")
            return
        }

        motionManager.accelerometerUpdateInterval = 1.0 / 60.0  // 60 Hz
    }

    func startDetection() {
        guard !isDetecting else { return }

        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            guard let self = self, let data = data else { return }
            self.processAccelerometerData(data)
        }

        isDetecting = true
    }

    func stopDetection() {
        motionManager.stopAccelerometerUpdates()
        isDetecting = false
    }

    private func processAccelerometerData(_ data: CMAccelerometerData) {
        let acceleration = data.acceleration
        let magnitude = sqrt(
            acceleration.x * acceleration.x +
            acceleration.y * acceleration.y +
            acceleration.z * acceleration.z
        )

        currentAcceleration = magnitude

        // Check cooldown
        let now = Date()
        guard now.timeIntervalSince(lastImpactTime) >= settings.cooldownDuration else {
            return
        }

        // Check for slap (high g-force spike)
        if settings.slapDetectionEnabled && magnitude > settings.slapThreshold {
            let impact = ImpactEvent(type: .slap, magnitude: magnitude)
            triggerImpact(impact)
            return
        }

        // Check for throw (freefall detection)
        if settings.throwDetectionEnabled {
            detectThrow(magnitude: magnitude)
        }
    }

    private func detectThrow(magnitude: Double) {
        let now = Date()

        if magnitude < freefallThreshold {
            // In freefall
            if freefallStartTime == nil {
                freefallStartTime = now
            } else if let startTime = freefallStartTime,
                      now.timeIntervalSince(startTime) >= minFreefallDuration {
                // Confirmed throw
                let impact = ImpactEvent(type: .thrown, magnitude: 1.0)
                triggerImpact(impact)
                freefallStartTime = nil
            }
        } else {
            // Not in freefall
            freefallStartTime = nil
        }
    }

    func handleShake() {
        guard settings.shakeDetectionEnabled else { return }

        let now = Date()
        guard now.timeIntervalSince(lastImpactTime) >= settings.cooldownDuration else {
            return
        }

        let impact = ImpactEvent(type: .shake, magnitude: 1.0)
        triggerImpact(impact)
    }

    private func triggerImpact(_ impact: ImpactEvent) {
        lastImpactTime = Date()
        lastImpact = impact
        impactPublisher.send(impact)
    }

    deinit {
        stopDetection()
    }
}
