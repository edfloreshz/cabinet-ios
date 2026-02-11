//
//  Category.swift
//  Cabinet
//
//  Created by Eduardo Flores on 08/02/26.
//

import Foundation
import SwiftData

@Model
final class Category: Identifiable {
	@Attribute(.unique) var name: String
	var icon: String

	init(name: String, icon: String = "line.3.horizontal.decrease.circle") {
		self.name = name
		self.icon = icon
	}

	static var defaultCategories = [
		Category(name: "All", icon: "list.clipboard.fill"),
		Category(name: "Favorites", icon: "star.fill"),
	]
}
