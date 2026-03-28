import Foundation
import AVFoundation
import Combine

class AudioService: ObservableObject {
    private var audioPlayers: [AVAudioPlayer] = []
    private let settings = Settings.shared
    private var cancellables = Set<AnyCancellable>()

    // Background audio support
    private var silentAudioPlayer: AVAudioPlayer?
    private var backgroundTimer: Timer?
    @Published var isBackgroundModeActive: Bool = false

    @Published var isPlaying: Bool = false

    init() {
        setupAudioSession()
        setupBackgroundAudio()
    }

    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            // Use .playback to allow background audio, .duckOthers to lower other audio
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers, .duckOthers])
            try session.setActive(true)

            // Handle interruptions (phone calls, etc.)
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleInterruption),
                name: AVAudioSession.interruptionNotification,
                object: session
            )
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }

    @objc private func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }

        switch type {
        case .began:
            // Interruption began - pause background audio
            silentAudioPlayer?.pause()
        case .ended:
            // Interruption ended - resume if we should be in background mode
            if isBackgroundModeActive {
                try? AVAudioSession.sharedInstance().setActive(true)
                silentAudioPlayer?.play()
            }
        @unknown default:
            break
        }
    }

    private func setupBackgroundAudio() {
        // Create a silent audio file for background keep-alive
        // We'll generate a very quiet tone that keeps the audio session active
        guard let silentURL = createSilentAudioFile() else { return }

        do {
            silentAudioPlayer = try AVAudioPlayer(contentsOf: silentURL)
            silentAudioPlayer?.numberOfLoops = -1 // Loop indefinitely
            silentAudioPlayer?.volume = 0.01 // Nearly silent
            silentAudioPlayer?.prepareToPlay()
        } catch {
            print("Failed to setup background audio: \(error)")
        }
    }

    private func createSilentAudioFile() -> URL? {
        // Use a sound file from the bundle as the "silent" background track
        // Play it at very low volume
        if let url = Bundle.main.url(forResource: "Sounds/default/ow1", withExtension: "m4a") {
            return url
        }
        return nil
    }

    func startBackgroundMode() {
        guard settings.backgroundModeEnabled else { return }
        isBackgroundModeActive = true
        silentAudioPlayer?.play()
    }

    func stopBackgroundMode() {
        isBackgroundModeActive = false
        silentAudioPlayer?.pause()
    }

    func playReaction(for impact: ImpactEvent) {
        let voicePack = settings.selectedVoicePack
        guard !voicePack.sounds.isEmpty else { return }

        // Pick a random sound from the pack
        let soundName = voicePack.sounds.randomElement() ?? voicePack.sounds[0]
        let soundPath = "Sounds/\(voicePack.id)/\(soundName)"

        playSound(named: soundPath, volume: volumeForImpact(impact))
    }

    func playPlugSound(isPlugIn: Bool) {
        guard settings.usbMoanerEnabled else { return }

        let sounds = isPlugIn ? PlugSounds.plugIn : PlugSounds.plugOut
        guard let soundName = sounds.randomElement() else { return }

        let soundPath = "Sounds/plug/\(soundName)"
        playSound(named: soundPath, volume: Float(settings.volume))
    }

    func previewVoicePack(_ pack: VoicePack) {
        guard let soundName = pack.sounds.first else { return }
        let soundPath = "Sounds/\(pack.id)/\(soundName)"
        playSound(named: soundPath, volume: Float(settings.volume))
    }

    private func playSound(named path: String, volume: Float) {
        // Try multiple extensions
        let extensions = ["m4a", "caf", "wav", "mp3"]

        for ext in extensions {
            if let url = Bundle.main.url(forResource: path, withExtension: ext) {
                playFromURL(url, volume: volume)
                return
            }
        }

        // Fallback: Generate a system sound for demo purposes
        playFallbackSound()
    }

    private func playFromURL(_ url: URL, volume: Float) {
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = volume * Float(settings.volume)
            player.prepareToPlay()
            player.play()

            // Keep reference and clean up when done
            audioPlayers.append(player)
            isPlaying = true

            // Clean up finished players
            DispatchQueue.main.asyncAfter(deadline: .now() + player.duration + 0.1) { [weak self] in
                self?.audioPlayers.removeAll { $0 == player }
                if self?.audioPlayers.isEmpty == true {
                    self?.isPlaying = false
                }
            }
        } catch {
            print("Failed to play sound: \(error)")
        }
    }

    private func playFallbackSound() {
        // Use system sound as fallback when audio files aren't available
        AudioServicesPlaySystemSound(1519) // Peek sound
        isPlaying = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.isPlaying = false
        }
    }

    private func volumeForImpact(_ impact: ImpactEvent) -> Float {
        // Scale volume based on impact magnitude
        // Minimum 0.5, maximum 1.0
        let normalizedMagnitude = min(impact.magnitude / 5.0, 1.0)
        return Float(0.5 + (normalizedMagnitude * 0.5))
    }

    func stopAll() {
        audioPlayers.forEach { $0.stop() }
        audioPlayers.removeAll()
        isPlaying = false
    }
}
