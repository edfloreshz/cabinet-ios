//
//  Settings.swift
//  Cabinet
//
//  Created by Eduardo Flores on 25/01/26.
//

import SwiftUI

struct SettingsView: View {
	@Environment(\.dismiss) private var dismiss
	@Binding var accentColorName: String
	
	let accentColors: [(name: String, color: Color)] = [
		("indigo", .indigo),
		("blue", .blue),
		("purple", .purple),
		("pink", .pink),
		("red", .red),
		("orange", .orange),
		("yellow", .yellow),
		("green", .green),
		("teal", .teal),
		("cyan", .cyan)
	]
	
	var body: some View {
		Form {
			Section {
				LazyVGrid(columns: [
					GridItem(.adaptive(minimum: 60), spacing: 16)
				], spacing: 16) {
					ForEach(accentColors, id: \.name) { colorOption in
						Button {
							withAnimation(.spring(duration: 0.3)) {
								accentColorName = colorOption.name
							}
						} label: {
							ZStack {
								Circle()
									.fill(colorOption.color.gradient)
									.frame(width: 60, height: 60)
								
								if accentColorName == colorOption.name {
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
#if os(iOS)
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
