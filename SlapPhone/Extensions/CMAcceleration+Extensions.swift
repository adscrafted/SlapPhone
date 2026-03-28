import CoreMotion

extension CMAcceleration {
    /// Calculate the magnitude of the acceleration vector
    var magnitude: Double {
        sqrt(x * x + y * y + z * z)
    }

    /// Check if this acceleration indicates freefall (near-zero g)
    var isInFreefall: Bool {
        magnitude < 0.3
    }

    /// Check if this acceleration exceeds a threshold (impact detected)
    func exceedsThreshold(_ threshold: Double) -> Bool {
        magnitude > threshold
    }

    /// Get the dominant axis of acceleration
    var dominantAxis: AccelerationAxis {
        let absX = abs(x)
        let absY = abs(y)
        let absZ = abs(z)

        if absX >= absY && absX >= absZ {
            return .x
        } else if absY >= absX && absY >= absZ {
            return .y
        } else {
            return .z
        }
    }

    /// Formatted string representation
    var formatted: String {
        String(format: "x: %.2f, y: %.2f, z: %.2f (%.2fg)", x, y, z, magnitude)
    }
}

enum AccelerationAxis {
    case x, y, z

    var description: String {
        switch self {
        case .x: return "Left/Right"
        case .y: return "Forward/Back"
        case .z: return "Up/Down"
        }
    }
}
