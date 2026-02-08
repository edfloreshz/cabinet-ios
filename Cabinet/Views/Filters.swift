//
//  Filters.swift
//  Cabinet
//
//  Created by Eduardo Flores on 08/02/26.
//

import SwiftUI
import SwiftData

struct Filters: View {
	@Query private var categories: [Category]
	@State private var selectedCategory: String = "All"
	var accentColor: Color
	var onSelect: (String) -> Void
	
	private var allCategories: [Category] {
		Category.defaultCategories + categories
	}
	
	var body: some View {
		ScrollView(.horizontal, showsIndicators: false) {
			HStack(spacing: 8) {
				ForEach(allCategories, id: \.name) { category in
					let isSelected = category.name == selectedCategory
					Button {
						withAnimation(.snappy) {
							selectedCategory = category.name
							onSelect(category.name)
						}
					} label: {
						Text(category.name.capitalized)
							.font(.callout)
							.padding(.vertical, 8)
							.padding(.horizontal, 14)
							.background(
								Capsule().fill(isSelected ? accentColor : Color.clear)
							)
							.foregroundStyle(isSelected ? Color.white : Color.primary)
					}
					.glassEffect(.clear)
					.accessibilityLabel(Text("Category \(category.name.capitalized)"))
					.accessibilityAddTraits(isSelected ? .isSelected : [])
				}.padding(1)
			}
			.padding(.horizontal)
			.padding(.top, 10)
		}
	}
}
