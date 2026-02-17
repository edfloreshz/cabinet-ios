//
//  Settings.swift
//  Cabinet
//
//  Created by Eduardo Flores on 25/01/26.
//
import SwiftUI

struct SettingsView: View {
	@Environment(\.dismiss) private var dismiss
	@AppStorage("accentColor") private var accent: ThemeColor = .indigo
	@AppStorage("biometricsEnabled") private var biometricsEnabled: Bool = false
	@AppStorage("lockTimeout") private var lockTimeout: Int = -1
	@AppStorage("requirePasswordOnWake") private var requirePasswordOnWake:
		Bool = true

	var biometricsAvailable: Bool {
		AuthenticationService.biometricsAvailable()
	}

	var body: some View {
		#if os(macOS)
			macOSSettings
		#else
			iOSSettings
		#endif
	}

	private var macOSSettings: some View {
		TabView {
			Tab("Appearance", systemImage: "paintpalette.fill") {
				Form {
					Section("Theme") {
						HStack {
							Picker("Accent Color", selection: $accent) {
								ForEach(ThemeColor.allCases, id: \.self) {
									colorOption in
									Text(colorOption.rawValue.capitalized)
										.tag(colorOption)
								}
							}
							.pickerStyle(.menu)

							Circle()
								.fill(accent.color)
								.frame(width: 14, height: 14)
						}
					}
				}
				.formStyle(.grouped)
				.frame(width: 360)
			}

			Tab("Security", systemImage: "lock.fill") {
				Form {
					Section("Biometrics") {
						Toggle("Enable Biometrics", isOn: $biometricsEnabled)
							.disabled(!biometricsAvailable)

						if !biometricsAvailable {
							Label(
								"Biometrics are not available on this device.",
								systemImage: "exclamationmark.triangle"
							)
							.font(.caption)
							.foregroundStyle(.secondary)
						}
					}

					Section("Auto-Lock") {
						Picker("Lock After", selection: $lockTimeout) {
							Text("Immediately").tag(0)
							Text("1 Minute").tag(1)
							Text("5 Minutes").tag(5)
							Text("Never").tag(-1)
						}
						.pickerStyle(.menu)

						Toggle(
							"Require Password on Wake",
							isOn: $requirePasswordOnWake
						)
					}
				}
				.formStyle(.grouped)
				.frame(width: 360)
			}
		}
	}

	private var iOSSettings: some View {
		NavigationStack {
			Form {
				Section("Theme") {
					HStack {
						Picker("Accent Color", selection: $accent) {
							ForEach(ThemeColor.allCases, id: \.self) {
								colorOption in
								Text(colorOption.rawValue.capitalized)
									.tag(colorOption)
							}
						}
						.pickerStyle(.menu)
						Circle()
							.fill(accent.color)
							.frame(width: 14, height: 14)
					}
				}

				Section("Biometrics") {
					Toggle("Enable Biometrics", isOn: $biometricsEnabled)
						.disabled(!biometricsAvailable)
					if !biometricsAvailable {
						Label(
							"Biometrics are not available on this device.",
							systemImage: "exclamationmark.triangle"
						)
						.font(.caption)
						.foregroundStyle(.secondary)
					}
				}

				Section("Auto-Lock") {
					Picker("Lock After", selection: $lockTimeout) {
						Text("Immediately").tag(0)
						Text("1 Minute").tag(1)
						Text("5 Minutes").tag(5)
						Text("Never").tag(-1)
					}
					Toggle(
						"Require Password on Wake",
						isOn: $requirePasswordOnWake
					)
				}
			}
			.navigationTitle("Settings")
			#if os(iOS) || os(iPadOS) || os(visionOS)
				.navigationBarTitleDisplayMode(.inline)
			#endif
		}
	}
}

#Preview {
	SettingsView()
}
