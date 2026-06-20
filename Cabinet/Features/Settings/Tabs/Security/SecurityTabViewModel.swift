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
final class SecuritySettingsStore {
	static let shared = SecuritySettingsStore()

	private enum Keys {
		static let biometricsEnabled = "biometricsEnabled"
		static let lockTimeout = "lockTimeout"
	}

	private let defaults: UserDefaults

	var biometricsEnabled: Bool {
		didSet {
			defaults.set(biometricsEnabled, forKey: Keys.biometricsEnabled)
		}
	}

	var lockTimeout: Int {
		didSet {
			defaults.set(lockTimeout, forKey: Keys.lockTimeout)
		}
	}

	var isLockingEnabled: Bool {
		biometricsEnabled && lockTimeout >= 0
	}

	init(defaults: UserDefaults = .standard) {
		self.defaults = defaults
		self.biometricsEnabled = defaults.bool(forKey: Keys.biometricsEnabled)
		self.lockTimeout = defaults.object(forKey: Keys.lockTimeout) as? Int ?? -1
	}

	func setBiometricsEnabled(_ enabled: Bool) {
		biometricsEnabled = enabled

		if !enabled {
			lockTimeout = -1
		} else if lockTimeout < 0 {
			lockTimeout = 1
		}
	}

	func setLockTimeout(_ timeout: Int) {
		lockTimeout = biometricsEnabled ? timeout : -1
	}
}

@Observable
@MainActor
final class SecurityTabViewModel {
	private let authenticationService: AuthenticationServicing
	private let settingsStore: SecuritySettingsStore
	
	init() {
		self.authenticationService = AuthenticationService.shared
		self.settingsStore = .shared

		if !biometricsAvailable {
			settingsStore.setBiometricsEnabled(false)
		}
	}

	init(
		authenticationService: AuthenticationServicing,
		settingsStore: SecuritySettingsStore
	) {
		self.authenticationService = authenticationService
		self.settingsStore = settingsStore
		
		if !biometricsAvailable {
			settingsStore.setBiometricsEnabled(false)
		}
	}
	
	// MARK: - Settings
	
	var biometricsEnabled: Bool {
		settingsStore.biometricsEnabled
	}
	
	var lockTimeout: Int {
		settingsStore.lockTimeout
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
		settingsStore.setLockTimeout(timeout)
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
				
				self.settingsStore.setBiometricsEnabled(true)
				
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
				
				self.settingsStore.setBiometricsEnabled(false)
				
				ToastManager.shared.show(
					"Biometrics disabled. App lock is now off.",
					type: .info
				)
			}
		}
	}
}
