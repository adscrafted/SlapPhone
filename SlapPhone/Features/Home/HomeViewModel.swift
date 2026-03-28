import Foundation
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var isDetectionActive = false
    @Published var lastImpactType: ImpactType?
    @Published var currentMagnitude: Double = 0

    private var cancellables = Set<AnyCancellable>()

    init() {
        // Additional setup if needed
    }

    func formatMagnitude(_ magnitude: Double) -> String {
        String(format: "%.1fg", magnitude)
    }
}
