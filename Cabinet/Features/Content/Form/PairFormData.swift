//
//  PairFormData.swift
//  Cabinet
//
//  Created by Eduardo Flores on 11/06/26.
//

import Foundation

struct PairFormData: Equatable {
	var key: String
	var value: String
	var notes: String
	var icon: String
	var isHidden: Bool
	var drawerIDs: Set<UUID>
	var image: Data?
	var secretLoadErrorMessage: String?

	init(pair: Pair?, initialDrawers: [Drawer] = []) {
		self.key = pair?.key ?? ""
		self.notes = pair?.notes ?? ""
		self.icon = pair?.icon ?? ""
		self.isHidden = pair?.isHidden ?? false
		self.drawerIDs = Set((pair?.drawers ?? initialDrawers).map(\.id))
		self.image = pair?.image

		if let pair {
			do {
				self.value = try pair.secretValue()
				self.secretLoadErrorMessage = nil
			} catch {
				self.value = ""
				self.secretLoadErrorMessage = error.localizedDescription
			}
		} else {
			self.value = ""
			self.secretLoadErrorMessage = nil
		}
	}
	
	static func == (lhs: PairFormData, rhs: PairFormData) -> Bool {
		lhs.key == rhs.key &&
		lhs.value == rhs.value &&
		lhs.notes == rhs.notes &&
		lhs.icon == rhs.icon &&
		lhs.isHidden == rhs.isHidden &&
		lhs.drawerIDs == rhs.drawerIDs &&
		lhs.image == rhs.image
	}
}
