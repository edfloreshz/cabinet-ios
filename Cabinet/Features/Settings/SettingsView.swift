//
//  Settings.swift
//  Cabinet
//
//  Created by Eduardo Flores on 25/01/26.
//
import SwiftUI

import SwiftUI

struct SettingsView: View {
	var body: some View {
		TabView {
			AppearanceView()
				.tabItem {
					Label("Appearance", systemImage: "paintpalette.fill")
				}
			
			BiometricsView()
				.tabItem {
					Label("Security", systemImage: "lock.fill")
				}
		}
#if os(macOS)
		.frame(maxWidth: 500)
#endif
	}
}

#Preview {
	SettingsView()
}
