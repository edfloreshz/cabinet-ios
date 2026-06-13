//
//  Pair.swift
//  Cabinet
//
//  Created by Eduardo Flores on 26/11/25.
//

import Foundation
import SwiftData
import UIKit

@Model
final class Pair {
	@Attribute(.unique) var id: UUID
	var key: String
	var icon: String?
	var isFavorite: Bool
	var isHidden: Bool
	var drawers: [UUID]
	var notes: String
	var lastUsedDate: Date?
	var encryptedValue: Data
	var image: Data?

	var value: String {
		get {
			(try? CryptoService.decryptToString(encryptedValue)) ?? ""
		}
		set {
			if let data = try? CryptoService.encryptString(newValue) {
				encryptedValue = data
			}
		}
	}
	
	var backgroundImage: UIImage? {
		guard let data = image else { return nil }
		return UIImage(data: data)
	}

	init(
		id: UUID = UUID(),
		key: String,
		icon: String? = nil,
		value: String,
		isFavorite: Bool = false,
		isHidden: Bool = false,
		drawers: [UUID] = [],
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
		self.encryptedValue = (try? CryptoService.encryptString(value)) ?? Data()
		self.image = image
	}
}
