//
//  SecurityTabView.swift
//  Cabinet
//
//  Created by Eduardo Flores on 10/06/26.
//

import SwiftUI

struct SecurityTabView: View {
	@State private var model = SecurityTabViewModel()
	
	private let lockOptions: [(label: LocalizedStringKey, value: Int)] = [
		("Immediately", 0),
		("1 Minute", 1),
		("5 Minutes", 5),
		("15 Minutes", 15),
		("Never", -1)
	]
	
	var body: some View {
		List {
			Section {
				Toggle(
					"Enable \(model.biometryKind.displayName)",
					isOn: Binding(
						get: { model.biometricsEnabled },
						set: { model.setBiometricsEnabled($0) }
					)
				)
				.disabled(
					!model.biometricsAvailable ||
					model.isProcessing
				)
				
				if !model.biometricsAvailable {
					Label(
						"Biometrics are not available on this device.",
						systemImage: "exclamationmark.triangle"
					)
					.font(.caption)
					.foregroundStyle(.secondary)
				}
			}  header: {
				Text("Biometrics")
#if !os(macOS)
					.padding(.top, 20)
#endif
			}
			
			Section("Auto-Lock") {
				Picker(
					"Lock After",
					selection: Binding(
						get: { model.lockTimeout },
						set: { model.updateLockTimeout($0) }
					)
				) {
					ForEach(lockOptions, id: \.value) { option in
						Text(option.label).tag(option.value)
					}
				}
				.pickerStyle(.menu)
				.disabled(!model.biometricsEnabled)
				
				if model.biometricsEnabled {
					Text("Choose how long Cabinet can stay in the background before requiring unlock.")
						.font(.caption)
						.foregroundStyle(.secondary)
				}
			}
		}
	}
}

#Preview {
	SecurityTabView()
}
