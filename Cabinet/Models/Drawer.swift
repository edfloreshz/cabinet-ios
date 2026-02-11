//
//  Drawer.swift
//  Cabinet
//
//  Created by Eduardo Flores on 08/02/26.
//

import Foundation
import SwiftData

@Model
final class Drawer: Identifiable {
	@Attribute(.unique) var name: String
	var icon: String

	init(name: String, icon: String = "tag.fill") {
		self.name = name
		self.icon = icon
	}

	static var defaultDrawers = [
		Drawer(name: "All", icon: "list.clipboard.fill"),
		Drawer(name: "Favorites", icon: "star.fill"),
	]

	static var sampleDrawers = [
		Drawer(name: "School", icon: "graduationcap.fill"),
		Drawer(name: "Bank", icon: "dollarsign.bank.building.fill"),
	]
}
