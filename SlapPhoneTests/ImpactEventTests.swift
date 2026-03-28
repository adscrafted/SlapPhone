//
//  ImpactEventTests.swift
//  SlapPhoneTests
//
//  Unit tests for ImpactEvent and ImpactType
//

import XCTest
@testable import SlapPhone

final class ImpactEventTests: XCTestCase {

    // MARK: - ImpactEvent Tests

    func testImpactEvent_InitializesCorrectly() {
        let event = ImpactEvent(type: .slap, magnitude: 5.5)

        XCTAssertEqual(event.type, .slap)
        XCTAssertEqual(event.magnitude, 5.5)
        XCTAssertNotNil(event.id)
        XCTAssertNotNil(event.timestamp)
    }

    func testImpactEvent_TimestampIsRecent() {
        let before = Date()
        let event = ImpactEvent(type: .shake, magnitude: 2.0)
        let after = Date()

        XCTAssertGreaterThanOrEqual(event.timestamp, before)
        XCTAssertLessThanOrEqual(event.timestamp, after)
    }

    func testImpactEvent_UniqueIds() {
        let event1 = ImpactEvent(type: .slap, magnitude: 1.0)
        let event2 = ImpactEvent(type: .slap, magnitude: 1.0)

        XCTAssertNotEqual(event1.id, event2.id)
    }

    // MARK: - ImpactType Tests

    func testImpactType_AllCases() {
        let cases = ImpactType.allCases

        XCTAssertEqual(cases.count, 3)
        XCTAssertTrue(cases.contains(.slap))
        XCTAssertTrue(cases.contains(.shake))
        XCTAssertTrue(cases.contains(.thrown))
    }

    func testImpactType_DisplayNames() {
        XCTAssertEqual(ImpactType.slap.displayName, "Slap")
        XCTAssertEqual(ImpactType.shake.displayName, "Shake")
        XCTAssertEqual(ImpactType.thrown.displayName, "Throw")
    }

    func testImpactType_Icons() {
        XCTAssertEqual(ImpactType.slap.icon, "hand.raised.fill")
        XCTAssertEqual(ImpactType.shake.icon, "iphone.gen3.radiowaves.left.and.right")
        XCTAssertEqual(ImpactType.thrown.icon, "arrow.up.right")
    }

    func testImpactType_Colors() {
        XCTAssertEqual(ImpactType.slap.color, "FF2D92")
        XCTAssertEqual(ImpactType.shake.color, "FFE600")
        XCTAssertEqual(ImpactType.thrown.color, "7B2D8E")
    }

    func testImpactType_RawValues() {
        XCTAssertEqual(ImpactType.slap.rawValue, "slap")
        XCTAssertEqual(ImpactType.shake.rawValue, "shake")
        XCTAssertEqual(ImpactType.thrown.rawValue, "thrown")
    }
}
