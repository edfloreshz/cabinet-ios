//
//  CategoriesListView.swift
//  Cabinet
//
//  Created by Eduardo Flores on 14/06/26.
//

import SwiftUI

struct CategoriesListView: View {
	var body: some View {
		Section("Categories") {
			ForEach(Filter.allCases) { filter in
				NavigationLink(value: Destination.filter(filter)) {
					HStack { filter.label }
				}
				.tag(Destination.filter(filter))
			}
		}

	}
}

#Preview {
	List {
		CategoriesListView()
	}
}
