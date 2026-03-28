//
//  PaywallManagerTests.swift
//  SlapPhoneTests
//
//  Unit tests for PaywallManager
//  Note: Full StoreKit testing requires StoreKitTest configuration
//

import XCTest
@testable import SlapPhone

@MainActor
final class PaywallManagerTests: XCTestCase {

    var sut: PaywallManager!

    override func setUp() async throws {
        try await super.setUp()
        // Clear UserDefaults before each test
        UserDefaults.standard.removeObject(forKey: "isPurchased")
        sut = PaywallManager()
    }

    override func tearDown() async throws {
        sut = nil
        try await super.tearDown()
    }

    // MARK: - Product ID Tests

    func testProductID_IsCorrect() {
        XCTAssertEqual(PaywallManager.productID, "com.adscrafted.slapphone.fullversion")
    }

    // MARK: - Initial State Tests

    func testInitialState_NotPurchased() {
        XCTAssertFalse(sut.isPurchased)
    }

    func testInitialState_IdleState() {
        XCTAssertEqual(sut.purchaseState, .idle)
    }

    func testInitialState_NoError() {
        XCTAssertNil(sut.errorMessage)
    }

    // MARK: - PurchaseState Enum Tests

    func testPurchaseState_AllCases() {
        // Test that all states are distinct
        let states: [PaywallManager.PurchaseState] = [.idle, .loading, .purchasing, .purchased, .failed]

        for (index, state) in states.enumerated() {
            for (otherIndex, otherState) in states.enumerated() {
                if index == otherIndex {
                    XCTAssertTrue(compareStates(state, otherState))
                } else {
                    XCTAssertFalse(compareStates(state, otherState))
                }
            }
        }
    }

    // Helper to compare PurchaseState since it's not Equatable
    private func compareStates(_ lhs: PaywallManager.PurchaseState, _ rhs: PaywallManager.PurchaseState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle): return true
        case (.loading, .loading): return true
        case (.purchasing, .purchasing): return true
        case (.purchased, .purchased): return true
        case (.failed, .failed): return true
        default: return false
        }
    }

    #if DEBUG
    // MARK: - Debug Methods Tests (only available in DEBUG)

    func testSimulatePurchase_SetsPurchased() {
        sut.simulatePurchase()

        XCTAssertTrue(sut.isPurchased)
        XCTAssertTrue(compareStates(sut.purchaseState, .purchased))
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "isPurchased"))
    }

    func testResetPurchase_ClearsPurchased() {
        // First simulate a purchase
        sut.simulatePurchase()
        XCTAssertTrue(sut.isPurchased)

        // Then reset
        sut.resetPurchase()

        XCTAssertFalse(sut.isPurchased)
        XCTAssertTrue(compareStates(sut.purchaseState, .idle))
        XCTAssertFalse(UserDefaults.standard.bool(forKey: "isPurchased"))
    }

    func testSimulatePurchase_PersistsAcrossInstances() {
        sut.simulatePurchase()

        // Create new instance
        let newManager = PaywallManager()

        // Give it time to load
        let expectation = XCTestExpectation(description: "Load purchase state")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)

        XCTAssertTrue(newManager.isPurchased)
    }
    #endif

    // MARK: - Purchase Method Tests

    func testPurchase_WithNoProduct_SetsErrorMessage() async {
        // Product is nil by default (not loaded in test environment)
        await sut.purchase()

        XCTAssertEqual(sut.errorMessage, "Product not available")
    }
}
