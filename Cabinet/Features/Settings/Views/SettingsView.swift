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
		#if os(macOS)
			macOSSettings
		#else
			iOSSettings
		#endif
	}

	private var macOSSettings: some View {
		VStack(spacing: 0) {
			VStack {
				HStack(alignment: .center) {
					Text("Accent Color:")
						.font(.system(size: 13))

					Picker("", selection: $accent) {
						ForEach(ThemeColor.allCases, id: \.self) { colorOption in
							Text(colorOption.rawValue.capitalized)
								.font(.system(size: 13))
							.tag(colorOption)
						}
					}
					.pickerStyle(.menu)
					
					Circle()
						.fill(accent.color)
						.frame(width: 20, height: 20)
				}
				.padding()
			}
			
			Divider()
			
			HStack {
				Spacer()
				Button("Done") {
					dismiss()
				}
				.keyboardShortcut(.defaultAction)
			}
			.padding(.horizontal, 20)
			.padding(.vertical, 12)
			.background(.background)
		}
	}

	private var iOSSettings: some View {
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
