import Foundation
import Combine

class StatisticsManager: ObservableObject {
    @Published var lifetimeSlaps: Int {
        didSet { UserDefaults.standard.set(lifetimeSlaps, forKey: "lifetimeSlaps") }
    }

    @Published var lifetimeThrows: Int {
        didSet { UserDefaults.standard.set(lifetimeThrows, forKey: "lifetimeThrows") }
    }

    @Published var lifetimeShakes: Int {
        didSet { UserDefaults.standard.set(lifetimeShakes, forKey: "lifetimeShakes") }
    }

    @Published var hardestSlap: Double {
        didSet { UserDefaults.standard.set(hardestSlap, forKey: "hardestSlap") }
    }

    @Published var totalPlugEvents: Int {
        didSet { UserDefaults.standard.set(totalPlugEvents, forKey: "totalPlugEvents") }
    }

    @Published var recentImpacts: [ImpactEvent] = []

    var totalImpacts: Int {
        lifetimeSlaps + lifetimeThrows + lifetimeShakes
    }

    init() {
        self.lifetimeSlaps = UserDefaults.standard.integer(forKey: "lifetimeSlaps")
        self.lifetimeThrows = UserDefaults.standard.integer(forKey: "lifetimeThrows")
        self.lifetimeShakes = UserDefaults.standard.integer(forKey: "lifetimeShakes")
        self.hardestSlap = UserDefaults.standard.double(forKey: "hardestSlap")
        self.totalPlugEvents = UserDefaults.standard.integer(forKey: "totalPlugEvents")
    }

    func recordImpact(_ event: ImpactEvent) {
        switch event.type {
        case .slap:
            lifetimeSlaps += 1
            if event.magnitude > hardestSlap {
                hardestSlap = event.magnitude
            }
        case .thrown:
            lifetimeThrows += 1
        case .shake:
            lifetimeShakes += 1
        }

        // Keep last 10 impacts for recent history
        recentImpacts.insert(event, at: 0)
        if recentImpacts.count > 10 {
            recentImpacts.removeLast()
        }
    }

    func recordPlugEvent() {
        totalPlugEvents += 1
    }

    func resetStatistics() {
        lifetimeSlaps = 0
        lifetimeThrows = 0
        lifetimeShakes = 0
        hardestSlap = 0
        totalPlugEvents = 0
        recentImpacts.removeAll()
    }

    func formattedHardestSlap() -> String {
        String(format: "%.1fg", hardestSlap)
    }
}
