//
//  LockedViewModel.swift
//  Cabinet
//
//  Created by Eduardo Flores on 09/06/26.
//
import SwiftUI

@Observable
class LockedViewModel {
	var isLocked = false
	var isAuthenticating = false
	var didAttemptInitialUnlock = false
	var backgroundedAt: Date?
	
	let biometryKind = AuthenticationService.biometryKind()
	
	var isLockingEnabled: Bool {
		biometricsEnabled && lockTimeout >= 0
	}
	
	var biometricsEnabled: Bool = false
	var lockTimeout: Int = -1
	
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
		
		if lockTimeout == 0 { return true }
		
		let elapsed = Date().timeIntervalSince(backgroundedAt)
		return elapsed >= TimeInterval(lockTimeout * 60)
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
		
		AuthenticationService.authenticate(reason: "Unlock Cabinet") { [weak self] result in
			guard let self else { return }
			isAuthenticating = false
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
