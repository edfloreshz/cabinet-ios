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
	@State private var isAdjustingBiometrics = false
	
	var biometricsAvailable: Bool {
		AuthenticationService.biometricsAvailable()
	}
	
	var biometryKind: AuthenticationService.BiometryKind {
		AuthenticationService.biometryKind()
	}
	
	private let lockOptions: [(label: LocalizedStringKey, value: Int)] = [
		("Immediately", 0),
		("1 Minute", 1),
		("5 Minutes", 5),
		("15 Minutes", 15),
		("Never", -1)
	]
	
	var body: some View {
		Group {
#if os(macOS)
			macOSSettings
#else
			iOSSettings
#endif
		}
		.onAppear {
			if !biometricsAvailable {
				biometricsEnabled = false
				lockTimeout = -1
			}
		}
		.onChange(of: biometricsEnabled) { oldValue, newValue in
			handleBiometricsToggle(oldValue: oldValue, newValue: newValue)
		}
		.onChange(of: lockTimeout) { _, newValue in
			handleLockTimeoutChange(newValue)
		}
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
						Toggle("Enable \(biometryKind.displayName)", isOn: $biometricsEnabled)
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
							ForEach(lockOptions, id: \.value) { option in
								Text(option.label).tag(option.value)
							}
						}
						.pickerStyle(.menu)
						.disabled(!biometricsEnabled)
						
						if biometricsEnabled {
							Text("Choose how long Cabinet can stay in the background before requiring unlock.")
								.font(.caption)
								.foregroundStyle(.secondary)
						}
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
					Toggle("Enable \(biometryKind.displayName)", isOn: $biometricsEnabled)
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
						ForEach(lockOptions, id: \.value) { option in
							Text(option.label).tag(option.value)
						}
					}
					.disabled(!biometricsEnabled)
					
					if biometricsEnabled {
						Text("Choose how long Cabinet can stay in the background before requiring unlock.")
							.font(.caption)
							.foregroundStyle(.secondary)
					}
				}
			}
			.navigationTitle("Settings")
#if os(iOS) || os(iPadOS) || os(visionOS)
			.navigationBarTitleDisplayMode(.inline)
#endif
		}
	}
	
	private func handleBiometricsToggle(oldValue: Bool, newValue: Bool) {
		guard !isAdjustingBiometrics, oldValue != newValue else { return }
		
		if !newValue {
			lockTimeout = -1
			return
		}
		
		guard biometricsAvailable else {
			isAdjustingBiometrics = true
			biometricsEnabled = false
			isAdjustingBiometrics = false
			lockTimeout = -1
			ToastManager.shared.show(
				"\(biometryKind.displayName) is not available on this device.",
				type: .warning
			)
			return
		}
		
		AuthenticationService.authenticate(reason: "Enable app lock for Cabinet") { result in
			switch result {
			case .success:
				if lockTimeout < 0 {
					lockTimeout = 1
				}
			case .failure:
				isAdjustingBiometrics = true
				biometricsEnabled = false
				isAdjustingBiometrics = false
				lockTimeout = -1
				ToastManager.shared.show(
					"Could not enable app lock.",
					type: .error
				)
			}
		}
	}
	
	private func handleLockTimeoutChange(_ value: Int) {
		if !biometricsEnabled && value >= 0 {
			lockTimeout = -1
		}
	}
}

#Preview {
	SettingsView()
}
