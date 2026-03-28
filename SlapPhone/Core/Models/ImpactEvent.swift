import Foundation

struct ImpactEvent: Identifiable {
    let id = UUID()
    let type: ImpactType
    let magnitude: Double
    let timestamp: Date

    init(type: ImpactType, magnitude: Double) {
        self.type = type
        self.magnitude = magnitude
        self.timestamp = Date()
    }
}

enum ImpactType: String, CaseIterable {
    case slap
    case shake
    case thrown

    var displayName: String {
        switch self {
        case .slap: return "Slap"
        case .shake: return "Shake"
        case .thrown: return "Throw"
        }
    }

    var icon: String {
        switch self {
        case .slap: return "hand.raised.fill"
        case .shake: return "iphone.gen3.radiowaves.left.and.right"
        case .thrown: return "arrow.up.right"
        }
    }

    var color: String {
        switch self {
        case .slap: return "FF2D92"    // Pink
        case .shake: return "FFE600"   // Yellow
        case .thrown: return "7B2D8E"  // Purple
        }
    }
}
