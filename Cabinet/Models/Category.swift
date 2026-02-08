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
	
	init(name: String) {
		self.name = name
	}
	
	static var defaultCategories = [
		Category(name: "All"),
		Category(name: "Favorites")
	]
}
