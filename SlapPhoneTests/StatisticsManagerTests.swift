//
//  StatisticsManagerTests.swift
//  SlapPhoneTests
//
//  Unit tests for StatisticsManager
//

import XCTest
@testable import SlapPhone

final class StatisticsManagerTests: XCTestCase {

    var sut: StatisticsManager!

    override func setUp() {
        super.setUp()
        // Clear UserDefaults before each test
        UserDefaults.standard.removeObject(forKey: "lifetimeSlaps")
        UserDefaults.standard.removeObject(forKey: "lifetimeThrows")
        UserDefaults.standard.removeObject(forKey: "lifetimeShakes")
        UserDefaults.standard.removeObject(forKey: "hardestSlap")
        UserDefaults.standard.removeObject(forKey: "totalPlugEvents")

        sut = StatisticsManager()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialState_AllZeros() {
        XCTAssertEqual(sut.lifetimeSlaps, 0)
        XCTAssertEqual(sut.lifetimeThrows, 0)
        XCTAssertEqual(sut.lifetimeShakes, 0)
        XCTAssertEqual(sut.hardestSlap, 0)
        XCTAssertEqual(sut.totalPlugEvents, 0)
        XCTAssertTrue(sut.recentImpacts.isEmpty)
    }

    func testTotalImpacts_CalculatesCorrectly() {
        sut.lifetimeSlaps = 5
        sut.lifetimeThrows = 3
        sut.lifetimeShakes = 2

        XCTAssertEqual(sut.totalImpacts, 10)
    }

    // MARK: - Record Impact Tests

    func testRecordImpact_Slap_IncrementsCount() {
        let event = ImpactEvent(type: .slap, magnitude: 2.5)

        sut.recordImpact(event)

        XCTAssertEqual(sut.lifetimeSlaps, 1)
        XCTAssertEqual(sut.lifetimeThrows, 0)
        XCTAssertEqual(sut.lifetimeShakes, 0)
    }

    func testRecordImpact_Throw_IncrementsCount() {
        let event = ImpactEvent(type: .thrown, magnitude: 3.0)

        sut.recordImpact(event)

        XCTAssertEqual(sut.lifetimeSlaps, 0)
        XCTAssertEqual(sut.lifetimeThrows, 1)
        XCTAssertEqual(sut.lifetimeShakes, 0)
    }

    func testRecordImpact_Shake_IncrementsCount() {
        let event = ImpactEvent(type: .shake, magnitude: 1.5)

        sut.recordImpact(event)

        XCTAssertEqual(sut.lifetimeSlaps, 0)
        XCTAssertEqual(sut.lifetimeThrows, 0)
        XCTAssertEqual(sut.lifetimeShakes, 1)
    }

    func testRecordImpact_Slap_UpdatesHardestSlap() {
        let event1 = ImpactEvent(type: .slap, magnitude: 2.5)
        let event2 = ImpactEvent(type: .slap, magnitude: 5.0)
        let event3 = ImpactEvent(type: .slap, magnitude: 3.0)

        sut.recordImpact(event1)
        XCTAssertEqual(sut.hardestSlap, 2.5)

        sut.recordImpact(event2)
        XCTAssertEqual(sut.hardestSlap, 5.0)

        sut.recordImpact(event3)
        XCTAssertEqual(sut.hardestSlap, 5.0) // Should not decrease
    }

    func testRecordImpact_AddsToRecentImpacts() {
        let event = ImpactEvent(type: .slap, magnitude: 2.5)

        sut.recordImpact(event)

        XCTAssertEqual(sut.recentImpacts.count, 1)
        XCTAssertEqual(sut.recentImpacts.first?.type, .slap)
    }

    func testRecordImpact_RecentImpacts_LimitedTo10() {
        for i in 1...15 {
            let event = ImpactEvent(type: .slap, magnitude: Double(i))
            sut.recordImpact(event)
        }

        XCTAssertEqual(sut.recentImpacts.count, 10)
        // Most recent should be first (magnitude 15)
        XCTAssertEqual(sut.recentImpacts.first?.magnitude, 15.0)
    }

    // MARK: - Plug Event Tests

    func testRecordPlugEvent_IncrementsCount() {
        sut.recordPlugEvent()
        XCTAssertEqual(sut.totalPlugEvents, 1)

        sut.recordPlugEvent()
        XCTAssertEqual(sut.totalPlugEvents, 2)
    }

    // MARK: - Reset Tests

    func testResetStatistics_ClearsAll() {
        // Setup some data
        sut.lifetimeSlaps = 10
        sut.lifetimeThrows = 5
        sut.lifetimeShakes = 3
        sut.hardestSlap = 8.5
        sut.totalPlugEvents = 7
        sut.recordImpact(ImpactEvent(type: .slap, magnitude: 1.0))

        sut.resetStatistics()

        XCTAssertEqual(sut.lifetimeSlaps, 0)
        XCTAssertEqual(sut.lifetimeThrows, 0)
        XCTAssertEqual(sut.lifetimeShakes, 0)
        XCTAssertEqual(sut.hardestSlap, 0)
        XCTAssertEqual(sut.totalPlugEvents, 0)
        XCTAssertTrue(sut.recentImpacts.isEmpty)
    }

    // MARK: - Persistence Tests

    func testPersistence_SavesAndLoads() {
        sut.lifetimeSlaps = 100
        sut.lifetimeThrows = 50
        sut.lifetimeShakes = 25
        sut.hardestSlap = 9.8
        sut.totalPlugEvents = 12

        // Create new instance to test loading
        let newManager = StatisticsManager()

        XCTAssertEqual(newManager.lifetimeSlaps, 100)
        XCTAssertEqual(newManager.lifetimeThrows, 50)
        XCTAssertEqual(newManager.lifetimeShakes, 25)
        XCTAssertEqual(newManager.hardestSlap, 9.8)
        XCTAssertEqual(newManager.totalPlugEvents, 12)
    }

    // MARK: - Formatting Tests

    func testFormattedHardestSlap_FormatsCorrectly() {
        sut.hardestSlap = 5.678
        XCTAssertEqual(sut.formattedHardestSlap(), "5.7g")

        sut.hardestSlap = 10.0
        XCTAssertEqual(sut.formattedHardestSlap(), "10.0g")

        sut.hardestSlap = 0.0
        XCTAssertEqual(sut.formattedHardestSlap(), "0.0g")
    }
}
