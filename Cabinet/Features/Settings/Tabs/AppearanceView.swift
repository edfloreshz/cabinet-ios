//
//  AppearanceSettingsView.swift
//  Cabinet
//
//  Created by Eduardo Flores on 10/06/26.
//

import SwiftUI

struct AppearanceView: View {
	@AppStorage("accentColor")
	private var accent: ThemeColor = .indigo
	
	var body: some View {
		List {
			Section {
				HStack {
					Picker("Accent Color", selection: $accent) {
						ForEach(ThemeColor.allCases, id: \.self) { colorOption in
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
				Text("Theme")
#if os(iOS) || os(iPadOS) || os(visionOS)
					.padding(.top, 20)
#endif
			}
		}
	}
}

#Preview {
	AppearanceView()
}
