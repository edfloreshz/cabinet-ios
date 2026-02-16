//
//  Pair.swift
//  Cabinet
//
//  Created by Eduardo Flores on 26/11/25.
//

import Foundation
import SwiftData

@Model
final class Pair {
	@Attribute(.unique) var id: UUID
	var key: String
	var icon: String
	var isFavorite: Bool
	var isHidden: Bool
	var drawers: [UUID]
	var notes: String
	var lastUsedDate: Date?
	var encryptedValue: Data

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

	init(
		id: UUID = UUID(),
		key: String,
		icon: String = "text.document",
		value: String,
		isFavorite: Bool = false,
		isHidden: Bool = false,
		drawers: [UUID] = [],
		notes: String = ""
	) {
		self.id = id
		self.key = key
		self.icon = icon
		self.isFavorite = isFavorite
		self.isHidden = isHidden
		self.drawers = drawers
		self.notes = notes
		self.lastUsedDate = nil
		self.encryptedValue = (try? CryptoService.encryptString(value)) ?? Data()
	}
	
	static let sampleData: [Pair] = [
		Pair(key: "RFC", value: "DHRF990011Y3D", isFavorite: true),
		Pair(key: "Email", value: "name@gmail.com"),
		Pair(
			key: "Bank Account",
			value: "12390520234",
			isHidden: true
		),
		Pair(
			key: "School ID",
			value: "12345435312"
		),
	]
}
