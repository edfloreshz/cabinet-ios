//
//  SettingsView.swift
//  Cabinet
//
//  Created by Eduardo Flores on 25/01/26.
//
import SwiftUI

private enum SettingsTab: String, CaseIterable, Identifiable {
	case appearance
	case security

	var id: Self { self }

	var title: String {
		switch self {
		case .appearance:
			return "Appearance"
		case .security:
			return "Security"
		}
	}

	var systemImage: String {
		switch self {
		case .appearance:
			return "paintpalette.fill"
		case .security:
			return "lock.fill"
		}
	}
}

struct SettingsView: View {
	@State private var selectedTab: SettingsTab = .appearance

	var body: some View {
		VStack(spacing: 18) {
			TabView(selection: $selectedTab) {
				AppearanceTabView()
					.tag(SettingsTab.appearance)
					.tabItem {
						Label(SettingsTab.appearance.title,
							  systemImage: SettingsTab.appearance.systemImage)
					}
				SecurityTabView()
					.tag(SettingsTab.security)
					.tabItem {
						Label(SettingsTab.security.title,
							  systemImage: SettingsTab.security.systemImage)
					}
			}
		}
		.navigationTitle("Settings")
		.navigationBarTitleDisplayMode(.inline)
		.background(Color(uiColor: .systemGroupedBackground))
	}
}

#Preview {
	Color.clear
		.sheet(isPresented: .constant(true)) {
			NavigationStack {
				SettingsView()
			}
			.presentationDetents([.medium, .large])
			.presentationDragIndicator(.visible)
		}
}
