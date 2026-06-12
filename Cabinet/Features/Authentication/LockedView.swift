//
//  LockedView.swift
//  Cabinet
//
//  Created by Eduardo Flores on 09/06/26.
//
import SwiftUI

struct LockedView: View {
	@Environment(\.scenePhase) private var scenePhase
	@AppStorage("accentColor") private var accent: AppColor = .indigo
	@AppStorage("biometricsEnabled") private var biometricsEnabled: Bool = false
	@AppStorage("lockTimeout") private var lockTimeout: Int = -1
	
	@State private var model = LockedViewModel()
	
	var body: some View {
		ZStack {
			LibraryView()
				.blur(radius: model.isLocked ? 18 : 0)
				.disabled(model.isLocked)
			
			if model.isLocked {
				Rectangle()
					.fill(.ultraThinMaterial)
					.ignoresSafeArea()
					.transition(.opacity)
				
				VStack(spacing: 16) {
					Image(systemName: "lock.fill")
						.font(.system(size: 48, weight: .semibold))
						.foregroundStyle(.secondary)
						.accessibilityHidden(true)
					
					Text("Locked")
						.font(.title2).bold()
					
					Text("Unlock with \(model.biometryKind.displayName) or your passcode to access your items.")
						.font(.callout)
						.foregroundStyle(.secondary)
						.multilineTextAlignment(.center)
						.padding(.horizontal)
					
					Button {
						model.unlock()
					} label: {
						Label("Unlock", systemImage: model.biometryKind.symbolName)
							.font(.headline)
							.padding(.horizontal, 20)
							.padding(.vertical, 10)
					}
					.buttonStyle(.glassProminent)
					.tint(accent.color)
					.clipShape(.rect(cornerRadius: 20))
					
					if model.biometryKind != .none {
						Text("You can also unlock using your device passcode.")
							.font(.footnote)
							.foregroundStyle(.secondary)
							.multilineTextAlignment(.center)
							.padding(.top, 4)
					}
				}
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.padding()
				.transition(.opacity)
			}
		}
		.animation(.easeInOut(duration: 0.2), value: model.isLocked)
		.onAppear {
			model.biometricsEnabled = biometricsEnabled
			model.lockTimeout = lockTimeout
			model.applySecuritySettingsChange()
			model.attemptInitialUnlockIfNeeded()
		}
		.onChange(of: scenePhase) { _, newPhase in
			model.handleScenePhaseChange(newPhase)
		}
		.onChange(of: biometricsEnabled) { _, newValue in
			model.biometricsEnabled = newValue
			model.applySecuritySettingsChange()
		}
		.onChange(of: lockTimeout) { _, newValue in
			model.lockTimeout = newValue
			model.applySecuritySettingsChange()
		}
	}
}

#Preview {
	let defaults = UserDefaults(suiteName: "preview")!
	defaults.set(true, forKey: "biometricsEnabled")
	defaults.set(0, forKey: "lockTimeout")
	return LockedView()
		.defaultAppStorage(defaults)
}
