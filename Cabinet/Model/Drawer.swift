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
	@Attribute(.unique) var id: UUID = UUID()
	var name: String
	var icon: String

	init(name: String, icon: String = "tag.fill") {
		self.name = name
		self.icon = icon
	}

	static let sampleData: [Drawer] = [
		Drawer(name: "School", icon: "graduationcap.fill"),
		Drawer(name: "Bank", icon: "dollarsign.bank.building.fill"),
	]
}
