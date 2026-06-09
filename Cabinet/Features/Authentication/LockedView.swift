import SwiftUI

struct LockedView: View {
	@Environment(\.scenePhase) private var scenePhase
	@AppStorage("accentColor") private var accent: ThemeColor = .indigo
	@AppStorage("biometricsEnabled") private var biometricsEnabled: Bool = false
	@AppStorage("lockTimeout") private var lockTimeout: Int = -1
	
	@State private var backgroundedAt: Date?
	@State private var isLocked = false
	@State private var didAttemptInitialUnlock = false
	@State private var isAuthenticating = false
	private var biometryKind = AuthenticationService.biometryKind()
	
	var body: some View {
		ZStack {
			MasterView()
				.blur(radius: isLocked ? 18 : 0)
				.disabled(isLocked)
			
			if isLocked {
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
					
					Text("Unlock with \(biometryKind.displayName) or your passcode to access your items.")
						.font(.callout)
						.foregroundStyle(.secondary)
						.multilineTextAlignment(.center)
						.padding(.horizontal)
					
					Button {
						unlock()
					} label: {
						Label("Unlock", systemImage: biometryKind.symbolName)
							.font(.headline)
							.padding(.horizontal, 20)
							.padding(.vertical, 10)
					}
					.buttonStyle(.glassProminent)
					.tint(accent.color)
					.clipShape(.rect(cornerRadius: 20))
					
					if biometryKind != .none {
						Text("You can also unlock using your device passcode.")
							.font(.footnote)
							.foregroundStyle(.secondary)
							.multilineTextAlignment(.center)
							.padding(.top, 4)
					}
				}
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.padding()
				.background(Color.clear)
				.onAppear {
					unlock()
				}
				.transition(.opacity)
			}
		}
		.animation(.easeInOut(duration: 0.2), value: isLocked)
		.onAppear {
			applySecuritySettingsChange()
			attemptInitialUnlockIfNeeded()
		}
		.onChange(of: scenePhase) { _, newPhase in
			handleScenePhaseChange(newPhase)
		}
		.onChange(of: biometricsEnabled) { _, _ in
			applySecuritySettingsChange()
		}
		.onChange(of: lockTimeout) { _, _ in
			applySecuritySettingsChange()
		}
	}
	
	private var isLockingEnabled: Bool {
		biometricsEnabled && lockTimeout >= 0
	}
	
	private func handleScenePhaseChange(_ phase: ScenePhase) {
		switch phase {
		case .background:
			guard isLockingEnabled, !isAuthenticating else { return }
			backgroundedAt = Date()
			isLocked = true
		case .inactive:
			// Lock immediately on inactive, unless an auth prompt caused this transition.
			guard isLockingEnabled, !isAuthenticating else { return }
			backgroundedAt = Date()
			isLocked = true
		case .active:
			guard !isAuthenticating else { return }
			if shouldRequireLockOnForeground() {
				isLocked = true
			}
		default:
			break
		}
	}
	
	private func shouldRequireLockOnForeground() -> Bool {
		guard isLockingEnabled else { return false }
		guard let backgroundedAt else {
			return false
		}
		
		if lockTimeout == 0 {
			return true
		}
		
		let elapsed = Date().timeIntervalSince(backgroundedAt)
		return elapsed >= TimeInterval(lockTimeout * 60)
	}
	
	private func attemptInitialUnlockIfNeeded() {
		guard !didAttemptInitialUnlock else { return }
		didAttemptInitialUnlock = true
		
		guard isLockingEnabled else { return }
		isLocked = true
		unlock()
	}
	
	private func applySecuritySettingsChange() {
		if !isLockingEnabled {
			isLocked = false
			backgroundedAt = nil
		}
	}
	
	private func unlock() {
		guard !isAuthenticating else { return }
		isAuthenticating = true
		
		AuthenticationService.authenticate(reason: "Unlock Cabinet") { result in
			isAuthenticating = false
			switch result {
			case .success:
				withAnimation(.easeInOut(duration: 0.2)) {
					isLocked = false
				}
				backgroundedAt = nil
			case .failure:
				isLocked = true
			}
		}
	}
}

#Preview {
	LockedView()
}
