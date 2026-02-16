//
//  Authentication.swift
//  Cabinet
//
//  Created by Eduardo Flores on 25/01/26.
//

import LocalAuthentication
import SwiftUI
import os

class AuthenticationService {
	static let logger = Logger(
		subsystem: "dev.edfloreshz.Cabinet",
		category: "Authentication"
	)

	enum AuthenticationError: Error {
		case biometricsNotAvailable
		case authenticationFailed
		case unknown(Error)

		var message: String {
			switch self {
			case .biometricsNotAvailable:
				return
					"Biometric authentication is not available on this device"
			case .authenticationFailed:
				return "Authentication failed. Please try again"
			case .unknown(let error):
				return "Authentication error: \(error.localizedDescription)"
			}
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
					completion(.failure(.authenticationFailed))
				}
			}
		}
	}
}
