//
//  SnapshotHelper.swift
//  SlapPhoneUITests
//
//  Fastlane Snapshot Helper
//  Auto-generated - do not modify directly
//

import Foundation
import XCTest

var deviceLanguage = ""
var locale = ""

func setupSnapshot(_ app: XCUIApplication, waitForAnimations: Bool = true) {
    Snapshot.setupSnapshot(app, waitForAnimations: waitForAnimations)
}

func snapshot(_ name: String, waitForLoadingIndicator: Bool = true) {
    if waitForLoadingIndicator {
        Snapshot.snapshot(name, timeWaitingForIdle: 20)
    } else {
        Snapshot.snapshot(name)
    }
}

enum Snapshot {
    static var app: XCUIApplication?
    static var waitForAnimations = true
    static var cacheDirectory: URL?
    static var screenshotsDirectory: URL? {
        return cacheDirectory
    }

    static func setupSnapshot(_ app: XCUIApplication, waitForAnimations: Bool = true) {
        Snapshot.app = app
        Snapshot.waitForAnimations = waitForAnimations

        do {
            let cacheDir = try getCacheDirectory()
            Snapshot.cacheDirectory = cacheDir
            setLanguage(app)
            setLocale(app)
            setLaunchArguments(app)
        } catch {
            NSLog("Snapshot: Error setting up snapshot: \(error)")
        }
    }

    static func setLanguage(_ app: XCUIApplication) {
        guard let cacheDirectory = cacheDirectory else { return }

        let path = cacheDirectory.appendingPathComponent("language.txt")

        do {
            let trimCharacterSet = CharacterSet.whitespacesAndNewlines
            deviceLanguage = try String(contentsOf: path, encoding: .utf8).trimmingCharacters(in: trimCharacterSet)
            app.launchArguments += ["-AppleLanguages", "(\(deviceLanguage))"]
        } catch {
            NSLog("Snapshot: Couldn't find language.txt: \(error)")
        }
    }

    static func setLocale(_ app: XCUIApplication) {
        guard let cacheDirectory = cacheDirectory else { return }

        let path = cacheDirectory.appendingPathComponent("locale.txt")

        do {
            let trimCharacterSet = CharacterSet.whitespacesAndNewlines
            locale = try String(contentsOf: path, encoding: .utf8).trimmingCharacters(in: trimCharacterSet)
            app.launchArguments += ["-AppleLocale", "\"\(locale)\""]
        } catch {
            NSLog("Snapshot: Couldn't find locale.txt: \(error)")
        }
    }

    static func setLaunchArguments(_ app: XCUIApplication) {
        guard let cacheDirectory = cacheDirectory else { return }

        app.launchArguments += ["FASTLANE_SNAPSHOT", "YES"]
        app.launchArguments += ["-FASTLANE_SNAPSHOT_CACHE_DIR", cacheDirectory.path]
    }

    static func getCacheDirectory() throws -> URL {
        let cachePath = ProcessInfo.processInfo.environment["SIMULATOR_SHARED_RESOURCES_DIRECTORY"]
        guard let simulatorCachePath = cachePath else {
            throw SnapshotError.cannotFindCacheDirectory
        }
        return URL(fileURLWithPath: simulatorCachePath).appendingPathComponent("fastlane")
    }

    static func snapshot(_ name: String, timeWaitingForIdle timeout: TimeInterval = 20) {
        guard let app = app else {
            NSLog("Snapshot: App not set up. Call setupSnapshot first.")
            return
        }

        if waitForAnimations {
            sleep(1)
        }

        let screenshot = app.windows.firstMatch.screenshot()
        guard let cacheDirectory = cacheDirectory else { return }

        let path = cacheDirectory.appendingPathComponent("\(name).png")

        do {
            try screenshot.pngRepresentation.write(to: path)
            NSLog("Snapshot: Saved \(name).png")
        } catch {
            NSLog("Snapshot: Error saving screenshot: \(error)")
        }
    }
}

enum SnapshotError: Error, LocalizedError {
    case cannotFindCacheDirectory

    var errorDescription: String? {
        switch self {
        case .cannotFindCacheDirectory:
            return "Couldn't find cache directory"
        }
    }
}
