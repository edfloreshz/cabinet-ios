//
//  FilterCard.swift
//  Cabinet
//
//  Created by Eduardo Flores on 15/02/26.
//

import SwiftUI

struct CategoryCard: View {
	@State var category: Category
	
    var body: some View {
		NavigationLink(value: Drawer(name: category.title)) {
			VStack(alignment: .leading, spacing: 0) {
				HStack {
					Image(systemName: category.icon)
						.font(.system(size: 28))
						.foregroundStyle(.white)
					
					Spacer()
					
					Text(category.count.formatted())
						.font(.system(size: 32, weight: .bold))
						.foregroundStyle(.white)
				}
				.padding(.top, 20)
				.padding(.horizontal, 20)
				
				Spacer()
				
				Text(category.title.capitalized)
					.font(.system(size: 20, weight: .semibold))
					.foregroundStyle(.white)
					.padding(.horizontal, 20)
					.padding(.bottom, 20)
			}
			.frame(height: 120)
			.background(category.color.gradient)
			.clipShape(RoundedRectangle(cornerRadius: 16))
		}
    }
}

#Preview {
	CategoryCard(category: Category(title: "All", icon: "list.clipboard.fill", color: .blue, count: 10))
}
