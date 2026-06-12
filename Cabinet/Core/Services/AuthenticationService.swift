//
//  AuthenticationService.swift
//  Cabinet
//
//  Created by Eduardo Flores on 25/01/26.
//

import LocalAuthentication
import os
import SwiftUI

class AuthenticationService {
	static let logger = Logger(
		subsystem: "dev.edfloreshz.Cabinet",
		category: "Authentication"
	)
	
	enum BiometryKind {
		case faceID
		case touchID
		case opticID
		case none
		
		var displayName: String {
			switch self {
			case .faceID: return "Face ID"
			case .touchID: return "Touch ID"
			case .opticID: return "Optic ID"
			case .none: return "Biometrics"
			}
		}
		
		var symbolName: String {
			switch self {
			case .faceID: return "faceid"
			case .touchID: return "touchid"
			case .opticID: return "opticid"
			case .none: return "lock.fill"
			}
		}
	}
	
	enum AuthenticationError: Error {
		case biometricsNotAvailable
		case authenticationFailed
		case unknown(Error)
		
		var message: String {
			switch self {
			case .biometricsNotAvailable:
				return "Biometric authentication is not available on this device"
			case .authenticationFailed:
				return "Authentication failed. Please try again"
			case .unknown(let error):
				return "Authentication error: \(error.localizedDescription)"
			}
		}
	}
	
	static func biometricsAvailable() -> Bool {
		let context = LAContext()
		var error: NSError?
		return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
	}
	
	static func biometryKind() -> BiometryKind {
		let context = LAContext()
		var error: NSError?
		guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
		else {
			return .none
		}
		
		switch context.biometryType {
		case .faceID:
			return .faceID
		case .touchID:
			return .touchID
		case .opticID:
			return .opticID
		case .none:
			return .none
		@unknown default:
			return .none
		}
	}
	
	static func authenticate(
		reason: String = "We need to unlock your data.",
		completion: @escaping (Result<Void, AuthenticationError>) -> Void
	) {
		let context = LAContext()
		var error: NSError?
		
		guard
			context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
		else {
			logger.error("Authentication not available")
			DispatchQueue.main.async {
				ToastManager.shared.show(
					"Authentication not available",
					type: .error
				)
				completion(.failure(.biometricsNotAvailable))
			}
			return
		}
		
		context.evaluatePolicy(
			.deviceOwnerAuthentication,
			localizedReason: reason
		) { success, authError in
			DispatchQueue.main.async {
				if success {
					completion(.success(()))
				} else {
					if let error = authError {
						completion(.failure(.unknown(error)))
					} else {
						completion(.failure(.authenticationFailed))
					}
				}
			}
		}
	}
}
