//
//  SlapPhoneUITests.swift
//  SlapPhoneUITests
//
//  UI Tests for App Store Screenshot Generation
//

import XCTest

final class SlapPhoneUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    /// Generate all App Store screenshots
    func testGenerateScreenshots() throws {
        // Wait for app to fully load
        sleep(2)

        // 1. Splash/Hero - Main screen
        snapshot("1_splash")

        // 2. Home Screen with impact visualizer
        // The app should auto-navigate to home after splash
        sleep(1)
        snapshot("2_home")

        // 3. Voice Packs - Tap voice pack selector
        let voicePackButton = app.buttons["waveform"]
        if voicePackButton.waitForExistence(timeout: 5) {
            voicePackButton.tap()
            sleep(1)
            snapshot("3_voicepacks")

            // Dismiss voice packs sheet
            app.swipeDown()
            sleep(1)
        }

        // 4. Settings - Tap settings button
        let settingsButton = app.buttons["gearshape.fill"]
        if settingsButton.waitForExistence(timeout: 5) {
            settingsButton.tap()
            sleep(1)
            snapshot("4_settings")

            // Dismiss settings sheet
            app.swipeDown()
            sleep(1)
        }

        // 5. Stats - Show lifetime statistics
        // Stats are visible on home screen, take a focused shot
        snapshot("5_stats")

        // 6. Impact moment - Simulate impact flash
        // This would require triggering an impact event
        // For screenshots, we'll capture the current state
        snapshot("6_impact")
    }

    /// Test individual screens for manual screenshot capture
    func testHomeScreen() throws {
        sleep(2)
        snapshot("home_screen")
    }

    func testVoicePacksScreen() throws {
        sleep(2)
        let voicePackButton = app.buttons["waveform"]
        if voicePackButton.waitForExistence(timeout: 5) {
            voicePackButton.tap()
            sleep(1)
            snapshot("voice_packs")
        }
    }

    func testSettingsScreen() throws {
        sleep(2)
        let settingsButton = app.buttons["gearshape.fill"]
        if settingsButton.waitForExistence(timeout: 5) {
            settingsButton.tap()
            sleep(1)
            snapshot("settings")
        }
    }
}
