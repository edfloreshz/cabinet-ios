//
//  FilterCard.swift
//  Cabinet
//
//  Created by Eduardo Flores on 15/02/26.
//
import SwiftUI
struct FilterCard: View {
	@State var filter: Filter
	@Binding var selectedDestination: NavigationDestination?
	
	var body: some View {
		Button {
			selectedDestination = NavigationDestination.filter(filter)
		} label: {
			VStack(alignment: .leading, spacing: 0) {
				HStack {
					Image(systemName: filter.icon)
						.font(.system(size: 28))
						.foregroundStyle(.white)
					
					Spacer()
					
					//					Text(filter.count.formatted())
					//						.font(.system(size: 32, weight: .bold))
					//						.foregroundStyle(.white)
				}
				.padding(.top, 20)
				.padding(.horizontal, 20)
				
				Spacer()
				
				Text(filter.rawValue.capitalized)
					.font(.system(size: 20, weight: .semibold))
					.foregroundStyle(.white)
					.padding(.horizontal, 20)
					.padding(.bottom, 20)
			}
			.frame(height: 120)
			.background(filter.color.gradient)
			.clipShape(RoundedRectangle(cornerRadius: 16))
		}
		.buttonStyle(.plain)
	}
}
#Preview {
	@Previewable @State var selectedDestination: NavigationDestination? = nil
	FilterCard(filter: .all, selectedDestination: $selectedDestination)
}
