//
//  AppearanceTabView.swift
//  Cabinet
//
//  Created by Eduardo Flores on 10/06/26.
//

import SwiftUI

struct AppearanceTabView: View {
	@AppStorage("accentColor")
	private var accent: AppColor = .indigo

	var body: some View {
		List {
			Section {
				HStack {
					Picker("Accent Color", selection: $accent) {
						ForEach(AppColor.allCases, id: \.self) { colorOption in
							Text(colorOption.rawValue.capitalized)
								.tag(colorOption)
						}
					}
					.pickerStyle(.menu)
					Spacer()
					Circle()
						.fill(accent.color)
						.frame(width: 14, height: 14)
				}
			} header: {
				Label("Appearance", systemImage: "paintpalette.fill")
			}
		}
		.listStyle(.insetGrouped)
		.scrollContentBackground(.hidden)
		.background(Color(uiColor: .systemGroupedBackground))
	}
}

#Preview {
	AppearanceTabView()
}
