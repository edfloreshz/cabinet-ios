//
//  LockedViewModel.swift
//  Cabinet
//
//  Created by Eduardo Flores on 09/06/26.
//
import SwiftUI

@Observable
@MainActor
final class LockedViewModel {
	private let authenticationService: AuthenticationServicing
	private let settingsStore: SecuritySettingsStore

	var isLocked = false
	var isAuthenticating = false
	var didAttemptInitialUnlock = false
	var backgroundedAt: Date?
	
	init() {
		self.authenticationService = AuthenticationService.shared
		self.settingsStore = .shared
	}

	init(
		authenticationService: AuthenticationServicing,
		settingsStore: SecuritySettingsStore
	) {
		self.authenticationService = authenticationService
		self.settingsStore = settingsStore
	}

	var biometryKind: AuthenticationService.BiometryKind {
		authenticationService.biometryKind()
	}
	
	var isLockingEnabled: Bool {
		settingsStore.isLockingEnabled
	}
	
	func handleScenePhaseChange(_ phase: ScenePhase) {
		switch phase {
		case .background, .inactive:
			guard isLockingEnabled, !isAuthenticating else { return }
			backgroundedAt = Date()
		case .active:
			guard !isAuthenticating else { return }
			if shouldRequireLockOnForeground() {
				isLocked = true
			}
		default:
			break
		}
	}
	
	func shouldRequireLockOnForeground() -> Bool {
		guard isLockingEnabled else { return false }
		guard let backgroundedAt else { return false }
		
		if settingsStore.lockTimeout == 0 { return true }
		
		let elapsed = Date().timeIntervalSince(backgroundedAt)
		return elapsed >= TimeInterval(settingsStore.lockTimeout * 60)
	}
	
	func attemptInitialUnlockIfNeeded() {
		guard !didAttemptInitialUnlock else { return }
		didAttemptInitialUnlock = true
		guard isLockingEnabled else { return }
		isLocked = true
		unlock()
	}
	
	func applySecuritySettingsChange() {
		if !isLockingEnabled {
			isLocked = false
			backgroundedAt = nil
		}
	}
	
	func unlock() {
		guard !isAuthenticating else { return }
		isAuthenticating = true
		
		authenticationService.authenticate(reason: "Unlock Cabinet") { [weak self] result in
			guard let self else { return }
			Task { @MainActor in
				self.isAuthenticating = false
				switch result {
				case .success:
					withAnimation(.easeInOut(duration: 0.2)) {
						self.isLocked = false
					}
					self.backgroundedAt = nil
				case .failure:
					self.isLocked = true
				}
			}
		}
	}
}
