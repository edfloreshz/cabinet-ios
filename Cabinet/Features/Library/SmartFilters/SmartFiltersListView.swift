//
//  SmartFilters.swift
//  Cabinet
//
//  Created by Eduardo Flores on 11/06/26.
//

import SwiftUI

struct SmartFiltersListView: View {
	var body: some View {
		Section {
			ForEach(Filter.allCases) { filter in
				NavigationLink(value: Destination.filter(filter)) {
					HStack { filter.label }
				}
				.tag(Destination.filter(filter))
			}
		}
	}
}
