//
//  SettingsView.swift
//  Cabinet
//
//  Created by Eduardo Flores on 25/01/26.
//
import SwiftUI

struct SettingsView: View {
	var body: some View {
		TabView {
			AppearanceTabView()
				.tabItem {
					Label("Appearance", systemImage: "paintpalette.fill")
				}

			SecurityTabView()
				.tabItem {
					Label("Security", systemImage: "lock.fill")
				}
		}
	}
}

#Preview {
	Color.clear
		.sheet(isPresented: .constant(true)) {
			NavigationStack {
				SettingsView()
			}
			.presentationDetents([.large])
			.presentationDragIndicator(.visible)
		}
}
