//
//  Settings.swift
//  Cabinet
//
//  Created by Eduardo Flores on 25/01/26.
//

import SwiftUI

struct SettingsView: View {
	@Environment(\.dismiss) private var dismiss
	@AppStorage("accentColor") private var accent: ThemeColor = .indigo

	var body: some View {
		Form {
			Section {
				LazyVGrid(
					columns: [GridItem(.adaptive(minimum: 60), spacing: 16)],
					spacing: 16
				) {
					ForEach(ThemeColor.allCases, id: \.self) { colorOption in
						Button {
							withAnimation(.spring(duration: 0.3)) {
								accent = colorOption
							}
						} label: {
							ZStack {
								Circle()
									.fill(colorOption.color.gradient)
									.frame(width: 60, height: 60)

								if accent == colorOption {
									Circle()
										.strokeBorder(.white, lineWidth: 3)
										.frame(width: 60, height: 60)

									Image(systemName: "checkmark")
										.font(.title3.bold())
										.foregroundStyle(.white)
								}
							}
						}
						.buttonStyle(.plain)
					}
				}
				.padding(.vertical, 8)
			} header: {
				Text("Accent Color")
			}
		}
		.navigationTitle("Settings")
		#if os(iOS) || os(iPadOS) || os(visionOS)
			.navigationBarTitleDisplayMode(.inline)
		#endif
		.toolbar {
			ToolbarItem(placement: .confirmationAction) {
				Button("Done") {
					dismiss()
				}
			}
		}
	}
}

#Preview {
	SettingsView()
}
