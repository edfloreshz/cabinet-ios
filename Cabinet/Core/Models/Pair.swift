//
//  Pair.swift
//  Cabinet
//
//  Created by Eduardo Flores on 26/11/25.
//

import Foundation
import os
import SwiftData
import UIKit

enum PairSecretAccessError: LocalizedError {
	case decryptionFailed
	case encryptionFailed

	var errorDescription: String? {
		switch self {
		case .decryptionFailed:
			return "The stored secret could not be decrypted."
		case .encryptionFailed:
			return "The secret could not be encrypted."
		}
	}
}

@Model
final class Pair {
	private static let logger = Logger(
		subsystem: "dev.edfloreshz.Cabinet",
		category: "Pair"
	)

	@Attribute(.unique) var id: UUID
	var key: String
	var icon: String?
	var isFavorite: Bool
	var isHidden: Bool
	@Relationship var drawers: [Drawer]
	var notes: String
	var lastUsedDate: Date?
	var encryptedValue: Data
	var image: Data?
	
	var backgroundImage: UIImage? {
		guard let data = image else { return nil }
		return UIImage(data: data)
	}

	init(
		id: UUID = UUID(),
		key: String,
		icon: String? = nil,
		encryptedValue: Data,
		isFavorite: Bool = false,
		isHidden: Bool = false,
		drawers: [Drawer] = [],
		lastUsedDate: Date? = nil,
		notes: String = "",
		image: Data? = nil
	) {
		self.id = id
		self.key = key
		self.icon = icon
		self.isFavorite = isFavorite
		self.isHidden = isHidden
		self.drawers = drawers
		self.notes = notes
		self.lastUsedDate = lastUsedDate
		self.encryptedValue = encryptedValue
		self.image = image
	}

	static func create(
		id: UUID = UUID(),
		key: String,
		icon: String? = nil,
		value: String,
		isFavorite: Bool = false,
		isHidden: Bool = false,
		drawers: [Drawer] = [],
		lastUsedDate: Date? = nil,
		notes: String = "",
		image: Data? = nil
	) throws -> Pair {
		let encryptedValue: Data

		do {
			encryptedValue = try CryptoService.encryptString(value)
		} catch {
			logger.error("Failed to encrypt pair value for '\(key, privacy: .public)'")
			throw PairSecretAccessError.encryptionFailed
		}

		return Pair(
			id: id,
			key: key,
			icon: icon,
			encryptedValue: encryptedValue,
			isFavorite: isFavorite,
			isHidden: isHidden,
			drawers: drawers,
			lastUsedDate: lastUsedDate,
			notes: notes,
			image: image
		)
	}

	func secretValue() throws -> String {
		do {
			return try CryptoService.decryptToString(encryptedValue)
		} catch {
			Self.logger.error("Failed to decrypt pair value for '\(self.key, privacy: .public)'")
			throw PairSecretAccessError.decryptionFailed
		}
	}

	func updateSecretValue(_ newValue: String) throws {
		do {
			encryptedValue = try CryptoService.encryptString(newValue)
		} catch {
			Self.logger.error("Failed to encrypt updated pair value for '\(self.key, privacy: .public)'")
			throw PairSecretAccessError.encryptionFailed
		}
	}
}
