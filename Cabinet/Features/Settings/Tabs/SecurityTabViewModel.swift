//
//  SecurityTabViewModel.swift
//  Cabinet
//
//  Created by Eduardo Flores on 10/06/26.
//

import Observation
import SwiftUI

@Observable
@MainActor
final class SecurityTabViewModel {
	private let authenticationService: AuthenticationService.Type
	
	init(
		authenticationService: AuthenticationService.Type = AuthenticationService.self
	) {
		self.authenticationService = authenticationService
		
		if !biometricsAvailable {
			biometricsEnabled = false
			lockTimeout = -1
		}
	}
	
	// MARK: - Settings
	
	var biometricsEnabled: Bool {
		get {
			UserDefaults.standard.bool(forKey: "biometricsEnabled")
		}
		set {
			UserDefaults.standard.set(newValue, forKey: "biometricsEnabled")
		}
	}
	
	var lockTimeout: Int {
		get {
			let value = UserDefaults.standard.object(forKey: "lockTimeout") as? Int
			return value ?? -1
		}
		set {
			UserDefaults.standard.set(newValue, forKey: "lockTimeout")
		}
	}
	
	// MARK: - State
	
	private(set) var isProcessing = false
	
	// MARK: - Computed
	
	var biometricsAvailable: Bool {
		authenticationService.biometricsAvailable()
	}
	
	var biometryKind: AuthenticationService.BiometryKind {
		authenticationService.biometryKind()
	}
	
	// MARK: - Actions
	
	func setBiometricsEnabled(_ enabled: Bool) {
		guard !isProcessing else { return }
		guard biometricsEnabled != enabled else { return }
		
		isProcessing = true
		
		if enabled {
			enableBiometrics()
		} else {
			disableBiometrics()
		}
	}
	
	func updateLockTimeout(_ timeout: Int) {
		guard biometricsEnabled else {
			lockTimeout = -1
			return
		}
		
		lockTimeout = timeout
	}
	
	// MARK: - Private
	
	private func enableBiometrics() {
		guard biometricsAvailable else {
			ToastManager.shared.show(
				"\(biometryKind.displayName) is not available on this device.",
				type: .warning
			)
			
			isProcessing = false
			return
		}
		
		authenticationService.authenticate(
			reason: "Enable app lock for Cabinet"
		) { [weak self] result in
			guard let self else { return }
			
			Task { @MainActor in
				defer { self.isProcessing = false }
				
				guard case .success = result else {
					return
				}
				
				self.biometricsEnabled = true
				
				if self.lockTimeout < 0 {
					self.lockTimeout = 1
				}
				
				ToastManager.shared.show(
					"Biometrics enabled. App lock is now on.",
					type: .success
				)
			}
		}
	}
	
	private func disableBiometrics() {
		authenticationService.authenticate(
			reason: "Disable app lock for Cabinet"
		) { [weak self] result in
			guard let self else { return }
			
			Task { @MainActor in
				defer { self.isProcessing = false }
				
				guard case .success = result else {
					return
				}
				
				self.biometricsEnabled = false
				self.lockTimeout = -1
				
				ToastManager.shared.show(
					"Biometrics disabled. App lock is now off.",
					type: .info
				)
			}
		}
	}
}
