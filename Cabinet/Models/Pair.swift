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
	var value: String
	var isFavorite: Bool
	var isHidden: Bool
	var categories: [Category]
	var notes: String

	init(
		id: UUID = UUID(),
		key: String,
		value: String,
		isFavorite: Bool = false,
		isHidden: Bool = false,
		categories: [Category] = [],
		notes: String = ""
	) {
		self.id = id
		self.key = key
		self.value = value
		self.isFavorite = isFavorite
		self.isHidden = isHidden
		self.categories = categories
		self.notes = notes
	}

	static let sampleData = [
		Pair(key: "RFC", value: "DHRF990011Y3D", isFavorite: true),
		Pair(key: "Email", value: "eduardo@gmail.com"),
		Pair(
			key: "Bank Account",
			value: "12390520234",
			isHidden: true,
			categories: [
				Category(name: "Bank", icon: "dollarsign.bank.building.fill")
			]
		),
		Pair(
			key: "School ID",
			value: "12345435312",
			categories: [Category(name: "School", icon: "graduationcap.fill")]
		),
	]
}
