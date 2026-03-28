//
//  VoicePackTests.swift
//  SlapPhoneTests
//
//  Unit tests for VoicePack and PlugSounds
//

import XCTest
@testable import SlapPhone

final class VoicePackTests: XCTestCase {

    // MARK: - VoicePack Static Instances Tests

    func testDefaultVoicePack() {
        let pack = VoicePack.default

        XCTAssertEqual(pack.id, "default")
        XCTAssertEqual(pack.name, "Default")
        XCTAssertEqual(pack.description, "Classic ouch reactions")
        XCTAssertEqual(pack.icon, "waveform")
        XCTAssertEqual(pack.sounds.count, 8)
        XCTAssertTrue(pack.sounds.contains("ow1"))
        XCTAssertTrue(pack.sounds.contains("ouch1"))
    }

    func testAngryVoicePack() {
        let pack = VoicePack.angry

        XCTAssertEqual(pack.id, "angry")
        XCTAssertEqual(pack.name, "Angry")
        XCTAssertEqual(pack.description, "Aggressive reactions")
        XCTAssertEqual(pack.icon, "flame.fill")
        XCTAssertEqual(pack.sounds.count, 8)
        XCTAssertTrue(pack.sounds.contains("angry1"))
        XCTAssertTrue(pack.sounds.contains("rage1"))
    }

    func testDramaticVoicePack() {
        let pack = VoicePack.dramatic

        XCTAssertEqual(pack.id, "dramatic")
        XCTAssertEqual(pack.name, "Dramatic")
        XCTAssertEqual(pack.description, "Over-the-top screams")
        XCTAssertEqual(pack.icon, "theatermasks.fill")
        XCTAssertEqual(pack.sounds.count, 8)
        XCTAssertTrue(pack.sounds.contains("scream1"))
        XCTAssertTrue(pack.sounds.contains("dramatic1"))
    }

    func testSillyVoicePack() {
        let pack = VoicePack.silly

        XCTAssertEqual(pack.id, "silly")
        XCTAssertEqual(pack.name, "Silly")
        XCTAssertEqual(pack.description, "Cartoon sounds")
        XCTAssertEqual(pack.icon, "face.smiling.fill")
        XCTAssertEqual(pack.sounds.count, 8)
        XCTAssertTrue(pack.sounds.contains("boing1"))
        XCTAssertTrue(pack.sounds.contains("squeak1"))
    }

    // MARK: - All Packs Tests

    func testAllPacks_ContainsAllVoicePacks() {
        let allPacks = VoicePack.allPacks

        XCTAssertEqual(allPacks.count, 4)
        XCTAssertTrue(allPacks.contains(VoicePack.default))
        XCTAssertTrue(allPacks.contains(VoicePack.angry))
        XCTAssertTrue(allPacks.contains(VoicePack.dramatic))
        XCTAssertTrue(allPacks.contains(VoicePack.silly))
    }

    func testAllPacks_UniqueIds() {
        let ids = VoicePack.allPacks.map { $0.id }
        let uniqueIds = Set(ids)

        XCTAssertEqual(ids.count, uniqueIds.count)
    }

    func testAllPacks_AllHave8Sounds() {
        for pack in VoicePack.allPacks {
            XCTAssertEqual(pack.sounds.count, 8, "\(pack.name) should have 8 sounds")
        }
    }

    // MARK: - Equatable Tests

    func testVoicePack_Equatable() {
        let pack1 = VoicePack.default
        let pack2 = VoicePack.default
        let pack3 = VoicePack.angry

        XCTAssertEqual(pack1, pack2)
        XCTAssertNotEqual(pack1, pack3)
    }

    // MARK: - Codable Tests

    func testVoicePack_EncodesAndDecodes() throws {
        let original = VoicePack.default
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let data = try encoder.encode(original)
        let decoded = try decoder.decode(VoicePack.self, from: data)

        XCTAssertEqual(original, decoded)
    }

    // MARK: - PlugSounds Tests

    func testPlugSounds_PlugIn() {
        XCTAssertEqual(PlugSounds.plugIn.count, 4)
        XCTAssertTrue(PlugSounds.plugIn.contains("moan1"))
        XCTAssertTrue(PlugSounds.plugIn.contains("ooh1"))
        XCTAssertTrue(PlugSounds.plugIn.contains("ahh1"))
        XCTAssertTrue(PlugSounds.plugIn.contains("sigh1"))
    }

    func testPlugSounds_PlugOut() {
        XCTAssertEqual(PlugSounds.plugOut.count, 4)
        XCTAssertTrue(PlugSounds.plugOut.contains("gasp1"))
        XCTAssertTrue(PlugSounds.plugOut.contains("oh1"))
        XCTAssertTrue(PlugSounds.plugOut.contains("huh1"))
        XCTAssertTrue(PlugSounds.plugOut.contains("hmm1"))
    }
}
