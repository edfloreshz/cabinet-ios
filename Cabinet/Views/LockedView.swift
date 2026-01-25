//
//  LockedView.swift
//  Cabinet
//
//  Created by Eduardo Flores on 03/12/25.
//

import SwiftUI

struct LockedView : View {
	let authenticate: () -> Void
	var accentColor: Color
	
	var body: some View {
		VStack(spacing: 16) {
			Image(systemName: "lock.fill")
				.font(.system(size: 48, weight: .semibold))
				.foregroundStyle(.secondary)
				.accessibilityHidden(true)
			
			Text("Locked")
				.font(.title2).bold()
			
			Text("Unlock with Face ID / Touch ID to access your items.")
				.font(.callout)
				.foregroundStyle(.secondary)
				.multilineTextAlignment(.center)
				.padding(.horizontal)
			
			Button {
				authenticate()
			} label: {
				Label("Unlock", systemImage: "faceid")
					.font(.headline)
					.padding(.horizontal, 20)
					.padding(.vertical, 10)
			}
			.glassEffect()
			.tint(accentColor)
			.buttonStyle(.borderedProminent)
			
			Text("You can also unlock using your device passcode.")
				.font(.footnote)
				.foregroundStyle(.secondary)
				.multilineTextAlignment(.center)
				.padding(.top, 4)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.padding()
		.background(Color.clear)
	}
}

#Preview {
	LockedView(authenticate: {}, accentColor: .indigo)
}
