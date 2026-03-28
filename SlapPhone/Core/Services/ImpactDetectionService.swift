import Foundation
import CoreMotion
import Combine
import UIKit

class ImpactDetectionService: ObservableObject {
    private let motionManager = CMMotionManager()
    private let settings = Settings.shared
    private var lastImpactTime: Date = .distantPast

    // Use a dedicated queue for background processing
    private let motionQueue = OperationQueue()
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid

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
        setupBackgroundObservers()
    }

    private func setupMotionManager() {
        guard motionManager.isAccelerometerAvailable else {
            print("Accelerometer not available")
            return
        }

        motionManager.accelerometerUpdateInterval = 1.0 / 60.0  // 60 Hz
        motionQueue.name = "com.slapphone.motion"
        motionQueue.qualityOfService = .userInteractive
    }

    private func setupBackgroundObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    @objc private func appDidEnterBackground() {
        guard isDetecting && settings.backgroundModeEnabled else { return }

        // Start background task to keep detection running
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
    }

    @objc private func appWillEnterForeground() {
        endBackgroundTask()
    }

    private func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }

    func startDetection() {
        guard !isDetecting else { return }

        // Use dedicated queue for background support
        motionManager.startAccelerometerUpdates(to: motionQueue) { [weak self] data, error in
            guard let self = self, let data = data else { return }
            self.processAccelerometerData(data)
        }

        DispatchQueue.main.async { [weak self] in
            self?.isDetecting = true
        }
    }

    func stopDetection() {
        motionManager.stopAccelerometerUpdates()
        DispatchQueue.main.async { [weak self] in
            self?.isDetecting = false
        }
    }

    private func processAccelerometerData(_ data: CMAccelerometerData) {
        let acceleration = data.acceleration
        let magnitude = sqrt(
            acceleration.x * acceleration.x +
            acceleration.y * acceleration.y +
            acceleration.z * acceleration.z
        )

        // Update UI on main thread
        DispatchQueue.main.async { [weak self] in
            self?.currentAcceleration = magnitude
        }

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
        DispatchQueue.main.async { [weak self] in
            self?.lastImpact = impact
            self?.impactPublisher.send(impact)
        }
    }

    deinit {
        stopDetection()
    }
}
