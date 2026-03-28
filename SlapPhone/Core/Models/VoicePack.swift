import Foundation

struct VoicePack: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let description: String
    let icon: String  // SF Symbol name
    let sounds: [String]  // Sound file names without extension

    static let `default` = VoicePack(
        id: "default",
        name: "Default",
        description: "Classic ouch reactions",
        icon: "waveform",
        sounds: ["ow1", "ow2", "ouch1", "ouch2", "oof1", "grunt1", "argh1", "hey1"]
    )

    static let angry = VoicePack(
        id: "angry",
        name: "Angry",
        description: "Aggressive reactions",
        icon: "flame.fill",
        sounds: ["angry1", "angry2", "rage1", "rage2", "growl1", "yell1", "grr1", "what1"]
    )

    static let dramatic = VoicePack(
        id: "dramatic",
        name: "Dramatic",
        description: "Over-the-top screams",
        icon: "theatermasks.fill",
        sounds: ["scream1", "scream2", "dramatic1", "dramatic2", "wail1", "cry1", "nooo1", "whyyy1"]
    )

    static let silly = VoicePack(
        id: "silly",
        name: "Silly",
        description: "Cartoon sounds",
        icon: "face.smiling.fill",
        sounds: ["boing1", "boing2", "squeak1", "squeak2", "honk1", "pop1", "splat1", "spring1"]
    )

    static let allPacks: [VoicePack] = [.default, .angry, .dramatic, .silly]
}

// USB/Plug specific sounds
struct PlugSounds {
    static let plugIn = ["moan1", "ooh1", "ahh1", "sigh1"]
    static let plugOut = ["gasp1", "oh1", "huh1", "hmm1"]
}
