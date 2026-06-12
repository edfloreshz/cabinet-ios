//
//  DrawerFormData.swift
//  Cabinet
//
//  Created by Eduardo Flores on 11/06/26.
//

import Foundation

struct DrawerFormData: Equatable {
	var name: String
	var icon: String
	var purpose: String

	init(from drawer: Drawer) {
		self.name = drawer.name
		self.icon = drawer.icon
		self.purpose = drawer.purpose
	}
}
