import SwiftUI

struct VoicePacksView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var audioService: AudioService
    @EnvironmentObject var hapticService: HapticService

    @StateObject private var settings = Settings.shared
    @State private var playingPackId: String?

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                SlapColors.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Text("Voice Packs")
                                .font(SlapFonts.title)
                                .foregroundStyle(SlapColors.text)

                            Text("Choose how your phone reacts")
                                .font(SlapFonts.bodyMedium)
                                .foregroundStyle(SlapColors.text.opacity(0.6))
                        }
                        .padding(.top, 20)

                        // Voice pack grid
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(VoicePack.allPacks) { pack in
                                VoicePackCard(
                                    pack: pack,
                                    isSelected: settings.selectedVoicePackId == pack.id,
                                    isPlaying: playingPackId == pack.id,
                                    onSelect: {
                                        selectPack(pack)
                                    },
                                    onPreview: {
                                        previewPack(pack)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)

                        // Current selection info
                        if let selectedPack = VoicePack.allPacks.first(where: { $0.id == settings.selectedVoicePackId }) {
                            VStack(spacing: 8) {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(SlapColors.success)
                                    Text("Currently using: \(selectedPack.name)")
                                        .font(SlapFonts.bodyMedium)
                                        .foregroundStyle(SlapColors.text)
                                }

                                Text("\(selectedPack.sounds.count) sounds included")
                                    .font(SlapFonts.caption)
                                    .foregroundStyle(SlapColors.text.opacity(0.5))
                            }
                            .padding(.top, 20)
                        }

                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(SlapColors.primary)
                }
            }
            .toolbarBackground(SlapColors.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    private func selectPack(_ pack: VoicePack) {
        settings.selectVoicePack(pack)
        hapticService.playButtonHaptic()
    }

    private func previewPack(_ pack: VoicePack) {
        playingPackId = pack.id
        audioService.previewVoicePack(pack)

        // Reset playing state after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if playingPackId == pack.id {
                playingPackId = nil
            }
        }
    }
}

struct VoicePackCard: View {
    let pack: VoicePack
    let isSelected: Bool
    let isPlaying: Bool
    let onSelect: () -> Void
    let onPreview: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isSelected ? SlapColors.primary.opacity(0.2) : SlapColors.text.opacity(0.1))
                        .frame(width: 70, height: 70)

                    Image(systemName: pack.icon)
                        .font(.system(size: 30, weight: .medium))
                        .foregroundStyle(isSelected ? SlapColors.primary : SlapColors.text.opacity(0.7))
                        .scaleEffect(isPlaying ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3), value: isPlaying)
                }

                // Name
                Text(pack.name)
                    .font(SlapFonts.bodyBold(size: 16))
                    .foregroundStyle(SlapColors.text)

                // Description
                Text(pack.description)
                    .font(SlapFonts.caption)
                    .foregroundStyle(SlapColors.text.opacity(0.5))
                    .lineLimit(1)

                // Sound count
                Text("\(pack.sounds.count) sounds")
                    .font(SlapFonts.caption)
                    .foregroundStyle(SlapColors.secondary)

                // Preview button
                Button(action: onPreview) {
                    HStack(spacing: 4) {
                        Image(systemName: isPlaying ? "speaker.wave.3.fill" : "play.fill")
                            .font(.system(size: 10))
                        Text("Preview")
                            .font(SlapFonts.caption)
                    }
                    .foregroundStyle(SlapColors.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(SlapColors.primary.opacity(0.15))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(SlapColors.text.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? SlapColors.primary : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview {
    VoicePacksView()
        .environmentObject(AudioService())
        .environmentObject(HapticService())
}
