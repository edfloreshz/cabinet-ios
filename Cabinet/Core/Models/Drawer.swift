//
//  Drawer.swift
//  Cabinet
//
//  Created by Eduardo Flores on 08/02/26.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Drawer: Identifiable {
	@Attribute(.unique) var id: UUID = UUID()
	var name: String
	var icon: String
	var purpose: String

	init(name: String, icon: String = "archivebox", purpose: String = "") {
		self.name = name
		self.icon = icon
		self.purpose = purpose
	}

	static let sampleData: [Drawer] = [
		Drawer(name: "School", icon: "graduationcap.fill", purpose: "School stuff"),
		Drawer(name: "Bank", icon: "dollarsign.bank.building.fill", purpose: "Bank stuff"),
	]
}
