//
//  PairFormData.swift
//  Cabinet
//
//  Created by Eduardo Flores on 11/06/26.
//

import Foundation

import Foundation

struct PairFormData: Equatable {
	var key: String
	var value: String
	var notes: String
	var icon: String
	var isHidden: Bool
	var drawers: [UUID]
	
	init(from pair: Pair) {
		self.key = pair.key
		self.value = pair.value
		self.notes = pair.notes
		self.icon = pair.icon
		self.isHidden = pair.isHidden
		self.drawers = pair.drawers
	}
	
	// Drawer order is not significant; compare as sets.
	static func == (lhs: PairFormData, rhs: PairFormData) -> Bool {
		lhs.key == rhs.key &&
		lhs.value == rhs.value &&
		lhs.notes == rhs.notes &&
		lhs.icon == rhs.icon &&
		lhs.isHidden == rhs.isHidden &&
		Set(lhs.drawers) == Set(rhs.drawers)
	}
}
