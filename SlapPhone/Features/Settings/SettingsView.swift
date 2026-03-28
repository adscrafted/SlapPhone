import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var settings = Settings.shared
    @EnvironmentObject var statisticsManager: StatisticsManager
    @EnvironmentObject var hapticService: HapticService

    @State private var showResetConfirmation = false

    var body: some View {
        NavigationStack {
            ZStack {
                SlapColors.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Sensitivity section
                        settingsSection(title: "Sensitivity") {
                            SensitivitySlider(
                                value: $settings.sensitivityLevel,
                                range: 1...10,
                                step: 1,
                                label: "Impact Sensitivity"
                            )
                        }

                        // Cooldown section
                        settingsSection(title: "Timing") {
                            CooldownSlider(value: $settings.cooldownDuration)
                        }

                        // Detection toggles
                        settingsSection(title: "Detection") {
                            VStack(spacing: 12) {
                                ToggleButton(
                                    icon: "hand.raised.fill",
                                    label: "Slap Detection",
                                    isOn: $settings.slapDetectionEnabled
                                )

                                ToggleButton(
                                    icon: "arrow.up.right",
                                    label: "Throw Detection",
                                    isOn: $settings.throwDetectionEnabled
                                )

                                ToggleButton(
                                    icon: "iphone.gen3.radiowaves.left.and.right",
                                    label: "Shake Detection",
                                    isOn: $settings.shakeDetectionEnabled
                                )

                                ToggleButton(
                                    icon: "bolt.fill",
                                    label: "USB Moaner",
                                    isOn: $settings.usbMoanerEnabled
                                )

                                ToggleButton(
                                    icon: "waveform",
                                    label: "Haptic Feedback",
                                    isOn: $settings.hapticFeedbackEnabled
                                )
                            }
                        }

                        // Statistics section
                        settingsSection(title: "Statistics") {
                            VStack(spacing: 16) {
                                statisticRow(
                                    label: "Total Impacts",
                                    value: "\(statisticsManager.totalImpacts)",
                                    icon: "number"
                                )

                                statisticRow(
                                    label: "Hardest Slap",
                                    value: statisticsManager.formattedHardestSlap(),
                                    icon: "bolt.fill"
                                )

                                statisticRow(
                                    label: "Plug Events",
                                    value: "\(statisticsManager.totalPlugEvents)",
                                    icon: "powerplug.fill"
                                )

                                Button {
                                    showResetConfirmation = true
                                } label: {
                                    HStack {
                                        Image(systemName: "trash")
                                        Text("Reset Statistics")
                                    }
                                    .font(SlapFonts.bodyMedium)
                                    .foregroundStyle(.red)
                                }
                                .padding(.top, 8)
                            }
                        }

                        // About section
                        settingsSection(title: "About") {
                            VStack(spacing: 12) {
                                aboutRow(label: "Version", value: "1.0.0")
                                aboutRow(label: "Build", value: "1")

                                Link(destination: URL(string: "https://example.com/privacy")!) {
                                    HStack {
                                        Text("Privacy Policy")
                                            .font(SlapFonts.bodyMedium)
                                        Spacer()
                                        Image(systemName: "arrow.up.right")
                                            .font(.caption)
                                    }
                                    .foregroundStyle(SlapColors.primary)
                                }
                                .padding(.top, 8)

                                Link(destination: URL(string: "https://example.com/terms")!) {
                                    HStack {
                                        Text("Terms of Service")
                                            .font(SlapFonts.bodyMedium)
                                        Spacer()
                                        Image(systemName: "arrow.up.right")
                                            .font(.caption)
                                    }
                                    .foregroundStyle(SlapColors.primary)
                                }
                            }
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Settings")
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
            .alert("Reset Statistics?", isPresented: $showResetConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    statisticsManager.resetStatistics()
                    hapticService.playSuccessHaptic()
                }
            } message: {
                Text("This will permanently delete all your statistics. This action cannot be undone.")
            }
        }
    }

    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title.uppercased())
                .font(SlapFonts.caption)
                .foregroundStyle(SlapColors.text.opacity(0.5))
                .tracking(2)

            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func statisticRow(label: String, value: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(SlapColors.primary)
                .frame(width: 24)

            Text(label)
                .font(SlapFonts.bodyMedium)
                .foregroundStyle(SlapColors.text)

            Spacer()

            Text(value)
                .font(SlapFonts.statNumber)
                .foregroundStyle(SlapColors.secondary)
        }
        .padding(.vertical, 4)
    }

    private func aboutRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(SlapFonts.bodyMedium)
                .foregroundStyle(SlapColors.text)

            Spacer()

            Text(value)
                .font(SlapFonts.bodyMedium)
                .foregroundStyle(SlapColors.text.opacity(0.6))
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(StatisticsManager())
        .environmentObject(HapticService())
}
