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
			VStack(spacing: 20) {
				VStack(alignment: .leading, spacing: 8) {
					Text("Accent Color")
						.font(.system(size: 13, weight: .semibold))
						.foregroundStyle(.secondary)

					LazyVGrid(
						columns: Array(
							repeating: GridItem(.fixed(48), spacing: 12),
							count: 6
						),
						spacing: 12
					) {
						ForEach(ThemeColor.allCases, id: \.self) {
							colorOption in
							Button {
								withAnimation(.spring(duration: 0.3)) {
									accent = colorOption
								}
							} label: {
								ZStack {
									Circle()
										.fill(colorOption.color.gradient)
										.frame(width: 48, height: 48)

									if accent == colorOption {
										Circle()
											.strokeBorder(
												.white,
												lineWidth: 2.5
											)
											.frame(width: 48, height: 48)
											.shadow(
												color: .black.opacity(0.2),
												radius: 2,
												y: 1
											)

										Image(systemName: "checkmark")
											.font(
												.system(size: 14, weight: .bold)
											)
											.foregroundStyle(.white)
											.shadow(
												color: .black.opacity(0.3),
												radius: 1,
												y: 0.5
											)
									}
								}
							}
							.buttonStyle(.plain)
							.help(colorOption.rawValue.capitalized)
						}
					}
					.padding(12)
					.background(.background.opacity(0.5))
					.clipShape(RoundedRectangle(cornerRadius: 8))
					.overlay(
						RoundedRectangle(cornerRadius: 8)
							.stroke(Color.secondary.opacity(0.2), lineWidth: 1)
					)
				}
				.frame(maxWidth: 380)

				Spacer()
			}
			.padding(20)

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
		.frame(width: 420, height: 300)
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
